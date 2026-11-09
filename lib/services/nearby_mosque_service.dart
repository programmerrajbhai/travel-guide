import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
  final String key, name, address;
  final String? masjidiId;
  final double latitude, longitude, distanceKm;
  final Set<String> names, sources;

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
  final bool isRefreshing, isStale;
  final DateTime? updatedAt;

  const NearbyMosqueResult(
      this.mosques,
      this.warnings, {
        this.isRefreshing = false,
        this.isStale = false,
        this.updatedAt,
      });
}

typedef _Source = ({
List<MosqueItem> items,
String? warning,
bool failed,
});

class _SavedSource {
  // null = never loaded successfully; [] = valid empty result.
  final List<MosqueItem>? items;
  final DateTime? savedAt;
  final DateTime triedAt, nextTry;
  final String? error;
  final bool partial;

  const _SavedSource({
    this.items,
    this.savedAt,
    required this.triedAt,
    required this.nextTry,
    this.error,
    this.partial = false,
  });
}

class NearbyMosqueService {
  static final instance = NearbyMosqueService();

  // Mac-এর Wi-Fi IP পরিবর্তন হলে শুধু এই URL পরিবর্তন করবে।
  static const proxy =
      'http://192.168.1.102/travel_admin/masjidi.php';

  static const radiusKm = 15.0;
  static const _diskKey = 'travel_guide_mosques_v3';
  static const _sources = ['Masjidi', 'OpenStreetMap'];
  static const _maxAge = Duration(hours: 24);

  final http.Client? _client;
  final Future<String?> Function() _readDisk;
  final Future<void> Function(String) _writeDisk;

  final _cache = <String, Map<String, _SavedSource>>{};
  final _jobs = <String, Future<_SavedSource>>{};
  final _blockedUntil = <String, DateTime>{};

  Future<void>? _loaded;
  Future<void> _writing = Future.value();

  NearbyMosqueService({
    http.Client? client,
    Future<String?> Function()? readCache,
    Future<void> Function(String)? writeCache,
  }) : _client = client,
        _readDisk = readCache ??
            (() => SharedPreferencesAsync().getString(_diskKey)),
        _writeDisk = writeCache ??
            ((value) =>
                SharedPreferencesAsync().setString(_diskKey, value));

  // Compatibility for older callers.
  Future<NearbyMosqueResult> fetch(double lat, double lng) {
    return watch(lat, lng).last;
  }

  // Cached data first; then publish each provider's result separately.
  Stream<NearbyMosqueResult> watch(
      double lat,
      double lng, {
        bool force = false,
      }) async* {
    if (!_valid(lat, lng)) {
      throw const NearbyMosqueException('Invalid GPS coordinates.');
    }

    await (_loaded ??= _loadDisk());

    final a = lat.toStringAsFixed(3);
    final b = lng.toStringAsFixed(3);
    final key = '$a,$b';
    final now = DateTime.now();

    final saved =
    Map<String, _SavedSource>.from(_cache[key] ?? {});

    saved.removeWhere(
          (_, item) =>
      item.savedAt != null &&
          now.difference(item.savedAt!) > _maxAge,
    );

    final needed = _sources.where((source) {
      final slot = saved[source];

      return slot == null ||
          !now.isBefore(slot.nextTry) ||
          (force &&
              slot.error == null &&
              now.difference(slot.triedAt) >=
                  const Duration(seconds: 30));
    }).toList();

    if (saved.values.any((item) => item.items != null)) {
      yield _result(saved, lat, lng, needed.isNotEmpty);
    }

    if (needed.isEmpty) {
      if (!saved.values.any((item) => item.items != null)) {
        throw NearbyMosqueException(
          saved.values
              .map((v) => v.error)
              .whereType<String>()
              .join('\n'),
        );
      }
      return;
    }

    final controller = StreamController<NearbyMosqueResult>();
    var remaining = needed.length;

    void publish() {
      if (controller.isClosed) return;

      if (saved.values.any((item) => item.items != null)) {
        controller.add(_result(saved, lat, lng, remaining > 0));
      } else if (remaining == 0) {
        controller.addError(
          NearbyMosqueException(
            saved.values
                .map((v) => v.error)
                .whereType<String>()
                .join('\n'),
          ),
        );
      }

      if (remaining == 0) {
        unawaited(controller.close());
      }
    }

    for (final source in needed) {
      _sourceJob(key, source, a, b).then((slot) {
        saved[source] = slot;
        remaining--;
        publish();
      });
    }

    try {
      yield* controller.stream;
    } finally {
      // Screen বন্ধ হলেও shared request cache update করতে পারবে।
      if (!controller.isClosed) {
        unawaited(controller.close());
      }
    }
  }

