import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:http/http.dart' as http;

class NearbyMosqueException implements Exception {
  final String message;
  final bool allowFallback;

  const NearbyMosqueException(
      this.message, {
        this.allowFallback = false,
      });

  @override
  String toString() => message;
}

class MosqueItem {
  final String key;
  final String name;
  final String address;
  final String? masjidiId;

  final double latitude;
  final double longitude;
  final double distanceKm;

  final Set<String> names;
  final Set<String> sources;

  const MosqueItem({
    required this.key,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.names,
    required this.sources,
    this.masjidiId,
    this.distanceKm = 0,
  });

  MosqueItem copy({
    double? distanceKm,
    Set<String>? sources,
    Set<String>? names,
  }) {
    return MosqueItem(
      key: key,
      name: name,
      address: address,
      masjidiId: masjidiId,
      latitude: latitude,
      longitude: longitude,
      names: names ?? this.names,
      sources: sources ?? this.sources,
      distanceKm: distanceKm ?? this.distanceKm,
    );
  }
}

class NearbyMosqueResult {
  final List<MosqueItem> mosques;
  final List<String> warnings;

  const NearbyMosqueResult(
      this.mosques,
      this.warnings,
      );
}

typedef _Source = ({
List<MosqueItem> items,
String? warning,
bool failed,
});

class NearbyMosqueService {
  static final instance = NearbyMosqueService();

  // Mac-এর Wi-Fi IP পরিবর্তন হলে এখানে পরিবর্তন করবে।
  static const proxy =
      'http://192.168.1.102/travel_admin/masjidi.php';

  static const radiusKm = 15.0;

  final http.Client? _client;

  final _blockedUntil = <String, DateTime>{};

  final _cache =
  <String, ({DateTime until, List<_Source> data})>{};

  final _pending = <String, Future<List<_Source>>>{};

  NearbyMosqueService({http.Client? client})
      : _client = client;

  Future<NearbyMosqueResult> fetch(
      double latitude,
      double longitude,
      ) async {
    if (!_valid(latitude, longitude)) {
      throw const NearbyMosqueException(
        'Invalid GPS coordinates.',
      );
    }

    print(
      '[TravelGuide Nearby v2] Search 15 km '
          'from $latitude,$longitude',
    );

    // ছোট GPS পরিবর্তনে একই এলাকার request share করা হয়।
    final lat = latitude.toStringAsFixed(3);
    final lng = longitude.toStringAsFixed(3);
    final cacheKey = '$lat,$lng';

    final cached = _cache[cacheKey];
    late List<_Source> results;

    if (cached != null &&
        DateTime.now().isBefore(cached.until)) {
      results = cached.data;
    } else {
      final request = _pending.putIfAbsent(
        cacheKey,
            () => Future.wait([
          _safe(
            'Masjidi',
                () => _masjidi(lat, lng),
          ),
          _safe(
            'OpenStreetMap',
                () => _osm(lat, lng),
          ),
        ]),
      );

      try {
        results = await request;

        if (_cache.length >= 20) {
          _cache.remove(_cache.keys.first);
        }

        final partial =
        results.any((result) => result.warning != null);

        // দুই API-ই ব্যর্থ হলে সেই failure cache করব না।
        if (results.any((result) => !result.failed)) {
          _cache[cacheKey] = (
          until: DateTime.now().add(
            Duration(seconds: partial ? 30 : 600),
          ),
          data: results,
          );
        }
      } finally {
        if (identical(_pending[cacheKey], request)) {
          _pending.remove(cacheKey);
        }
      }
    }

    if (results.every((result) => result.failed)) {
      throw NearbyMosqueException(
        results
            .map((result) => result.warning)
            .whereType<String>()
            .join('\n\n'),
      );
    }

    final merged = <MosqueItem>[];

    for (final source in results) {
      for (final item in source.items) {
        // Distance সবসময় বর্তমান GPS থেকে হিসাব হবে।
        final km = distance(
          latitude,
          longitude,
          item.latitude,
          item.longitude,
        );

        if (km > radiusKm) continue;

        final candidate = item.copy(distanceKm: km);

        final index = merged.indexWhere(
              (existing) => _same(existing, candidate),
        );

        if (index < 0) {
          merged.add(candidate);
        } else {
          final existing = merged[index];

          merged[index] = existing.copy(
            sources: {
              ...existing.sources,
              ...candidate.sources,
            },
            names: {
              ...existing.names,
              ...candidate.names,
            },
          );
        }
      }
    }

    merged.sort(
          (a, b) => a.distanceKm.compareTo(b.distanceKm),
    );

    print(
      '[TravelGuide Nearby v2] '
          '${merged.length} results within 15 km',
    );

    return NearbyMosqueResult(
      List.unmodifiable(merged),
      [
        for (final result in results)
          if (result.warning != null) result.warning!,
      ],
    );
  }

