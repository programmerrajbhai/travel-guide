import '../services/muslims_day_service.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../constants/app_colors.dart';

const _prayerNames = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

String _two(int number) => number.toString().padLeft(2, '0');

String _dateKey(DateTime date) {
  return '${_two(date.day)}-${_two(date.month)}-${date.year}';
}

class _PrayerDay {
  final tz.Location zone;
  final String date;
  final Map<String, DateTime> times;

  final String sourceLabel;
  const _PrayerDay(
    this.zone,
    this.date,
    this.times, [
    this.sourceLabel = 'AlAdhan · GPS',
  ]);

  static bool _zonesReady = false;
  static final _cache = <String, _PrayerDay>{};

  bool covers(DateTime instant) {
    final local = tz.TZDateTime.from(instant, zone);
    return _dateKey(local) == date;
  }

  String clock(String prayer) {
    final local = tz.TZDateTime.from(times[prayer]!, zone);
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final period = local.hour < 12 ? 'AM' : 'PM';

    return '$hour:${_two(local.minute)} $period';
  }

  static Future<_PrayerDay> fetch(LatLng point, DateTime instant) async {
    if (!_zonesReady) {
      tzdata.initializeTimeZones();
      _zonesReady = true;
    }

    final md = await MuslimsDayService.forGps(point, instant);
    if (md != null) {
      return _PrayerDay(
        md.zone,
        _dateKey(tz.TZDateTime.from(instant, md.zone)),
        md.times,
        'Muslims Day · ${md.city}',
      );
    }
    final area = '${point.latitude},${point.longitude}/';

    for (final entry in _cache.entries) {
      if (entry.key.startsWith(area) && entry.value.covers(instant)) {
        return entry.value;
      }
    }

    Future<Map> request(String day) async {
      final uri = Uri.https('api.aladhan.com', '/v1/timings/$day', {
        'latitude': '${point.latitude}',
        'longitude': '${point.longitude}',
        'method': '1', // Karachi calculation method
        'school': '1', // Hanafi Asr
        'iso8601': 'true',
      });

      final response = await http.get(uri).timeout(const Duration(seconds: 12));

      if (response.statusCode != 200) {
        throw const FormatException('Prayer server unavailable');
      }

      final body = jsonDecode(utf8.decode(response.bodyBytes));

      if (body is! Map || body['code'] != 200 || body['data'] is! Map) {
        throw const FormatException('Invalid prayer response');
      }

      return body['data'] as Map;
    }

    // The GPS coordinates determine the timezone.
    // Using an instant also works when the phone uses another timezone.
    final epoch = instant.millisecondsSinceEpoch ~/ 1000;
    var data = await request('$epoch');

    final zone = tz.getLocation(data['meta']['timezone'] as String);
    final localDate = _dateKey(tz.TZDateTime.from(instant, zone));

    if (data['date']['gregorian']['date'] != localDate) {
      data = await request(localDate);
    }
    if (data['date']['gregorian']['date'] != localDate) {
      throw const FormatException('Incorrect prayer date');
    }

    final times = <String, DateTime>{};

    for (final name in _prayerNames) {
      final raw = data['timings'][name];

      if (raw is! String || !RegExp(r'(Z|[+-]\d{2}:?\d{2})$').hasMatch(raw)) {
        throw FormatException('Missing local prayer time for $name');
      }

      times[name] = DateTime.parse(raw).toUtc();
    }

    final result = _PrayerDay(zone, localDate, times);

    if (_cache.length >= 12) {
      _cache.remove(_cache.keys.first);
    }

    _cache['$area$localDate'] = result;
    return result;
  }
}

class DynamicTopHeroSection extends StatefulWidget {
  final LatLng? point;
  final String cityName;
  final String temperature;
  final String weatherStatus;

  const DynamicTopHeroSection({
    super.key,
    required this.point,
    required this.cityName,
    required this.temperature,
    required this.weatherStatus,
  });

  @override
  State<DynamicTopHeroSection> createState() => _HeroState();
}

class _HeroState extends State<DynamicTopHeroSection> {
  Timer? _timer;
  _PrayerDay? _today;
  _PrayerDay? _tomorrow;

