import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../constants/app_colors.dart';
import '../../../services/backend_service.dart';
import '../../place_map_screen.dart';

class NearbyPlacesSheet extends StatefulWidget {
  const NearbyPlacesSheet({Key? key}) : super(key: key);

  @override
  State<NearbyPlacesSheet> createState() => _NearbyPlacesSheetState();
}

class _NearbyPlacesSheetState extends State<NearbyPlacesSheet> {
  List<dynamic> _places = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPlacesAndCalculateDistance();
  }

  Future<void> _fetchPlacesAndCalculateDistance() async {
    try {
      final places = await BackendService.fetchPlaces();

      Position? userPos;
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
          userPos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        }
      }

      // এরর ফিক্স করার জন্য সিম্পল ডাইনামিক লিস্ট ব্যবহার করা হয়েছে
      List<dynamic> processedPlaces = [];

      for (var item in places) {
        // ডাইনামিক ডাটাকে সেফভাবে ম্যাপে কনভার্ট করা হলো
        Map<String, dynamic> p = Map<String, dynamic>.from(item);

        double lat = double.tryParse(p['latitude'].toString()) ?? 0.0;
        double lng = double.tryParse(p['longitude'].toString()) ?? 0.0;
        double distanceKm = 0.0;

        if (userPos != null) {
          distanceKm = Geolocator.distanceBetween(userPos.latitude, userPos.longitude, lat, lng) / 1000;
        }

        // দূরত্ব যুক্ত করে নতুন লিস্টে অ্যাড করা হলো
        p['calculated_distance'] = distanceKm;
        processedPlaces.add(p);
      }

      processedPlaces.sort((a, b) => (a['calculated_distance'] as double).compareTo(b['calculated_distance'] as double));

      if (mounted) {
        setState(() {
          _places = processedPlaces;
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
    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.15,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5))
            ],
          ),
          child: Column(
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Nearby Places', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                    Row(
                      children: [
                        Text('Sort: Distance', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                        Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey.shade600),
                      ],
                    ),
                  ],
                ),
              ),

              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
                    : _places.isEmpty
                    ? const Center(child: Text("No nearby places found."))
                    : ListView.builder(
                  controller: scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                  itemCount: _places.length,
                  itemBuilder: (context, index) {
                    return _buildPremiumPlaceCard(context, _places[index]);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPremiumPlaceCard(BuildContext context, Map<String, dynamic> place) {
    double distance = place['calculated_distance'] ?? 0.0;
    String distanceText = distance > 0 ? "${distance.toStringAsFixed(1)} km" : "";

    bool isMosque = place['category_name'].toString().toLowerCase().contains('masjid') ||
        place['category_name'].toString().toLowerCase().contains('mosque');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              place['image'],
              width: 85,
              height: 85,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(width: 85, height: 85, color: Colors.grey.shade200, child: const Icon(Icons.image, color: Colors.grey)),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        place['name'],
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark, height: 1.2),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            if (distanceText.isNotEmpty)
                              Text(distanceText, style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w500)),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                double lat = double.tryParse(place['latitude'].toString()) ?? 0.0;
                                double lng = double.tryParse(place['longitude'].toString()) ?? 0.0;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => PlaceMapScreen(placeName: place['name'], latitude: lat, longitude: lng)),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF115C49),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.directions, color: Colors.white, size: 14),
                                    SizedBox(width: 4),
                                    Text("Directions", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        const Text("4.8", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        const SizedBox(width: 4),
                        Text("(210)", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: Colors.green.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
                          child: const Text("Open", style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                    const Icon(Icons.bookmark_border, color: AppColors.textDark, size: 20),
                  ],
                ),
                const SizedBox(height: 6),

                Text(
                  place['category_name'] ?? 'Destination',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: isMosque
                      ? [
                    _buildTag(Icons.local_parking, "Parking"),
                    _buildTag(Icons.water_drop_outlined, "Wudu"),
                    _buildTag(Icons.people_outline, "Sisters Area"),
                  ]
                      : [
                    _buildTag(Icons.verified, "Halal Verified"),
                    _buildTag(Icons.restaurant, "Dine-in"),
                    _buildTag(Icons.shopping_bag_outlined, "Takeaway"),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTag(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textDark),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textDark)),
        ],
      ),
    );
  }
}