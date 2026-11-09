import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../screens/all_places_screen.dart';
import '../services/backend_service.dart';
import '../constants/app_colors.dart';
import '../services/location_service.dart';
import '../screens/business_detail/business_detail_screen.dart';

class DynamicPlaces extends StatefulWidget {
  const DynamicPlaces({Key? key}) : super(key: key);

  @override
  State<DynamicPlaces> createState() => _DynamicPlacesState();
}

class _DynamicPlacesState extends State<DynamicPlaces> {
  List<dynamic> _places = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAndSortPlaces();
  }

  Future<void> _fetchAndSortPlaces() async {
    try {
      final position = await LocationService.getCurrentLocation();
      double userLat = position?.latitude ?? 23.8103;
      double userLng = position?.longitude ?? 90.4125;

      final allPlaces = await BackendService.fetchPlaces();
      List<dynamic> sortedPlaces = [];

      for (var place in allPlaces) {
        double placeLat = double.tryParse(place['latitude'].toString()) ?? 0.0;
        double placeLng = double.tryParse(place['longitude'].toString()) ?? 0.0;

        if (placeLat != 0.0 && placeLng != 0.0) {
          double distanceInMeters = Geolocator.distanceBetween(userLat, userLng, placeLat, placeLng);
          Map<String, dynamic> placeData = Map<String, dynamic>.from(place);
          placeData['distance'] = distanceInMeters / 1000;
          sortedPlaces.add(placeData);
        }
      }

      sortedPlaces.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));

      if (mounted) {
        setState(() {
          _places = sortedPlaces;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('NEARBY PLACES', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: AppColors.textDark)),
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AllPlacesScreen()));
              },
              child: const Text('View All', style: TextStyle(fontSize: 12, color: AppColors.primaryColor, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 16),

        _isLoading
            ? const Center(child: Padding(padding: EdgeInsets.all(20.0), child: CircularProgressIndicator()))
            : _places.isEmpty
            ? const Center(child: Padding(padding: EdgeInsets.all(20.0), child: Text("No places available.")))
            : SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _places.length,
            itemBuilder: (context, index) {
              final place = _places[index];
              return GestureDetector(
                onTap: () {
                  // Bottom Sheet এর বদলে সরাসরি ডিটেইলস স্ক্রিন ওপেন হবে
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BusinessDetailScreen(
                        placeData: Map<String, dynamic>.from(place),
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 180,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 5))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                              child: Image.network(
                                place['image']?.toString() ?? '',
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: Colors.grey[200],
                                  child: const Center(child: Icon(Icons.image_not_supported, color: Colors.grey)),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 10,
                              right: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  place['category_name']?.toString() ?? 'Place',
                                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              place['name']?.toString() ?? '',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.directions_walk, size: 14, color: AppColors.primaryColor),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    "${(place['distance'] as double).toStringAsFixed(1)} km",
                                    style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w600),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}