  Future<_Source> _safe(
      String source,
      Future<_Source> Function() load,
      ) async {
    try {
      final result = await load();

      print(
        '[TravelGuide Nearby v2] '
            '$source: ${result.items.length} records',
      );

      return result;
    } catch (error) {
      final reason = error
          .toString()
          .replaceFirst('Exception: ', '');

      final message = '$source: $reason';

      print('[TravelGuide Nearby v2] $message');

      return (
      items: <MosqueItem>[],
      warning: message,
      failed: true,
      );
    }
  }

  Future<dynamic> _request(
      Uri uri, {
        String? query,
        Duration timeout = const Duration(seconds: 22),
        bool allowNoContent = false,
      }) async {
    final blocked = _blockedUntil[uri.host];

    if (blocked != null &&
        DateTime.now().isBefore(blocked)) {
      final seconds =
          blocked.difference(DateTime.now()).inSeconds + 1;

      throw NearbyMosqueException(
        'Server busy. Retry in $seconds seconds.',
      );
    }

    final client = _client ?? http.Client();
    final watch = Stopwatch()..start();
    final method = query == null ? 'GET' : 'POST';

    print(
      '[TravelGuide Nearby v2] '
          '$method ${uri.host}${uri.path}',
    );

    try {
      final headers = {
        'Accept': 'application/json',
        'User-Agent':
        'TravelGuide/1.0 '
            '(+https://github.com/programmerrajbhai/travel-guide)',
      };

      final response = await (
          query == null
              ? client.get(uri, headers: headers)
              : client.post(
            uri,
            headers: headers,
            body: {'data': query},
          )
      ).timeout(timeout);

      print(
        '[TravelGuide Nearby v2] '
            '${uri.host}: HTTP ${response.statusCode}, '
            '${response.bodyBytes.length} bytes, '
            '${watch.elapsedMilliseconds} ms',
      );

      // Busy/rate-limited server-এ সঙ্গে সঙ্গে retry নয়।
      if (response.statusCode == 429 ||
          response.statusCode == 406) {
        final requested = int.tryParse(
          response.headers['retry-after'] ?? '',
        ) ??
            60;

        final seconds = math.max(30, requested);

        _blockedUntil[uri.host] = DateTime.now().add(
          Duration(seconds: seconds),
        );

        throw NearbyMosqueException(
          'HTTP ${response.statusCode}: server busy. '
              'Retry after $seconds seconds.',
        );
      }

      if (allowNoContent && response.statusCode == 204) {
        return <dynamic>[];
      }

      final body = utf8
          .decode(
        response.bodyBytes,
        allowMalformed: true,
      )
          .replaceFirst(RegExp(r'^\uFEFF'), '')
          .trim();

      dynamic decoded;

      if (body.isNotEmpty) {
        try {
          decoded = jsonDecode(body);
        } catch (_) {
          // নিচে পরিষ্কার JSON error দেখানো হবে।
        }
      }

      if (response.statusCode != 200) {
        String detail = '';

        if (decoded is Map && decoded['error'] is String) {
          final message = decoded['error'] as String;

          detail = ': ${message.substring(
            0,
            math.min(180, message.length),
          )}';
        }

        throw NearbyMosqueException(
          'HTTP ${response.statusCode}$detail',
          allowFallback: response.statusCode >= 500,
        );
      }

