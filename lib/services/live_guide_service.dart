import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

typedef Json = Map<String, dynamic>;

class GuideException implements Exception {
  final String message;
  const GuideException(this.message);

  @override
  String toString() => message;
}

class Mosque {
  final String id;
  final String name;
  final String address;
  final LatLng? point;
  final double? distanceKm;

  const Mosque({
    required this.id,
    required this.name,
    required this.address,
    required this.point,
    required this.distanceKm,
  });

  factory Mosque.fromJson(Json row, LatLng user) {
    // The daily schedule endpoint requires masjid_id, not the row's id.
    final id = '${row['masjid_id'] ?? ''}'.trim();
    if ((int.tryParse(id) ?? 0) <= 0) {
      throw const GuideException('Invalid mosque ID in directory.');
    }

    final lat = double.tryParse('${row['latitude']}');
    final lng = double.tryParse('${row['longitude']}');
    LatLng? point;
    double? km;

    if (lat != null && lng != null &&
        lat.isFinite && lng.isFinite &&
        lat.abs() <= 90 && lng.abs() <= 180 &&
        !(lat == 0 && lng == 0)) {
      point = LatLng(lat, lng);
      km = Geolocator.distanceBetween(
        user.latitude, user.longitude, lat, lng,
      ) / 1000;
    }

    final title = '${row['title'] ?? ''}'.trim();
    final address = [
      for (final field in ['address', 'city'])
        if ('${row[field] ?? ''}'.trim().isNotEmpty)
          '${row[field]}'.trim(),
    ].join(', ');

    return Mosque(
      id: id,
      name: title.isEmpty ? 'Mosque #$id' : title,
      address: address,
      point: point,
      distanceKm: km,
    );
  }
}

class PrayerDay {
  final Map<String, String> times;
  final String hijri;
  final String timezone;

  const PrayerDay(this.times, this.hijri, this.timezone);
}

class LiveGuideService {
  // Android Emulator + Mac XAMPP.
  // For a real phone or release, put your own HTTPS endpoint here.
  static const proxy = 'http://192.168.1.102/travel_admin/masjidi.php';


  static const prayerNames = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
  static final _cache = <Uri, ({DateTime expires, dynamic data})>{};
  static final _pending = <Uri, Future<dynamic>>{};

  static String _two(int n) => n.toString().padLeft(2, '0');

  static String dayKey(DateTime d) =>
      '${d.year}-${_two(d.month)}-${_two(d.day)}';

  static Future<dynamic> _json(Uri uri, Duration ttl) async {
    final now = DateTime.now();
    _cache.removeWhere((_, entry) => !entry.expires.isAfter(now));
    final cached = _cache[uri];
    if (cached != null) return cached.data;

    final running = _pending[uri];
    if (running != null) return await running;

    final request = _request(uri);
    _pending[uri] = request;
    try {
      final data = await request;
      _cache[uri] = (expires: DateTime.now().add(ttl), data: data);
      return data;
    } finally {
      _pending.remove(uri);
    }
  }

  static Future<dynamic> _request(Uri uri) async {
    final http.Response response;
    try {
      response = await http.get(
        uri,
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 20));
    } on TimeoutException {
      throw const GuideException('The request timed out. Please retry.');
    } on http.ClientException {
      throw const GuideException('Could not connect to the server.');
    }

    dynamic body;
    try {
      body = jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      throw GuideException('Expected JSON. Server returned HTTP '
          '${response.statusCode}. Check the endpoint URL.');
    }

