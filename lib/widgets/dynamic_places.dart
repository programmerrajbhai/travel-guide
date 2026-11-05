import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../screens/all_places_screen.dart';
import '../services/backend_service.dart';
import '../constants/app_colors.dart';
import '../screens/place_map_screen.dart';
import '../services/location_service.dart';

class DynamicPlaces extends StatefulWidget {
  const DynamicPlaces({Key? key}) : super(key: key);

  @override
  State<DynamicPlaces> createState() => _DynamicPlacesState();
}

class _DynamicPlacesState extends State<DynamicPlaces> {
  // ডাটা টাইপ সিম্প্লিফাই করা হলো যাতে কম্পাইলার এরর না দেয়
  List<dynamic> _places = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAndSortPlaces();
  }

  Future<void> _fetchAndSortPlaces() async {
    try {
      // 1. User er live location niye asha
      final position = await LocationService.getCurrentLocation();
      double userLat = position?.latitude ?? 23.8103;
      double userLng = position?.longitude ?? 90.4125;

      // 2. Database theke sob place fetch kora
      final allPlaces = await BackendService.fetchPlaces();

      // ডাটা টাইপ সিম্প্লিফাই করা হলো
      List<dynamic> sortedPlaces = [];

      // 3. Protiti place er distance map kora
      for (var place in allPlaces) {
        double placeLat = double.tryParse(place['latitude'].toString()) ?? 0.0;
        double placeLng = double.tryParse(place['longitude'].toString()) ?? 0.0;

        if (placeLat != 0.0 && placeLng != 0.0) {
          double distanceInMeters = Geolocator.distanceBetween(userLat, userLng, placeLat, placeLng);
          Map<String, dynamic> placeData = Map<String, dynamic>.from(place);
          placeData['distance'] = distanceInMeters / 1000; // Convert to km
          sortedPlaces.add(placeData);
        }
      }

      // 4. Kacher place gulo (Nearest) aage show korar jonno sort kora
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

  void _showPlaceDetailsBottomSheet(BuildContext context, dynamic place) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 12),
                  height: 5,
                  width: 50,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    place['image'] ?? '',
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 220,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        place['name'],
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        place['category_name'] ?? 'Place',
                        style: const TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.grey, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      "${(place['distance'] as double).toStringAsFixed(1)} km away from you",
                      style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text("About this place", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    place['description'] ?? 'No description available.',
                    style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          double lat = double.tryParse(place['latitude'].toString()) ?? 0.0;
                          double lng = double.tryParse(place['longitude'].toString()) ?? 0.0;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PlaceMapScreen(
                                placeName: place['name'],
                                latitude: lat,
                                longitude: lng,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: const Text('Get Directions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
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
                onTap: () => _showPlaceDetailsBottomSheet(context, place),
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
                                place['image'] ?? '',
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
                                  place['category_name'] ?? 'Place',
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
                              place['name'],
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