      if (body.isEmpty) {
        throw const NearbyMosqueException(
          'HTTP 200 with an empty body.',
          allowFallback: true,
        );
      }

      if (decoded == null) {
        throw const NearbyMosqueException(
          'Response is not valid JSON.',
          allowFallback: true,
        );
      }

      return decoded;
    } on TimeoutException {
      throw NearbyMosqueException(
        'Request timed out after '
            '${timeout.inSeconds}s (${uri.host}).',
        allowFallback: true,
      );
    } on http.ClientException catch (error) {
      final message = error.message;
      final short = message.substring(
        0,
        math.min(180, message.length),
      );

      throw NearbyMosqueException(
        'Connection failed: $short',
        allowFallback: true,
      );
    } finally {
      // Timeout হলেও নিজস্ব client-এর connection বন্ধ হবে।
      if (_client == null) {
        client.close();
      }
    }
  }

  Future<_Source> _masjidi(
      String latitude,
      String longitude,
      ) async {
    dynamic data = await _request(
      Uri.parse(proxy).replace(
        queryParameters: {
          'action': 'nearby',
          'lat': latitude,
          'lng': longitude,
        },
      ),
      allowNoContent: true,
    );

    if (data is Map && data['error'] != null) {
      throw Exception('Masjidi error');
    }

    if (data is Map) {
      data = data['data'];
    }

    if (data is! List) {
      throw Exception('Invalid Masjidi list');
    }

    final items = <MosqueItem>[];

    for (final row in data) {
      if (row is! Map) continue;

      final id = '${row['masjid_id'] ?? ''}';
      final lat = double.tryParse('${row['latitude']}');
      final lng = double.tryParse('${row['longitude']}');

      if ((int.tryParse(id) ?? 0) < 1 ||
          !_valid(lat, lng)) {
        continue;
      }

      final name = '${row['title'] ?? ''}'.trim();

      items.add(
        MosqueItem(
          key: 'masjidi:$id',
          masjidiId: id,
          name: name.isEmpty ? 'Unnamed mosque' : name,
          address: [
            row['address'],
            row['city'],
          ]
              .whereType<String>()
              .where((value) => value.trim().isNotEmpty)
              .join(', '),
          latitude: lat!,
          longitude: lng!,
          names: {_normalize(name)}..remove(''),
          sources: {'Masjidi'},
        ),
      );
    }

    return (
    items: items,
    warning: items.length < data.length
        ? 'Some Masjidi records have invalid coordinates or IDs.'
        : null,
    failed: false,
    );
  }

  Future<_Source> _osm(
      String latitude,
      String longitude,
      ) async {
    // Rounded query center-এর জন্য 100 m buffer।
    // Final result actual GPS থেকে 15 km-এর মধ্যে থাকবে।
    final query = '''
[out:json][timeout:25];
(
  nwr(around:15100,$latitude,$longitude)
    ["amenity"="place_of_worship"]["religion"="muslim"];
  nwr(around:15100,$latitude,$longitude)
    ["building"="mosque"];
);
out center;
''';

    dynamic data;

    try {
      data = await _request(
        Uri.https(
          'overpass-api.de',
          '/api/interpreter',
          {'data': query},
        ),
        timeout: const Duration(seconds: 90),
      );
    } on NearbyMosqueException catch (first) {
      if (!first.allowFallback) rethrow;

      print(
        '[TravelGuide Nearby v2] '
            'Trying alternate OSM server: $first',
      );

      try {
        data = await _request(
          Uri.parse(
            'https://overpass.private.coffee/api/interpreter',
          ),
          query: query,
          timeout: const Duration(seconds: 60),
        );
      } catch (second) {
        throw NearbyMosqueException(
          'Primary: $first\nAlternate: $second',
        );
      }
    }

    if (data is! Map || data['elements'] is! List) {
      throw const NearbyMosqueException(
        'Unexpected OpenStreetMap JSON structure.',
      );
    }

    final hasRemark = data['remark'] != null;
    final rows = data['elements'] as List;

    if (hasRemark && rows.isEmpty) {
      throw const NearbyMosqueException(
        'OSM query did not complete. Retry later.',
      );
    }

    final items = <MosqueItem>[];
    var invalid = 0;

    for (final row in rows) {
      if (row is! Map) {
        invalid++;
        continue;
      }

      final tags = row['tags'] is Map
          ? row['tags'] as Map
          : <String, dynamic>{};

      final center = row['center'] is Map
          ? row['center'] as Map
          : row;

      final lat = double.tryParse('${center['lat']}');
      final lng = double.tryParse('${center['lon']}');

      if (!_valid(lat, lng) ||
          row['id'] == null ||
          row['type'] == null) {
        invalid++;
        continue;
      }

      if (tags['disused'] == 'yes' ||
          tags['abandoned'] == 'yes' ||
          tags.containsKey('disused:amenity') ||
          tags.containsKey('abandoned:amenity') ||
          (tags['religion'] != null &&
              tags['religion'] != 'muslim') ||
          (tags['amenity'] != null &&
              tags['amenity'] != 'place_of_worship')) {
        continue;
      }

      final names = [
        tags['name:bn'],
        tags['name'],
        tags['name:en'],
      ]
          .whereType<String>()
          .where((value) => value.trim().isNotEmpty)
          .toList();

      items.add(
        MosqueItem(
          key: 'osm:${row['type']}:${row['id']}',
          name: names.isEmpty ? 'Unnamed mosque' : names.first,
          address: [
            tags['addr:street'],
            tags['addr:city'],
          ]
              .whereType<String>()
              .where((value) => value.trim().isNotEmpty)
              .join(', '),
          latitude: lat!,
          longitude: lng!,
          names: names.map(_normalize).toSet(),
          sources: {'OpenStreetMap'},
        ),
      );
    }

    return (
    items: items,
    warning: hasRemark
        ? 'OpenStreetMap returned a partial result. '
        'Retry later for the full list.'
        : invalid > 0
        ? 'Some OpenStreetMap records have missing coordinates.'
        : null,
    failed: false,
    );
  }

  static bool _valid(double? lat, double? lng) {
    return lat != null &&
        lng != null &&
        lat.isFinite &&
        lng.isFinite &&
        lat.abs() <= 90 &&
        lng.abs() <= 180;
  }

  static String _normalize(String name) {
    return name
        .toLowerCase()
        .replaceAll(RegExp(r'[\s\-.,\u0027’]+'), ' ')
        .trim();
  }

  static bool _same(MosqueItem a, MosqueItem b) {
    if (a.key == b.key) return true;

    if (a.masjidiId != null && b.masjidiId != null) {
      return false;
    }

    const genericNames = {
      'mosque',
      'masjid',
      'মসজিদ',
      'জামে মসজিদ',
      'unnamed mosque',
    };

    final commonNames =
    a.names.intersection(b.names).difference(genericNames);

    return commonNames.isNotEmpty &&
        distance(
          a.latitude,
          a.longitude,
          b.latitude,
          b.longitude,
        ) <=
            0.06;
  }

  // Straight-line distance in kilometres.
  static double distance(
      double latitude1,
      double longitude1,
      double latitude2,
      double longitude2,
      ) {
    const radians = math.pi / 180;

    final h = math.pow(
      math.sin((latitude2 - latitude1) * radians / 2),
      2,
    ) +
        math.cos(latitude1 * radians) *
            math.cos(latitude2 * radians) *
            math.pow(
              math.sin(
                (longitude2 - longitude1) * radians / 2,
              ),
              2,
            );

    return 6371.0088 *
        2 *
        math.asin(
          math.sqrt(h.clamp(0.0, 1.0)),
        );
  }
}