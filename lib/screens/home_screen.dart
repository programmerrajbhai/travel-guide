import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../config/api_config.dart';
import '../constants/app_colors.dart';
import '../services/location_service.dart';
import '../widgets/dynamic_categories.dart';
import '../widgets/dynamic_places.dart';
import '../widgets/map_preview_section.dart';
import '../widgets/nearby_mosques_section.dart';
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
  int _refreshVersion = 0;

  @override
  void initState() {
    super.initState();
    _location = _getLocation();
  }

  Future<LatLng> _getLocation() async {
    final position = await LocationService.getCurrentLocation()
        .timeout(const Duration(seconds: 25));

    if (position == null) {
      throw StateError('Enable GPS and allow location access.');
    }

    return LatLng(position.latitude, position.longitude);
  }

  Future<void> _refresh() async {
    final request = _getLocation();

    setState(() {
      _location = request;
      _refreshVersion++;
    });

    try {
      await request;
    } catch (_) {
      // The FutureBuilder displays the location error.
    }
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
              final ready =
                  snapshot.connectionState == ConnectionState.done;
              final point = ready ? snapshot.data : null;
              final locationKey = point == null
                  ? 'no-location'
                  : '$_refreshVersion:${point.latitude},${point.longitude}';

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (point == null)
                      DynamicTopHeroSection(
                        point: null,
                        cityName: ready ? 'Location unavailable' : 'Locating…',
                        temperature: '--°C',
                        weatherStatus: ready ? 'Unavailable' : 'Loading',
                      )
                    else
                      _LiveHeader(
                        key: ValueKey('hero-$locationKey'),
                        point: point,
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
                          if (point != null) const DynamicPlaces(),
                          const SizedBox(height: 28),

                          if (!ready)
                            const Padding(
                              padding: EdgeInsets.all(14),
                              child: Center(
                                child: SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            )
                          else if (point == null)
                            Column(
                              children: [
                                Text(
                                  snapshot.error is StateError
                                      ? (snapshot.error as StateError).message
                                      : 'Could not get your location.',
                                  textAlign: TextAlign.center,
                                ),
                                TextButton(
                                  onPressed: _refresh,
                                  child: const Text('Retry'),
                                ),
                              ],
                            )
                          else
                            NearbyMosquesSection(
                              key: ValueKey('nearby-$locationKey'),
                              latitude: point.latitude,
                              longitude: point.longitude,
                              forceRefresh: _refreshVersion > 0,
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

class _LiveHeader extends StatefulWidget {
  final LatLng point;

  const _LiveHeader({
    super.key,
    required this.point,
  });

  @override
  State<_LiveHeader> createState() => _LiveHeaderState();
}

class _LiveHeaderState extends State<_LiveHeader> {
  late String _city;
  String _temperature = '--°C';
  String _weather = 'Loading';

  @override
  void initState() {
    super.initState();

    _city =
    '${widget.point.latitude.toStringAsFixed(2)}, '
        '${widget.point.longitude.toStringAsFixed(2)}';

    _loadCity();
    _loadWeather();
  }

  Future<void> _loadCity() async {
    try {
      final city = await LocationService.getCityName(
        widget.point.latitude,
        widget.point.longitude,
      ).timeout(const Duration(seconds: 10));

      if (!mounted || city.trim().isEmpty) return;
      setState(() => _city = city);
    } catch (_) {
      // Coordinates remain visible if reverse geocoding fails.
    }
  }

  Future<void> _loadWeather() async {
    try {
      final uri = Uri.parse(ApiConfig.weatherBaseUrl).replace(
        queryParameters: {
          'lat': '${widget.point.latitude}',
          'lon': '${widget.point.longitude}',
          'appid': ApiConfig.weatherApiKey,
          'units': 'metric',
        },
      );

      final response =
      await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw const FormatException('Weather unavailable');
      }

      final data = jsonDecode(response.body);
      final temperature = data['main']['temp'];
      if (temperature is! num) {
        throw const FormatException('Temperature unavailable');
      }

      final conditions = data['weather'];
      var description = 'Weather';

      if (conditions is List && conditions.isNotEmpty) {
        final first = conditions.first;
        if (first is Map && first['main'] is String) {
          description = first['main'] as String;
        }
      }

      if (!mounted) return;

      setState(() {
        _temperature = '${temperature.round()}°C';
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

  @override
  Widget build(BuildContext context) {
    return DynamicTopHeroSection(
      point: widget.point,
      cityName: _city,
      temperature: _temperature,
      weatherStatus: _weather,
    );
  }
}