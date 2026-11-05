import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/live_guide_service.dart';
import '../services/location_service.dart';

const guideGreen = Color(0xFF115C49);

enum GuideView { home, prayer, mosques }

class LiveGuidePanel extends StatefulWidget {
  final GuideView view;

  const LiveGuidePanel({super.key, this.view = GuideView.home});

  @override
  State<LiveGuidePanel> createState() => _LiveGuidePanelState();
}

class _LiveGuidePanelState extends State<LiveGuidePanel>
    with WidgetsBindingObserver {
  late Future<LatLng> _location;
  DateTime _day = DateTime.now();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _location = _locate();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => _checkDay());
  }

  Future<LatLng> _locate() async {
    final position = await LocationService.getCurrentLocation()
        .timeout(const Duration(seconds: 25));
    if (position == null) {
      throw const GuideException(
        'Turn on location and allow this app to access it.',
      );
    }
    return LatLng(position.latitude, position.longitude);
  }

  void _checkDay() {
    final now = DateTime.now();
    if (LiveGuideService.dayKey(now) != LiveGuideService.dayKey(_day)) {
      setState(() => _day = now);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _checkDay();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LatLng>(
      future: _location,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _Loading('Finding your location…');
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Card(child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(children: [
              Text(snapshot.error is GuideException
                  ? '${snapshot.error}'
                  : 'Could not get your location. Check GPS and retry.'),
              Wrap(children: [
                TextButton(
                  onPressed: () => Geolocator.openLocationSettings(),
                  child: const Text('GPS settings'),
                ),
                TextButton(
                  onPressed: () => Geolocator.openAppSettings(),
                  child: const Text('App settings'),
                ),
                TextButton(
                  onPressed: () => setState(() => _location = _locate()),
                  child: const Text('Retry'),
                ),
              ]),
            ]),
          ));
        }

        final point = snapshot.requireData;
        final place = '${point.latitude},${point.longitude}';
        final day = LiveGuideService.dayKey(_day);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.view != GuideView.mosques)
              _Data<PrayerDay>(
                key: ValueKey('prayer-$place-$day'),
                label: 'Prayer times',
                fetch: () => LiveGuideService.prayers(point, _day),
                render: (data) => _PrayerCard(data, point, _day),
              ),
            if (widget.view == GuideView.prayer)
              _Data<double>(
                key: ValueKey('qibla-$place'),
                label: 'Qibla',
                fetch: () => LiveGuideService.qibla(point),
                render: (angle) => Card(child: ListTile(
                  leading: Transform.rotate(
                    angle: angle * math.pi / 180,
                    child: const Icon(Icons.navigation, color: guideGreen),
                  ),
                  title: const Text('Qibla direction'),
                  subtitle: Text('${angle.toStringAsFixed(1)}° '
                      'clockwise from true north'),
                )),
              ),
            if (widget.view != GuideView.prayer)
              _Data<List<Mosque>>(
                key: ValueKey('mosques-$place-$day'),
                label: 'Nearby mosques',
                fetch: () => LiveGuideService.nearby(point),
                render: (items) => _MosqueSection(items, point, _day),
              ),
          ],
        );
      },
    );
  }
}

class _PrayerCard extends StatefulWidget {
  final PrayerDay data;
  final LatLng point;
  final DateTime day;
  const _PrayerCard(this.data, this.point, this.day);

  @override
  State<_PrayerCard> createState() => _PrayerCardState();
}

class _PrayerCardState extends State<_PrayerCard> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      const Duration(minutes: 1),
          (_) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Widget _nextPrayer() {
    final now = DateTime.now();
    for (final name in LiveGuideService.prayerNames) {
      final time = DateTime.parse(widget.data.times[name]!);
      if (time.isAfter(now)) {
        final minutes = (time.difference(now).inMilliseconds / 60000).ceil();
        return Text('Next · $name in $minutes min',
            style: const TextStyle(fontWeight: FontWeight.bold));
      }
    }

    final day = widget.day;
    final tomorrow = DateTime(day.year, day.month, day.day + 1);
    return _Data<PrayerDay>(
      key: ValueKey('next-${LiveGuideService.dayKey(tomorrow)}'),
      label: 'Tomorrow’s Fajr',
      fetch: () => LiveGuideService.prayers(widget.point, tomorrow),
      render: (data) => Text(
        'Next · Fajr tomorrow at ${LiveGuideService.clock(data.times['Fajr']!)}',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFE9F5EE),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Prayer times', style: TextStyle(
              color: guideGreen, fontSize: 22, fontWeight: FontWeight.bold,
            )),
            Text('${widget.data.hijri} · Hanafi'),
            Text('${widget.data.timezone} · '
                '${LiveGuideService.dayKey(widget.day)}'),
            const Divider(),
            for (final item in widget.data.times.entries)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item.key),
                    Text(LiveGuideService.clock(item.value)),
                  ],
                ),
              ),
            const Divider(),
            _nextPrayer(),
          ],
        ),
      ),
    );
  }
}

