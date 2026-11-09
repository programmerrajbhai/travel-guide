import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/app_colors.dart';
import '../services/location_service.dart';
import '../services/nearby_mosque_service.dart';

class NearbyMosquesScreen extends StatelessWidget {
  final NearbyMosqueResult? initialData;
  final double? latitude;
  final double? longitude;

  const NearbyMosquesScreen({
    super.key,
    this.initialData,
    this.latitude,
    this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Nearby Masjids · 15 km'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: NearbyMosquesSection(
            preview: false,
            initialData: initialData,
            latitude: latitude,
            longitude: longitude,
          ),
        ),
      ),
    );
  }
}

class NearbyMosquesSection extends StatefulWidget {
  final bool preview;
  final bool forceRefresh;
  final double? latitude;
  final double? longitude;
  final NearbyMosqueResult? initialData;

  const NearbyMosquesSection({
    super.key,
    this.preview = true,
    this.forceRefresh = false,
    this.latitude,
    this.longitude,
    this.initialData,
  }) : assert((latitude == null) == (longitude == null));

  @override
  State<NearbyMosquesSection> createState() =>
      _NearbyMosquesSectionState();
}

class _NearbyMosquesSectionState
    extends State<NearbyMosquesSection> {
  NearbyMosqueResult? _data;
  StreamSubscription<NearbyMosqueResult>? _subscription;

  bool _loading = false;
  bool _openingMap = false;

  String? _error;
  double? _lat;
  double? _lng;

  @override
  void initState() {
    super.initState();
    _data = widget.initialData;
    _load(force: widget.forceRefresh);
  }

  Future<void> _load({
    bool force = false,
    bool newLocation = false,
  }) async {
    if (_loading) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    await _subscription?.cancel();

    try {
      var lat = newLocation ? null : widget.latitude;
      var lng = newLocation ? null : widget.longitude;

      if (lat == null || lng == null) {
        final position =
        await LocationService.getCurrentLocation().timeout(
          const Duration(seconds: 25),
        );

        if (position == null) {
          throw Exception(
            'Enable GPS and allow location access.',
          );
        }

        lat = position.latitude;
        lng = position.longitude;
      }

      if (!mounted) return;

      // অন্য এলাকায় গেলে পুরোনো এলাকার তালিকা দেখাবে না।
      if (_lat != null && (_lat != lat || _lng != lng)) {
        setState(() {
          _data = null;
        });
      }

      _lat = lat;
      _lng = lng;

      _subscription = NearbyMosqueService.instance
          .watch(lat, lng, force: force)
          .listen(
            (result) {
          if (!mounted) return;

          setState(() {
            _data = result;
            _loading = result.isRefreshing;
          });
        },
        onError: (Object error) {
          if (!mounted) return;

          setState(() {
            _error = error.toString();
            _loading = false;
          });
        },
        onDone: () {
          if (!mounted) return;

          setState(() {
            _loading = false;
          });
        },
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error = error
            .toString()
            .replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }

  Future<void> _open(
      Uri uri, {
        String errorMessage = 'Could not open the link.',
      }) async {
    // Installed app / external browser first.
    // If that fails, try the platform's default handler.
    for (final mode in [
      LaunchMode.externalApplication,
      LaunchMode.platformDefault,
    ]) {
      if (!mounted) return;

      try {
        final opened = await launchUrl(
          uri,
          mode: mode,
        );

        if (opened) return;
      } catch (_) {
        // Try the next launch mode.
      }
    }

    _showMessage(errorMessage);
  }

  Future<void> _directions(MosqueItem mosque) async {
    // Prevent multiple launches from rapid taps.
    if (_openingMap || !mounted) return;

    final lat = mosque.latitude;
    final lng = mosque.longitude;

    if (!lat.isFinite ||
        !lng.isFinite ||
        lat.abs() > 90 ||
        lng.abs() > 180) {
      _showMessage(
        'This mosque has invalid map coordinates.',
      );
      return;
    }

    _openingMap = true;

    try {
      final uri = Uri.https(
        'www.google.com',
        '/maps/dir/',
        {
          'api': '1',

          // Selected mosque's coordinates, not the user's.
          'destination': '$lat,$lng',

          'travelmode': 'driving',
          'dir_action': 'navigate',
        },
      );

      // Origin intentionally omitted:
      // Maps can use the device's current location.
      // No extra GPS/API request is needed before opening Maps.
      await _open(
        uri,
        errorMessage:
        'Could not open directions. '
            'Please check your Maps app or browser.',
      );
    } finally {
      _openingMap = false;
    }
  }

  void _viewAll() {
    final data = _data;
    if (data == null) return;

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => NearbyMosquesScreen(
          initialData: data,
          latitude: _lat,
          longitude: _lng,
        ),
      ),
    );
  }

  Widget _card(MosqueItem mosque) {
    return Container(
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
          // Entire card opens directions.
          onTap: () => _directions(mosque),
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
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
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
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            color: AppColors.primaryColor,
                            size: 15,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${mosque.distanceKm.toStringAsFixed(2)} km away',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textLight,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.grey.shade200,
                    ),
                  ),
                  child: IconButton(
                    // Arrow opens the same destination.
                    onPressed: () => _directions(mosque),
                    tooltip: 'Directions to ${mosque.name}',
                    icon: const Icon(
                      Icons.near_me_outlined,
                      size: 18,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;

    return Column(
      mainAxisSize: widget.preview
          ? MainAxisSize.min
          : MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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

            if (widget.preview)
              InkWell(
                onTap: data == null ? null : _viewAll,
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
              )
            else
              IconButton(
                onPressed: _loading
                    ? null
                    : () => _load(
                  force: true,
                  newLocation: true,
                ),
                tooltip: 'Refresh',
                icon: const Icon(Icons.refresh),
              ),
          ],
        ),

        const SizedBox(height: 12),

        if (_loading && data == null)
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
          ),

        if (_error != null) ...[
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          TextButton(
            onPressed: _loading
                ? null
                : () => _load(
              force: true,
              newLocation: true,
            ),
            child: const Text('Retry'),
          ),
        ],

        if (data != null) ...[
          Text(
            '${data.mosques.length} found within 15 km',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textLight,
            ),
          ),

          if (_loading)
            const Text(
              'Updating nearby mosques…',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textLight,
              ),
            ),

          if (data.isStale)
            Text(
              'Saved list · '
                  '${data.updatedAt?.toLocal().toString().split('.').first ?? ''}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textLight,
              ),
            ),

          for (final warning in data.warnings)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                warning,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.orange,
                ),
              ),
            ),

          const SizedBox(height: 12),

          if (data.mosques.isEmpty && !_loading)
            const Padding(
              padding: EdgeInsets.all(14),
              child: Text(
                'No mapped mosques returned within 15 km.',
                textAlign: TextAlign.center,
              ),
            ),

          if (widget.preview)
            ...data.mosques.take(2).map(_card)
          else
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _load(
                  force: true,
                  newLocation: true,
                ),
                child: ListView.builder(
                  physics:
                  const AlwaysScrollableScrollPhysics(),
                  itemCount: data.mosques.length,
                  itemBuilder: (_, index) {
                    return _card(data.mosques[index]);
                  },
                ),
              ),
            ),

          TextButton(
            onPressed: () => _open(
              Uri.parse(
                'https://www.openstreetmap.org/copyright',
              ),
            ),
            child: const Text(
              '© OpenStreetMap contributors · ODbL',
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textLight,
              ),
            ),
          ),
        ],
      ],
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}