    if (response.statusCode != 200) {
      final message = body is Map ? body['error'] : null;
      throw GuideException(
        message is String ? message : 'Server error ${response.statusCode}.',
      );
    }
    return body;
  }

  static Future<PrayerDay> prayers(LatLng point, DateTime day) async {
    final date = '${_two(day.day)}-${_two(day.month)}-${day.year}';
    final uri = Uri.https('api.aladhan.com', '/v1/timings/$date', {
      'latitude': point.latitude.toStringAsFixed(3),
      'longitude': point.longitude.toStringAsFixed(3),
      'method': '1',
      'school': '1', // Hanafi, consistent with your existing Home screen.
      'iso8601': 'true',
    });

    final body = await _json(uri, const Duration(days: 1));
    final data = body['data'];
    final result = <String, String>{};

    for (final name in const [
      'Fajr', 'Sunrise', 'Dhuhr', 'Asr', 'Maghrib', 'Isha',
    ]) {
      final value = data['timings'][name];
      if (value is! String || DateTime.tryParse(value) == null ||
          !RegExp(r'T\d{2}:\d{2}').hasMatch(value)) {
        throw GuideException('Invalid $name time received.');
      }
      result[name] = value;
    }

    final hijri = data['date']['hijri'];
    return PrayerDay(
      result,
      '${hijri['day']} ${hijri['month']['en']} ${hijri['year']}',
      '${data['meta']['timezone']}',
    );
  }

  // Preserve the location's clock time from the ISO string.
  static String clock(String iso) =>
      RegExp(r'T(\d{2}:\d{2})').firstMatch(iso)!.group(1)!;

  static Future<double> qibla(LatLng p) async {
    final lat = p.latitude.toStringAsFixed(3);
    final lng = p.longitude.toStringAsFixed(3);
    final uri = Uri.https('api.aladhan.com', '/v1/qibla/$lat/$lng');
    final body = await _json(uri, const Duration(days: 1));
    final angle = double.tryParse('${body['data']['direction']}');
    if (angle == null || !angle.isFinite) {
      throw const GuideException('Qibla direction is unavailable.');
    }
    return (angle % 360).toDouble();
  }
  static Future<List<Mosque>> nearby(LatLng user) async {
    final lat = user.latitude.toStringAsFixed(4);
    final lng = user.longitude.toStringAsFixed(4);

    final masjidiUri = Uri.parse(proxy).replace(
      queryParameters: {
        'action': 'nearby',
        'lat': lat,
        'lng': lng,
      },
    );

    String? masjidiError;

    try {
      final body = await _json(masjidiUri, const Duration(minutes: 5));
      final rows = body is Map ? body['data'] : body;

      if (rows is! List) {
        throw const GuideException('Unexpected Masjidi directory format.');
      }

      final mosques = <Mosque>[];
      for (final row in rows) {
        if (row is! Map) {
          throw const GuideException('Invalid record in Masjidi directory.');
        }

        mosques.add(
          Mosque.fromJson(Map<String, dynamic>.from(row), user),
        );
      }

      if (mosques.isNotEmpty) {
        _sortByDistance(mosques);
        debugPrint('[TravelGuide Nearby] Masjidi: ${mosques.length} results');
        return mosques;
      }
    } on GuideException catch (error) {
      masjidiError = error.message;
      debugPrint('[TravelGuide Nearby] Masjidi: $masjidiError');
    }

    // The same 5 km query that showed two results in Overpass Turbo.
    debugPrint('[TravelGuide Nearby] Trying OpenStreetMap within 5 km');

    try {
      final mosques = await _nearbyFromOsm(user, lat, lng);
      debugPrint('[TravelGuide Nearby] OpenStreetMap: ${mosques.length} results');

      if (mosques.isEmpty && masjidiError != null) {
        throw const GuideException(
          'OpenStreetMap found no mapped mosque within 5 km. '
              'Masjidi could not provide a directory for this location.',
        );
      }

      return mosques;
    } on GuideException {
      rethrow;
    } on FormatException {
      throw const GuideException('OpenStreetMap returned invalid data.');
    }
  }

  static void _sortByDistance(List<Mosque> mosques) {
    mosques.sort((a, b) {
      final distance = (a.distanceKm ?? double.infinity)
          .compareTo(b.distanceKm ?? double.infinity);
      return distance != 0 ? distance : a.name.compareTo(b.name);
    });
  }

  static Future<List<Mosque>> _nearbyFromOsm(
      LatLng user,
      String lat,
      String lng,
      ) async {
    final query = '''
[out:json][timeout:15];
(
  nwr(around:5000,$lat,$lng)["amenity"="place_of_worship"]["religion"="muslim"];
  nwr(around:5000,$lat,$lng)["building"="mosque"];
);
out center;
''';

    final uri = Uri.https(
      'overpass-api.de',
      '/api/interpreter',
      {'data': query},
    );

    final dynamic body;
    try {
      body = await _json(uri, const Duration(minutes: 10));
    } on GuideException catch (error) {
      throw GuideException('OpenStreetMap: ${error.message}');
    }

    if (body is! Map || body['elements'] is! List) {
      _cache.remove(uri);
      throw const GuideException('Unexpected OpenStreetMap response.');
    }

    // Overpass can return HTTP 200 with a timeout remark.
    if ('${body['remark'] ?? ''}'.trim().isNotEmpty) {
      _cache.remove(uri);
      throw const GuideException('OpenStreetMap could not finish. Please retry.');
    }

    final result = <Mosque>[];
    final seen = <String>{};

    for (final element in body['elements'] as List) {
      if (element is! Map) continue;

      final type = element['type'];
      final osmId = element['id'];
      if (osmId == null || !['node', 'way', 'relation'].contains(type)) {
        continue;
      }

      // Nodes have lat/lon directly. Ways and relations use center.
      final coords = type == 'node' ? element : element['center'];
      if (coords is! Map) continue;

      final latitude = double.tryParse('${coords['lat']}');
      final longitude = double.tryParse('${coords['lon']}');

      if (latitude == null || longitude == null ||
          !latitude.isFinite || !longitude.isFinite ||
          latitude.abs() > 90 || longitude.abs() > 180) {
        continue;
      }

      final id = 'osm:$type:$osmId';
      if (!seen.add(id)) continue;

      final tags = element['tags'] is Map ? element['tags'] as Map : const {};
      final names = [
        tags['name:bn'],
        tags['name'],
        tags['name:en'],
      ].whereType<String>().map((s) => s.trim()).where((s) => s.isNotEmpty);

      final address = [
        tags['addr:street'],
        tags['addr:village'],
        tags['addr:city'],
      ].whereType<String>().map((s) => s.trim()).where((s) => s.isNotEmpty);

      final distanceKm = Geolocator.distanceBetween(
        user.latitude,
        user.longitude,
        latitude,
        longitude,
      ) / 1000;

      result.add(Mosque(
        id: id,
        name: names.isEmpty ? 'স্থানীয় মসজিদ' : names.first,
        address: address.join(', '),
        point: LatLng(latitude, longitude),
        distanceKm: distanceKm,
      ));
    }

    _sortByDistance(result);
    return result;
  }

  static Future<Map<String, String>> jamaat(String id, DateTime day) async {
    final uri = Uri.parse(proxy).replace(queryParameters: {
      'action': 'times',
      'id': id,
      'date': dayKey(day),
    });
    final body = await _json(uri, const Duration(minutes: 5));
    dynamic row = body is Map && body.containsKey('data') ? body['data'] : body;
    if (row is List) row = row.isEmpty ? null : row.first;
    if (row == null || (row is Map && row.isEmpty)) return {};
    if (row is! Map) {
      throw const GuideException('Unexpected jamaat schedule format.');
    }

    // Reject dated records from another day.
    final dateField = row['date'];
    final rawDate = dateField is Map ? dateField['date'] : dateField;
    if (rawDate is String) {
      final received = RegExp(r'^\d{4}-\d{2}-\d{2}').stringMatch(rawDate);
      if (received != null && received != dayKey(day)) return {};
    }

    const keys = {
      'Fajr': ['fajr_iqama', 'fajr_iqama_time'],
      'Dhuhr': ['zuhr_iqama', 'zuhr_iqama_time'],
      'Asr': ['asr_iqama', 'asr_iqama_time'],
      'Maghrib': ['maghrib_iqama', 'magrib_iqama', 'maghrib_iqama_time'],
      'Isha': ['isha_iqama', 'isha_iqama_time'],
    };

    if (!keys.values.expand((fields) => fields).any(row.containsKey)) {
      throw const GuideException('Unrecognized daily schedule from Masjidi.');
    }

    final result = <String, String>{};
    for (final prayer in keys.entries) {
      for (final key in prayer.value) {
        final value = row[key];
        if (value is String &&
            RegExp(r'\d{1,2}:\d{2}').hasMatch(value) &&
            value.trim() != '00:00:00') {
          result[prayer.key] = value.trim();
          break;
        }
      }
    }
    return result;
  }
}