  Future<_SavedSource> _sourceJob(
      String key,
      String source,
      String lat,
      String lng,
      ) {
    final jobKey = '$key|$source';
    final existing = _jobs[jobKey];
    if (existing != null) return existing;

    late final Future<_SavedSource> job;

    job = (() async {
      final answer = await _safe(
        source,
            () => source == 'Masjidi'
            ? _masjidi(lat, lng)
            : _osm(lat, lng),
      );

      final now = DateTime.now();
      final previous = _cache[key]?[source];
      final usable = previous?.savedAt != null &&
          now.difference(previous!.savedAt!) <= _maxAge;

      // Success: 10 minutes.
      // Partial response: 1 minute.
      // Failure: 2 minutes before trying again.
      var nextTry = now.add(
        Duration(
          seconds: answer.failed
              ? 120
              : answer.warning != null
              ? 60
              : 600,
        ),
      );

      final hosts = source == 'Masjidi'
          ? [Uri.parse(proxy).host]
          : ['overpass-api.de', 'overpass.private.coffee'];

      for (final host in hosts) {
        final blocked = _blockedUntil[host];
        if (blocked != null && blocked.isAfter(nextTry)) {
          nextTry = blocked;
        }
      }

      final slot = _SavedSource(
        items: answer.failed
            ? (usable ? previous.items : null)
            : answer.items,
        savedAt: answer.failed
            ? (usable ? previous.savedAt : null)
            : now,
        triedAt: now,
        nextTry: nextTry,
        error: answer.failed ? answer.warning : null,
        partial: answer.failed
            ? (usable && previous.partial)
            : answer.warning != null,
      );

      (_cache[key] ??= {})[source] = slot;

      // Keep the latest 10 searched areas.
      while (_cache.length > 10) {
        _cache.remove(_cache.keys.first);
      }

      _queueSave();
      return slot;
    })().whenComplete(() {
      if (identical(_jobs[jobKey], job)) {
        _jobs.remove(jobKey);
      }
    });

    _jobs[jobKey] = job;
    return job;
  }

  NearbyMosqueResult _result(
      Map<String, _SavedSource> saved,
      double lat,
      double lng,
      bool refreshing,
      ) {
    final merged = <MosqueItem>[];
    final notes = <String>[];
    DateTime? oldest;
    var stale = false;

    for (final source in _sources) {
      final slot = saved[source];
      if (slot == null) continue;

      if (slot.error != null) {
        notes.add(
          '$source unavailable. Showing available results.',
        );
      }

      if (slot.items == null) continue;

      if (slot.partial) {
        notes.add('$source returned an incomplete list.');
      }

      final date = slot.savedAt!;

      if (oldest == null || date.isBefore(oldest)) {
        oldest = date;
      }

      if (DateTime.now().difference(date) >=
          const Duration(minutes: 10)) {
        stale = true;
      }

      for (final item in slot.items!) {
        final km = distance(
          lat, lng, item.latitude, item.longitude,
        );

        if (km > radiusKm) continue;

        final candidate = item.copy(distanceKm: km);
        final index =
        merged.indexWhere((old) => _same(old, candidate));

        if (index < 0) {
          merged.add(candidate);
        } else {
          merged[index] = merged[index].copy(
            names: {
              ...merged[index].names,
              ...candidate.names,
            },
            sources: {
              ...merged[index].sources,
              ...candidate.sources,
            },
          );
        }
      }
    }

    merged.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

    return NearbyMosqueResult(
      List.unmodifiable(merged),
      notes,
      isRefreshing: refreshing,
      isStale: stale,
      updatedAt: oldest,
    );
  }

