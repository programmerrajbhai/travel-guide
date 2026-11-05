import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static Future<Position?>? _pending;

  // Keep the existing method signature used by Home, Map and Places.
  static Future<Position?> getCurrentLocation() {
    final active = _pending;
    if (active != null) return active;

    final request = _readPosition().whenComplete(() {
      _pending = null;
    });

    _pending = request;
    return request;
  }

  static Future<Position?> _readPosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      debugPrint('[TravelGuide GPS] Device location is off.');
      return null;
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      debugPrint('[TravelGuide GPS] Permission: $permission');
      return null;
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 20),
      ),
    );

    if (kDebugMode) {
      debugPrint(
        '[TravelGuide GPS] '
            'lat=${position.latitude.toStringAsFixed(5)}, '
            'lng=${position.longitude.toStringAsFixed(5)}, '
            'accuracy=${position.accuracy.round()} m',
      );
    }

    return position;
  }

  static Future<String> getCityName(double lat, double lng) async {
    final coordinates =
        '${lat.toStringAsFixed(3)}, ${lng.toStringAsFixed(3)}';

    try {
      final places = await placemarkFromCoordinates(lat, lng)
          .timeout(const Duration(seconds: 8));

      if (places.isEmpty) return coordinates;

      final place = places.first;
      final city = [
        place.locality,
        place.subAdministrativeArea,
        place.administrativeArea,
      ].whereType<String>()
          .map((value) => value.trim())
          .firstWhere((value) => value.isNotEmpty, orElse: () => '');

      final country = (place.isoCountryCode ?? '').trim();
      final label = [
        if (city.isNotEmpty) city,
        if (country.isNotEmpty) country,
      ].join(', ');

      return label.isEmpty ? coordinates : label;
    } catch (_) {
      return coordinates;
    }
  }
}