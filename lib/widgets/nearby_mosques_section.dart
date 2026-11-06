import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/app_colors.dart';
import '../services/location_service.dart';
import '../services/nearby_mosque_service.dart';

class NearbyMosquesScreen extends StatelessWidget {
  final NearbyMosqueResult? initialData;

  const NearbyMosquesScreen({
    super.key,
    this.initialData,
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
          ),
        ),
      ),
    );
  }
}

class NearbyMosquesSection extends StatefulWidget {
  final bool preview;
  final NearbyMosqueResult? initialData;

  const NearbyMosquesSection({
    super.key,
    this.preview = true,
    this.initialData,
  });

  @override
  State<NearbyMosquesSection> createState() {
    return _NearbyMosquesSectionState();
  }
}

class _NearbyMosquesSectionState
    extends State<NearbyMosquesSection> {
  NearbyMosqueResult? _data;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();

    _data = widget.initialData;

    if (_data == null) {
      _load();
    }
  }

  Future<void> _load() async {
    if (_loading) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final position =
      await LocationService.getCurrentLocation().timeout(
        const Duration(seconds: 30),
      );

      if (position == null) {
        throw Exception(
          'Enable GPS and allow location access, then retry.',
        );
      }

      final result =
      await NearbyMosqueService.instance.fetch(
        position.latitude,
        position.longitude,
      );

      if (!mounted) return;

      setState(() {
        _data = result;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error = error
            .toString()
            .replaceFirst('Exception: ', '');
        _data = null;
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _open(Uri uri) async {
    try {
      final opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (opened) return;
    } catch (_) {}

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Could not open the link.'),
      ),
    );
  }

  void _directions(MosqueItem mosque) {
    _open(
      Uri.https(
        'www.google.com',
        '/maps/dir/',
        {
          'api': '1',
          'destination':
          '${mosque.latitude},${mosque.longitude}',
        },
      ),
    );
  }

  void _details(MosqueItem mosque) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              24,
              0,
              24,
              24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  mosque.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                if (mosque.address.isNotEmpty)
                  Text(mosque.address),
                Text(
                  '${mosque.distanceKm.toStringAsFixed(2)} km'
                      ' · straight-line distance',
                ),
                const SizedBox(height: 8),
                Text(
                  'Source: ${mosque.sources.join(' + ')}',
                ),
                const SizedBox(height: 12),
                const Text(
                  'Jamaat times are not provided by this nearby search.',
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => _directions(mosque),
                  icon: const Icon(Icons.directions),
                  label: const Text('Directions'),
                ),
              ],
            ),
          ),
        );
      },
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
            color: Colors.grey.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _details(mosque),
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
                        maxLines: 1,
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
                            size: 14,
                            color: AppColors.textLight,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${mosque.distanceKm.toStringAsFixed(2)} km',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.grey.shade200,
                    ),
                  ),
                  child: IconButton(
                    tooltip: 'Directions',
                    onPressed: () => _directions(mosque),
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

  Widget _credit() {
    return TextButton(
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
              TextButton(
                onPressed: data == null || _loading
                    ? null
                    : () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          NearbyMosquesScreen(
                            initialData: data,
                          ),
                    ),
                  );
                },
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else
              IconButton(
                onPressed: _loading ? null : _load,
                tooltip: 'Refresh location and mosques',
                icon: const Icon(Icons.refresh),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (_loading)
          const Padding(
            padding: EdgeInsets.all(20),
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryColor,
              ),
            ),
          )
        else if (_error != null) ...[
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textLight,
            ),
          ),
          Wrap(
            alignment: WrapAlignment.center,
            children: [
              TextButton(
                onPressed: _load,
                child: const Text('Retry'),
              ),
              TextButton(
                onPressed: () async {
                  await Geolocator.openAppSettings();
                },
                child: const Text('Permissions'),
              ),
              TextButton(
                onPressed: () async {
                  await Geolocator.openLocationSettings();
                },
                child: const Text('GPS settings'),
              ),
            ],
          ),
        ] else if (data != null) ...[
          Text(
            '${data.mosques.length} found within 15 km',
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textLight,
            ),
          ),
          for (final warning in data.warnings)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                warning,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.orange,
                ),
              ),
            ),
          const SizedBox(height: 12),
          if (data.mosques.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'No mapped mosques returned within 15 km.',
                textAlign: TextAlign.center,
              ),
            )
          else if (widget.preview)
            ...data.mosques.take(2).map(_card)
          else
            Expanded(
              child: RefreshIndicator(
                onRefresh: _load,
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
          _credit(),
        ],
      ],
    );
  }
}