  Future<void> _loadDisk() async {
    try {
      final text =
      await _readDisk().timeout(const Duration(seconds: 2));

      if (text == null) return;

      final decoded = jsonDecode(text);
      if (decoded is! Map) return;

      for (final cell in decoded.entries.take(10)) {
        try {
          final slots = <String, _SavedSource>{};

          for (final source in _sources) {
            final row = cell.value[source];
            if (row is! Map) continue;

            final date =
            DateTime.tryParse('${row['savedAt']}');

            if (date != null &&
                (date.isAfter(DateTime.now()) ||
                    DateTime.now().difference(date) > _maxAge)) {
              continue;
            }

            final items = row['items'] is List
                ? (row['items'] as List).map((m) {
              final lat = (m['lat'] as num).toDouble();
              final lng = (m['lng'] as num).toDouble();

              if (!_valid(lat, lng)) {
                throw const FormatException(
                  'Cache coordinates',
                );
              }

              return MosqueItem(
                key: m['key'],
                name: m['name'],
                address: m['address'],
                masjidiId: m['masjidiId'],
                latitude: lat,
                longitude: lng,
                names: Set<String>.from(m['names']),
                sources: Set<String>.from(m['sources']),
              );
            }).toList()
                : null;

            if (items != null && date == null) continue;

            slots[source] = _SavedSource(
              items: items,
              savedAt: date,
              triedAt: DateTime.parse(row['triedAt']),
              nextTry: DateTime.parse(row['nextTry']),
              error: row['error'],
              partial: row['partial'] == true,
            );
          }

          _cache[cell.key.toString()] = slots;
        } catch (_) {
          // Skip damaged cache cells.
        }
      }
    } catch (_) {
      // Storage failure must not block network loading.
    }
  }

  void _queueSave() {
    _writing = _writing.then((_) async {
      final document = _cache.map(
            (key, sources) => MapEntry(
          key,
          sources.map(
                (source, slot) => MapEntry(source, {
              'savedAt': slot.savedAt?.toIso8601String(),
              'triedAt': slot.triedAt.toIso8601String(),
              'nextTry': slot.nextTry.toIso8601String(),
              'error': slot.error,
              'partial': slot.partial,
              'items': slot.items?.map((m) => {
                'key': m.key,
                'name': m.name,
                'address': m.address,
                'masjidiId': m.masjidiId,
                'lat': m.latitude,
                'lng': m.longitude,
                'names': m.names.toList(),
                'sources': m.sources.toList(),
              }).toList(),
            }),
          ),
        ),
      );

      final encoded = jsonEncode(document);
      if (encoded.length <= 2000000) {
        await _writeDisk(encoded);
      }
    }).catchError((Object error) {
      print('[Nearby cache] Save unavailable: $error');
    });
  }

  Future<void> flushCache() => _writing;