class _MosqueSection extends StatelessWidget {
  final List<Mosque> mosques;
  final LatLng user;
  final DateTime day;
  const _MosqueSection(this.mosques, this.user, this.day);

  void _showTimes(BuildContext context, Mosque mosque) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(mosque.name,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              if (mosque.address.isNotEmpty) Text(mosque.address),
              const SizedBox(height: 12),
              Text('Jamaat · ${LiveGuideService.dayKey(day)}',
                  style: const TextStyle(color: guideGreen, fontWeight: FontWeight.bold)),
              _Data<Map<String, String>>(
                label: 'Jamaat times',
                fetch: () => LiveGuideService.jamaat(mosque.id, day),
                render: (times) {
                  if (times.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text('No jamaat times available for this date.'),
                    );
                  }
                  return Column(children: [
                    for (final name in LiveGuideService.prayerNames)
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(name),
                        trailing: Text(times[name] ?? 'Unavailable'),
                      ),
                  ]);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pins = mosques.where((m) => m.point != null).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        const Text('Nearby mosques', style: TextStyle(
          fontSize: 20, fontWeight: FontWeight.bold,
        )),
        Text('${mosques.length} listed within 10 miles'),
        const SizedBox(height: 8),
        if (mosques.isEmpty)
          const Card(child: ListTile(
            leading: Icon(Icons.mosque_outlined),
            title: Text('No listed mosques in this area.'),
          )),
        if (pins.isNotEmpty)
          SizedBox(
            height: 230,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: user, initialZoom: 12,
                  initialCameraFit: CameraFit.bounds(
                    bounds: LatLngBounds.fromPoints(
                      [user, ...pins.map((m) => m.point!)],
                    ),
                    padding: const EdgeInsets.all(28),
                    maxZoom: 15,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.travel_guide',
                  ),
                  MarkerLayer(markers: [
                    Marker(
                      point: user, width: 24, height: 24,
                      child: const Icon(Icons.my_location, color: Colors.blue),
                    ),
                    for (final m in pins)
                      Marker(
                        point: m.point!, width: 42, height: 42,
                        child: IconButton(
                          tooltip: m.name,
                          onPressed: () => _showTimes(context, m),
                          icon: const Icon(Icons.location_on, color: guideGreen),
                        ),
                      ),
                  ]),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Material(
                      color: Colors.white,
                      child: InkWell(
                        onTap: () => launchUrl(
                          Uri.parse('https://www.openstreetmap.org/copyright'),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(5),
                          child: Text('© OpenStreetMap contributors',
                              style: TextStyle(fontSize: 11)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        for (final m in mosques)
          Card(child: ListTile(
            leading: const Icon(Icons.mosque, color: guideGreen),
            title: Text(m.name),
            subtitle: Text([
              if (m.distanceKm != null) '${m.distanceKm!.toStringAsFixed(1)} km',
              if (m.address.isNotEmpty) m.address,
            ].join(' · ')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showTimes(context, m),
          )),
      ],
    );
  }
}

class _Data<T> extends StatefulWidget {
  final String label;
  final Future<T> Function() fetch;
  final Widget Function(T) render;

  const _Data({
    super.key, required this.label, required this.fetch, required this.render,
  });

  @override
  State<_Data<T>> createState() => _DataState<T>();
}

class _DataState<T> extends State<_Data<T>> {
  late Future<T> future;

  @override
  void initState() {
    super.initState();
    future = Future<T>.sync(widget.fetch);
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<T>(
    future: future,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return _Loading('Loading ${widget.label.toLowerCase()}…');
      }
      if (snapshot.hasError) {
        return Card(child: ListTile(
          title: Text(widget.label),
          subtitle: Text(snapshot.error is GuideException
              ? '${snapshot.error}' : 'Could not read the response.'),
          trailing: TextButton(
            onPressed: () => setState(() {
              future = Future<T>.sync(widget.fetch);
            }),
            child: const Text('Retry'),
          ),
        ));
      }
      return widget.render(snapshot.requireData);
    },
  );
}

class _Loading extends StatelessWidget {
  final String text;
  const _Loading(this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 14),
    child: Row(children: [
      const SizedBox(width: 17, height: 17,
          child: CircularProgressIndicator(strokeWidth: 2)),
      const SizedBox(width: 12),
      Expanded(child: Text(text)),
    ]),
  );
}