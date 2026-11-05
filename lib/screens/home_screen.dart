import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/api_config.dart';
import '../constants/app_colors.dart';
import '../services/live_guide_service.dart';
import '../services/location_service.dart';
import '../widgets/dynamic_categories.dart';
import '../widgets/dynamic_places.dart';
import '../widgets/live_guide_panel.dart';
import '../widgets/map_preview_section.dart';
import '../widgets/quick_actions_section.dart';
import '../widgets/top_hero_section.dart';
import '../widgets/travel_assistant_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<LatLng> _location;

  @override
  void initState() {
    super.initState();
    _location = _getLocation();
  }

  Future<LatLng> _getLocation() async {
    final position = await LocationService.getCurrentLocation()
        .timeout(const Duration(seconds: 25));

    if (position == null) {
      throw const GuideException('Enable GPS and allow location access.');
    }

    return LatLng(position.latitude, position.longitude);
  }
  Future<void> _refresh() async {
    final request = _getLocation();

    setState(() {
      _location = request;
    });

    try {
      await request;
    } catch (_) {
      // FutureBuilder দেখাবে কেন location পাওয়া যায়নি।
    }
  }

  void _openAllMosques() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          backgroundColor: AppColors.backgroundColor,
          appBar: AppBar(title: const Text('Nearby mosques')),
          body: const SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: LiveGuidePanel(view: GuideView.mosques),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: FutureBuilder<LatLng>(
            future: _location,
            builder: (context, snapshot) {
              final ready = snapshot.connectionState == ConnectionState.done;
              final point = ready ? snapshot.data : null;
              final locationKey = point == null
                  ? 'no-location'
                  : '${point.latitude},${point.longitude}';

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (point != null)
                      _LiveHero(
                        key: ValueKey('hero-$locationKey'),
                        point: point,
                      )
                    else
                      DynamicTopHeroSection(
                        cityName: ready ? 'Location unavailable' : 'Locating…',
                        temperature: '--°C',
                        weatherStatus: ready ? 'Unavailable' : 'Loading',
                        nextPrayerName: ready ? '—' : 'Loading',
                        timeRemaining: '--:--:--',
                        sunProgress: 0,
                      ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 20),
                          const TravelAssistantCard(),

                          const SizedBox(height: 28),
                          const QuickActionsSection(),

                          const SizedBox(height: 28),
                          const DynamicCategories(),

                          const SizedBox(height: 28),
                          // This existing widget also requests GPS.
                          // Mount it after the Home location request completes.
                          if (point != null) const DynamicPlaces(),

                          const SizedBox(height: 28),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'NEARBY MASJIDS',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: AppColors.textDark,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              InkWell(
                                onTap: _openAllMosques,
                                borderRadius: BorderRadius.circular(8),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 8,
                                  ),
                                  child: Text(
                                    'View All',
                                    style: TextStyle(
                                      color: AppColors.primaryColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          if (!ready)
                            const _HomeLoading()
                          else if (point == null)
                            _HomeNotice(
                              message: snapshot.error is GuideException
                                  ? '${snapshot.error}'
                                  : 'Could not get your location.',
                              onRetry: _refresh,
                            )
                          else
                            _NearbyPreview(
                              key: ValueKey('nearby-$locationKey'),
                              point: point,
                            ),

                          const SizedBox(height: 28),
                          const MapPreviewSection(),
                          const SizedBox(height: 110),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// Uses your original hero widget. Only the hero updates every second.
class _LiveHero extends StatefulWidget {
  final LatLng point;

  const _LiveHero({super.key, required this.point});

  @override
  State<_LiveHero> createState() => _LiveHeroState();
}

class _LiveHeroState extends State<_LiveHero> {
  Timer? _timer;
  late DateTime _day;
  late Future<PrayerDay> _today;
  Future<PrayerDay>? _tomorrow;

  String _city = '';
  String _temperature = '--°C';
  String _weather = 'Loading';

  @override
  void initState() {
    super.initState();
    _day = DateTime.now();
    _today = LiveGuideService.prayers(widget.point, _day);
    _city = _coordinateLabel();
    _loadWeather();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now();
      setState(() {
        if (LiveGuideService.dayKey(now) != LiveGuideService.dayKey(_day)) {
          _day = now;
          _today = LiveGuideService.prayers(widget.point, now);
          _tomorrow = null;
        }
      });
    });
  }

  String _coordinateLabel() =>
      '${widget.point.latitude.toStringAsFixed(2)}, '
          '${widget.point.longitude.toStringAsFixed(2)}';

  Future<void> _loadWeather() async {
    await Future.wait<void>([
      _loadCityLabel(),
      _loadTemperature(),
    ]);
  }

  Future<void> _loadCityLabel() async {
    final label = await LocationService.getCityName(
      widget.point.latitude,
      widget.point.longitude,
    );

    if (!mounted) return;

    setState(() {
      _city = label;
    });
  }

  Future<void> _loadTemperature() async {
    try {
      final key = ApiConfig.weatherApiKey.trim();
      if (key.isEmpty) {
        throw const FormatException('Weather key missing.');
      }

      final uri = Uri.parse(ApiConfig.weatherBaseUrl).replace(
        queryParameters: {
          'lat': widget.point.latitude.toString(),
          'lon': widget.point.longitude.toString(),
          'units': 'metric',
          'appid': key,
        },
      );

      final response = await http.get(uri).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode != 200) {
        throw const FormatException('Weather request failed.');
      }

      final data = jsonDecode(response.body);
      final temp = data['main']['temp'];
      final conditions = data['weather'];

      if (temp is! num) {
        throw const FormatException('Temperature missing.');
      }

      String description = 'Weather';
      if (conditions is List && conditions.isNotEmpty) {
        final first = conditions.first;
        if (first is Map && first['main'] is String) {
          description = first['main'] as String;
        }
      }

      if (!mounted) return;
      setState(() {
        _temperature = '${temp.round()}°C';
        _weather = description;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _temperature = '--°C';
        _weather = 'Unavailable';
      });
    }
  }

  String _countdown(DateTime next, DateTime now) {
    final seconds = (next.difference(now).inMilliseconds / 1000).ceil();
    final total = seconds < 0 ? 0 : seconds;

    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(total ~/ 3600)}:'
        '${two((total ~/ 60) % 60)}:'
        '${two(total % 60)}';
  }

  double _progress(DateTime? previous, DateTime next, DateTime now) {
    if (previous == null) return 0;
    final interval = next.difference(previous).inSeconds;
    if (interval <= 0) return 0;
    return (now.difference(previous).inSeconds / interval)
        .clamp(0.0, 1.0)
        .toDouble();
  }

  Widget _hero(String prayer, String remaining, double progress) {
    return DynamicTopHeroSection(
      cityName: _city,
      temperature: _temperature,
      weatherStatus: _weather,
      nextPrayerName: prayer,
      timeRemaining: remaining,
      sunProgress: progress,
    );
  }

  Widget _scheduleError(VoidCallback retry) {
    return Column(children: [
      _hero('—', '--:--:--', 0),
      _HomeNotice(
        message: 'Prayer times unavailable.',
        onRetry: retry,
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PrayerDay>(
      future: _today,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return _hero('Loading', '--:--:--', 0);
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return _scheduleError(() => setState(() {
            _today = LiveGuideService.prayers(widget.point, _day);
          }));
        }

        final times = snapshot.requireData.times;
        final now = DateTime.now();
        DateTime? previous;

        // Sunrise is shown on the details screen, but is not a next prayer.
        for (final name in LiveGuideService.prayerNames) {
          final next = DateTime.parse(times[name]!);
          if (next.isAfter(now)) {
            return _hero(
              name.toUpperCase(),
              _countdown(next, now),
              _progress(previous, next, now),
            );
          }
          previous = next;
        }

        // After Isha, count down to tomorrow's Fajr.
        final tomorrow = DateTime(_day.year, _day.month, _day.day + 1);
        final isha = DateTime.parse(times['Isha']!);
        _tomorrow ??= LiveGuideService.prayers(widget.point, tomorrow);

        return FutureBuilder<PrayerDay>(
          future: _tomorrow,
          builder: (context, nextDay) {
            if (nextDay.connectionState != ConnectionState.done) {
              return _hero('FAJR', '--:--:--', 0);
            }
            if (nextDay.hasError || !nextDay.hasData) {
              return _scheduleError(() => setState(() {
                _tomorrow = LiveGuideService.prayers(widget.point, tomorrow);
              }));
            }

            final fajr = DateTime.parse(nextDay.requireData.times['Fajr']!);
            return _hero(
              'FAJR',
              _countdown(fajr, now),
              _progress(isha, fajr, now),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class _NearbyPreview extends StatefulWidget {
  final LatLng point;

  const _NearbyPreview({super.key, required this.point});

  @override
  State<_NearbyPreview> createState() => _NearbyPreviewState();
}

class _NearbyPreviewState extends State<_NearbyPreview> {
  late Future<List<Mosque>> _mosques;

  @override
  void initState() {
    super.initState();
    _mosques = LiveGuideService.nearby(widget.point);
  }

  Future<void> _openMap(Mosque mosque) async {
    final point = mosque.point;
    if (point == null) return;

    final uri = Uri.https(
      'www.openstreetmap.org',
      '/',
      {
        'mlat': point.latitude.toString(),
        'mlon': point.longitude.toString(),
      },
    ).replace(fragment: 'map=17/${point.latitude}/${point.longitude}');

    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (opened) return;
    } catch (_) {
      // Show the same user-facing message if no handler is available.
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not open this mosque on the map.')),
    );
  }

  void _openSchedule(Mosque mosque) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => _MosqueScheduleSheet(mosque: mosque),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Mosque>>(
      future: _mosques,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _HomeLoading();
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return _HomeNotice(
            message: snapshot.error is GuideException
                ? '${snapshot.error}'
                : 'Could not load nearby mosques.',
            onRetry: () => setState(() {
              _mosques = LiveGuideService.nearby(widget.point);
            }),
          );
        }

        final mosques = snapshot.requireData;
        if (mosques.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'No mosques listed within 10 miles.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return Column(
          children: [
            for (final mosque in mosques.take(2))
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => _openSchedule(mosque),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.mosque,
                              color: Colors.grey,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  mosque.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(children: [
                                  const Icon(
                                    Icons.location_on_outlined,
                                    color: AppColors.primaryColor,
                                    size: 15,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      mosque.distanceKm != null
                                          ? '${mosque.distanceKm!.toStringAsFixed(1)} km away'
                                          : 'Distance unavailable',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textLight,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ]),
                              ],
                            ),
                          ),
                          if (mosque.point != null)
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: IconButton(
                                tooltip: 'Open mosque on map',
                                icon: const Icon(Icons.near_me_outlined, size: 18),
                                color: AppColors.textDark,
                                onPressed: () => _openMap(mosque),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _MosqueScheduleSheet extends StatefulWidget {
  final Mosque mosque;
  const _MosqueScheduleSheet({required this.mosque});

  @override
  State<_MosqueScheduleSheet> createState() => _MosqueScheduleSheetState();
}

class _MosqueScheduleSheetState extends State<_MosqueScheduleSheet> {
  late final DateTime _day;
  late Future<Map<String, String>> _schedule;

  @override
  void initState() {
    super.initState();
    _day = DateTime.now();
    _schedule = LiveGuideService.jamaat(widget.mosque.id, _day);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.mosque.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            if (widget.mosque.address.isNotEmpty)
              Text(widget.mosque.address),
            const SizedBox(height: 16),
            Text(
              'Jamaat · ${LiveGuideService.dayKey(_day)}',
              style: const TextStyle(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            FutureBuilder<Map<String, String>>(
              future: _schedule,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const _HomeLoading();
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return _HomeNotice(
                    message: snapshot.error is GuideException
                        ? '${snapshot.error}'
                        : 'Could not load the daily schedule.',
                    onRetry: () => setState(() {
                      _schedule = LiveGuideService.jamaat(widget.mosque.id, _day);
                    }),
                  );
                }

                final times = snapshot.requireData;
                if (times.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text('No jamaat times available for this date.'),
                  );
                }

                return Column(children: [
                  for (final prayer in LiveGuideService.prayerNames)
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(prayer),
                      trailing: Text(times[prayer] ?? 'Unavailable'),
                    ),
                ]);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeLoading extends StatelessWidget {
  const _HomeLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 14),
      child: Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}

class _HomeNotice extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _HomeNotice({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.grey),
      ),
      TextButton(onPressed: onRetry, child: const Text('Retry')),
    ]);
  }
}