  Future<_Source> _safe(
      String source,
      Future<_Source> Function() load,
      ) async {
    try {
      final result = await load();

      print(
        '[TravelGuide Nearby v3] '
            '$source: ${result.items.length} records',
      );

      return result;
    } catch (error) {
      final reason =
      error.toString().replaceFirst('Exception: ', '');
      final message = '$source: $reason';

      print('[TravelGuide Nearby v3] $message');

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

    if (blocked != null && DateTime.now().isBefore(blocked)) {
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
      '[TravelGuide Nearby v3] '
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
        '[TravelGuide Nearby v3] ${uri.host}: '
            'HTTP ${response.statusCode}, '
            '${response.bodyBytes.length} bytes, '
            '${watch.elapsedMilliseconds} ms',
      );

      if (response.statusCode == 429 ||
          response.statusCode == 406) {
        final requested =
            int.tryParse(response.headers['retry-after'] ?? '') ??
                60;
        final seconds = math.max(30, requested);

        _blockedUntil[uri.host] = DateTime.now().add(
          Duration(seconds: seconds),
        );

        throw NearbyMosqueException(
          'HTTP ${response.statusCode}: '
              'server busy. Retry after $seconds seconds.',
        );
      }

      if (allowNoContent && response.statusCode == 204) {
        return <dynamic>[];
      }

      final body = utf8
          .decode(response.bodyBytes, allowMalformed: true)
          .replaceFirst(RegExp(r'^\uFEFF'), '')
          .trim();

      dynamic decoded;

      if (body.isNotEmpty) {
        try {
          decoded = jsonDecode(body);
        } catch (_) {}
      }

      if (response.statusCode != 200) {
        final detail = decoded is Map &&
            decoded['error'] is String
            ? ': ${(decoded['error'] as String).substring(
          0,
          math.min(
            180,
            (decoded['error'] as String).length,
          ),
        )}'
            : '';

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
      final short =
      message.substring(0, math.min(180, message.length));

      throw NearbyMosqueException(
        'Connection failed: $short',
        allowFallback: true,
      );
    } finally {
      if (_client == null) client.close();
    }
  }

  Future<_Source> _masjidi(String lat, String lng) async {
    dynamic data = await _request(
      Uri.parse(proxy).replace(
        queryParameters: {
          'action': 'nearby',
          'lat': lat,
          'lng': lng,
        },
      ),
      allowNoContent: true,
    );

    if (data is Map && data['error'] != null) {
      throw Exception('Masjidi error');
    }

    if (data is Map) data = data['data'];
    if (data is! List) throw Exception('Invalid Masjidi list');

    final items = <MosqueItem>[];

    for (final row in data) {
      if (row is! Map) continue;

      final id = '${row['masjid_id'] ?? ''}';
      final latitude =
      double.tryParse('${row['latitude']}');
      final longitude =
      double.tryParse('${row['longitude']}');

      if ((int.tryParse(id) ?? 0) < 1 ||
          !_valid(latitude, longitude)) {
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
              .where((s) => s.trim().isNotEmpty)
              .join(', '),
          latitude: latitude!,
          longitude: longitude!,
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

  Future<_Source> _osm(String lat, String lng) async {
    // 100 m buffer for rounded search coordinates.
    // Final results are filtered against the actual GPS at 15 km.
    final query = '''
[out:json][timeout:25];
(
  nwr(around:15100,$lat,$lng)["amenity"="place_of_worship"]["religion"="muslim"];
  nwr(around:15100,$lat,$lng)["building"="mosque"];
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
        '[TravelGuide Nearby v3] '
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

      final tags =
      row['tags'] is Map ? row['tags'] as Map : <String, dynamic>{};

      final center =
      row['center'] is Map ? row['center'] as Map : row;

      final latitude = double.tryParse('${center['lat']}');
      final longitude = double.tryParse('${center['lon']}');

      if (!_valid(latitude, longitude) ||
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
          .where((s) => s.trim().isNotEmpty)
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
              .where((s) => s.trim().isNotEmpty)
              .join(', '),
          latitude: latitude!,
          longitude: longitude!,
          names: names.map(_normalize).toSet(),
          sources: {'OpenStreetMap'},
        ),
      );
    }

    return (
    items: items,
    warning: hasRemark
        ? 'OpenStreetMap returned a partial result.'
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

    const generic = {
      'mosque',
      'masjid',
      'মসজিদ',
      'জামে মসজিদ',
      'unnamed mosque',
    };

    final common =
    a.names.intersection(b.names).difference(generic);

    return common.isNotEmpty &&
        distance(
          a.latitude,
          a.longitude,
          b.latitude,
          b.longitude,
        ) <= 0.06;
  }

  // Straight-line kilometres.
  static double distance(double a, double b, double c, double d) {
    const r = math.pi / 180;

    final h = math.pow(math.sin((c - a) * r / 2), 2) +
        math.cos(a * r) *
            math.cos(c * r) *
            math.pow(math.sin((d - b) * r / 2), 2);

    return 6371.0088 *
        2 *
        math.asin(math.sqrt(h.clamp(0.0, 1.0)));
  }
}