import 'dart:async';
import 'dart:convert';

import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:timezone/timezone.dart' as tz;

typedef MuslimsDayResult = ({
  String city,
  tz.Location zone,
  Map<String, DateTime> times,
});

class MuslimsDayService {
  static const _method = 'University of Islamic Sciences, Karachi';

  static final _locations = <String, ({DateTime until, String? slug})>{};

  static final _months = <String, ({DateTime until, Map data})>{};

  static Future<Map> _get(String endpoint, Map<String, String> query) async {
    final uri = Uri.https(
      'muslimsday.com',
      '/api/prayer-times/$endpoint',
      query,
    );

    final response = await http
        .get(uri, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw FormatException('Muslims Day returned HTTP ${response.statusCode}');
    }

    final data = jsonDecode(utf8.decode(response.bodyBytes));

    if (data is! Map) {
      throw const FormatException('Invalid Muslims Day response');
    }

    return data;
  }

  static String _clean(String? name) {
    return (name ?? '')
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+(?:district|upazila|zila|জেলা|উপজেলা)$'), '')
        .trim();
  }

  static Future<String?> _findCity(LatLng point) async {
    final key =
        '${point.latitude.toStringAsFixed(3)},'
        '${point.longitude.toStringAsFixed(3)}';

    final cached = _locations[key];

    if (cached != null && DateTime.now().isBefore(cached.until)) {
      return cached.slug;
    }

    final places = await placemarkFromCoordinates(
      point.latitude,
      point.longitude,
    ).timeout(const Duration(seconds: 6));

    String? slug;

    if (places.isNotEmpty &&
        places.first.isoCountryCode?.toUpperCase() == 'BD') {
      final place = places.first;

      // Example: Dimla first, then Nilphamari District.
      final candidates = [
        place.locality,
        place.subLocality,
        place.subAdministrativeArea,
      ].map(_clean).where((name) => name.isNotEmpty).toSet();

      for (final name in candidates) {
        final response = await _get('search', {
          'country': 'bangladesh',
          'lang': 'en',
          'q': name,
        });

        final cities = response['cities'];

        if (cities is! List) {
          throw const FormatException('Invalid city list');
        }

        for (final city in cities.whereType<Map>()) {
          if (city['country'] != 'bangladesh' || city['slug'] is! String) {
            continue;
          }

          // Search may return partial matches. Accept an exact name.
          final aliases = [
            city['nameEn'],
            city['nameBn'],
            city['name'],
            city['slug'],
          ].whereType<String>().map(_clean);

          if (aliases.contains(name)) {
            slug = city['slug'] as String;
            break;
          }
        }

        if (slug != null) break;
      }
    }

    if (_locations.length >= 32) {
      _locations.remove(_locations.keys.first);
    }

    _locations[key] = (
      slug: slug,
      until: DateTime.now().add(
        slug == null ? const Duration(minutes: 15) : const Duration(hours: 6),
      ),
    );

    return slug;
  }

  static Future<MuslimsDayResult?> forGps(
    LatLng point,
    DateTime instant,
  ) async {
    try {
      final slug = await _findCity(point);
      if (slug == null) return null;

      // The existing Home prayer widget initializes timezone data.
      final zone = tz.getLocation('Asia/Dhaka');
      final day = tz.TZDateTime.from(instant, zone);

      final cacheKey = '$slug/${day.year}/${day.month}';
      final cached = _months[cacheKey];
      final useCache = cached != null && DateTime.now().isBefore(cached.until);

      final Map data;

      if (useCache) {
        data = cached!.data;
      } else {
        data = await _get('month', {
          'country': 'bangladesh',
          'city': slug,
          'year': '${day.year}',
          'month': '${day.month}',
          'method': _method,
          'madhab': 'hanafi',
        });

        final city = data['city'];

        if (city is! Map ||
            city['country'] != 'bangladesh' ||
            city['slug'] != slug ||
            city['timezone'] != zone.name ||
            data['method'] != _method ||
            data['madhab'] != 'hanafi' ||
            data['year'] != day.year ||
            data['month'] != day.month ||
            data['days'] is! List) {
          throw const FormatException('Unexpected monthly timetable');
        }
      }

      String two(int value) => value.toString().padLeft(2, '0');

      final date = '${day.year}-${two(day.month)}-${two(day.day)}';

      final row = (data['days'] as List).whereType<Map>().firstWhere(
        (item) => item['date'] == date,
      );

      final times = <String, DateTime>{};

      for (final prayer in ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha']) {
        final raw = row[prayer.toLowerCase()];

        if (raw is! String ||
            !RegExp(r'^(?:[01]\d|2[0-3]):[0-5]\d$').hasMatch(raw)) {
          throw FormatException('Invalid $prayer time');
        }

        final local = tz.TZDateTime(
          zone,
          day.year,
          day.month,
          day.day,
          int.parse(raw.substring(0, 2)),
          int.parse(raw.substring(3)),
        );

        times[prayer] = local.toUtc();
      }

      if (!useCache) {
        if (_months.length >= 8) {
          _months.remove(_months.keys.first);
        }

        _months[cacheKey] = (
          until: DateTime.now().add(const Duration(hours: 6)),
          data: data,
        );
      }

      final city = data['city'] as Map;
      final cityName =
          (city['nameBn'] as String?) ?? (city['nameEn'] as String);

      return (city: cityName, zone: zone, times: times);
    } catch (error) {
      print('[TravelGuide] Muslims Day timetable unavailable: $error');
      return null;
    }
  }
}
