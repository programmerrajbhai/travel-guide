import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static Future<Position?>? _pending;
  static Position? _last;
  static DateTime? _received;

  static final _cities = <String, String>{};
  static final _cityRequests = <String, Future<String>>{};

  static Future<Position?> getCurrentLocation() {
    final active = _pending;
    if (active != null) return active;

    late final Future<Position?> request;

    request = _read().whenComplete(() {
      if (identical(_pending, request)) {
        _pending = null;
      }
    });

    _pending = request;
    return request;
  }

  static Future<Position?> _read() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return null;
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    // Reuse only a very recent fix from this app session.
    if (_last != null &&
        _received != null &&
        DateTime.now().difference(_received!) <
            const Duration(seconds: 10)) {
      return _last;
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 20),
      ),
    );

    _last = position;
    _received = DateTime.now();

    return position;
  }

  static Future<String> getCityName(
      double lat,
      double lng,
      ) async {
    final key =
        '${lat.toStringAsFixed(3)},${lng.toStringAsFixed(3)}';

    if (_cities.containsKey(key)) {
      return _cities[key]!;
    }

    return _cityRequests.putIfAbsent(key, () async {
      try {
        final places = await placemarkFromCoordinates(
          lat,
          lng,
        ).timeout(const Duration(seconds: 8));

        if (places.isNotEmpty) {
          final p = places.first;

          final area = [
            p.locality,
            p.subAdministrativeArea,
            p.administrativeArea,
          ]
              .whereType<String>()
              .where((s) => s.trim().isNotEmpty);

          if (area.isNotEmpty) {
            final country =
                p.isoCountryCode ?? p.country ?? '';

            final label = country.isEmpty
                ? area.first
                : '${area.first}, $country';

            if (_cities.length >= 32) {
              _cities.remove(_cities.keys.first);
            }

            _cities[key] = label;
            return label;
          }
        }
      } catch (_) {}

      return '${lat.toStringAsFixed(3)}, '
          '${lng.toStringAsFixed(3)}';
    }).whenComplete(() {
      _cityRequests.remove(key);
    });
  }
}