  bool _busy = false;
  bool _failed = false;
  int _version = 0;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void didUpdateWidget(covariant DynamicTopHeroSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.point != widget.point) {
      _start();
    }
  }

  void _start() {
    _version++;
    _timer?.cancel();
    _today = null;
    _tomorrow = null;
    _busy = false;
    _failed = false;

    if (widget.point == null) return;

    _sync();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      _sync();

      // Only this hero rebuilds for the countdown.
      setState(() {});
    });
  }

  Future<void> _sync() async {
    final point = widget.point;
    if (point == null || _busy || _failed) return;

    final now = DateTime.now().toUtc();
    final current = _today;
    final needsToday = current == null || !current.covers(now);

    if (current != null && !needsToday) {
      final beforeEndOfDayPrayers = current.times['Isha']!.isAfter(now);

      if (beforeEndOfDayPrayers || _tomorrow != null) {
        return;
      }
    }

    final version = _version;
    _busy = true;

    try {
      if (needsToday) {
        final day = await _PrayerDay.fetch(point, now);
        if (!mounted || version != _version) return;

        setState(() {
          _today = day;
          _tomorrow = null;
        });
      } else {
        final zone = current!.zone;
        final local = tz.TZDateTime.from(now, zone);

        // Local noon on the next calendar date avoids midnight/DST ambiguity.
        final nextLocalDay = tz.TZDateTime(
          zone,
          local.year,
          local.month,
          local.day + 1,
          12,
        );

        final day = await _PrayerDay.fetch(point, nextLocalDay);
        if (!mounted || version != _version) return;

        setState(() => _tomorrow = day);
      }
    } catch (_) {
      if (mounted && version == _version) {
        setState(() => _failed = true);
      }
    } finally {
      if (version == _version) _busy = false;
    }
  }

  void _showTimes(_PrayerDay day) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          children: [
            Text(
              widget.cityName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${day.date} · ${day.zone.name} · ${day.sourceLabel}',
              style: const TextStyle(color: AppColors.textLight),
            ),
            const SizedBox(height: 12),
            for (final name in _prayerNames)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(name),
                trailing: Text(
                  day.clock(name),
                  style: const TextStyle(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now().toUtc();
    final today = _today?.covers(now) == true ? _today : null;

    String? nextPrayer;
    DateTime? previous;
    var targetDay = today;

    if (today != null) {
      for (final name in _prayerNames) {
        final time = today.times[name]!;

        if (time.isAfter(now)) {
          nextPrayer = name;
          break;
        }

        previous = time;
      }

      if (nextPrayer == null) {
        nextPrayer = 'Fajr';
        targetDay = _tomorrow;
      }
    }

    final target = nextPrayer == null ? null : targetDay?.times[nextPrayer];

    var remaining = '--:--:--';
    var progress = 0.0;

    if (target != null) {
      final seconds = math.max(
        0,
        (target.difference(now).inMilliseconds / 1000).ceil(),
      );

      remaining =
          '${_two(seconds ~/ 3600)}:'
          '${_two((seconds ~/ 60) % 60)}:'
          '${_two(seconds % 60)}';

      if (previous != null && target.isAfter(previous)) {
        progress =
            (now.difference(previous).inSeconds /
                    target.difference(previous).inSeconds)
                .clamp(0.0, 1.0)
                .toDouble();
      }
    }

    final clock = target == null ? '--:--' : targetDay!.clock(nextPrayer!);

    final dayLabel = today == null
        ? 'Local time'
        : targetDay == today
        ? 'Today'
        : 'Tomorrow';

    final prayerLabel =
        nextPrayer?.toUpperCase() ??
        (_failed || widget.point == null ? '—' : 'Loading');

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          right: 0,
          top: 30,
          child: Image.network(
            'https://cdn3d.iconscout.com/3d/premium/thumb/mosque-5353597-4468685.png',
            width: MediaQuery.sizeOf(context).width * 0.45,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              const SizedBox(height: 24),
              _prayerCard(
                prayer: prayerLabel,
                clock: clock,
                remaining: remaining,
                dayLabel: dayLabel,
                progress: progress,
                onTimes: today == null ? null : () => _showTimes(today),
              ),
              if (today != null)
                Text(
                  targetDay?.sourceLabel ?? today.sourceLabel,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textLight,
                  ),
                ),
              if (_failed)
                Center(
                  child: TextButton(
                    onPressed: () {
                      setState(() => _failed = false);
                      _sync();
                    },
                    child: const Text('Prayer times unavailable · Retry'),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _header() {
    final shadow = BoxShadow(
      color: Colors.grey.withOpacity(0.15),
      blurRadius: 10,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 16,
                    color: AppColors.textDark,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      widget.cityName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    size: 16,
                    color: AppColors.textDark,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                'Assalamu Alaikum,',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'May Allah bless your day',
                style: TextStyle(fontSize: 12, color: AppColors.textLight),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [shadow],
          ),
          child: Row(
            children: [
              const Icon(Icons.wb_sunny, color: Color(0xFFFFB300), size: 16),
              const SizedBox(width: 6),
              Text(
                '${widget.temperature}\n${widget.weatherStatus}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 10,
                  height: 1.1,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [shadow],
              ),
              child: const Icon(Icons.notifications_none, size: 20),
            ),
            Positioned(
              right: -2,
              top: -4,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFE53935),
                ),
                child: const Text(
                  '3',
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _prayerCard({
    required String prayer,
    required String clock,
    required String remaining,
    required String dayLabel,
    required double progress,
    required VoidCallback? onTimes,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'NEXT PRAYER',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    prayer,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    remaining,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Text(
                  'remaining',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 16),
                Material(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(24),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: onTimes,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'View Prayer Times',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(width: 5),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                              size: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 5,
            child: Column(
              children: [
                SizedBox(
                  width: 110,
                  height: 65,
                  child: CustomPaint(
                    painter: SunArcPainter(progress: progress),
                  ),
                ),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    clock,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
                Text(
                  dayLabel,
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.volume_up, color: Colors.black87, size: 18),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _version++;
    _timer?.cancel();
    super.dispose();
  }
}

class SunArcPainter extends CustomPainter {
  final double progress;

  const SunArcPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final radius = math.min(size.width / 2 - 5, size.height - 8);
    if (radius <= 0) return;

    final center = Offset(size.width / 2, size.height - 5);
    final dots = Paint()..color = Colors.white54;

    Offset onArc(double fraction) {
      final angle = math.pi + math.pi * fraction;
      return Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
    }

    for (var i = 0; i <= 20; i++) {
      canvas.drawCircle(onArc(i / 20), 1.5, dots);
    }

    final track = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(
      center: center,
      radius: math.max(1.0, radius - 10),
    );

    canvas.drawArc(rect, math.pi, math.pi, false, track);

    track.color = const Color(0xFF2EA866);
    canvas.drawArc(rect, math.pi, math.pi * progress, false, track);

    final sun = onArc(progress);
    canvas.drawCircle(sun, 4, Paint()..color = Colors.amber);
  }

  @override
  bool shouldRepaint(covariant SunArcPainter old) {
    return old.progress != progress;
  }
}
