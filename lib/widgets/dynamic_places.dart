import 'package:flutter/material.dart';
import '../screens/all_places_screen.dart';
import '../services/backend_service.dart';
import '../constants/app_colors.dart';

class DynamicPlaces extends StatefulWidget {
  const DynamicPlaces({Key? key}) : super(key: key);

  @override
  State<DynamicPlaces> createState() => _DynamicPlacesState();
}

class _DynamicPlacesState extends State<DynamicPlaces> {
  late Future<List<dynamic>> _placesFuture;

  @override
  void initState() {
    super.initState();
    _placesFuture = BackendService.fetchPlaces();
  }

  // Stylish Bottom Sheet for Place Details
  void _showPlaceDetailsBottomSheet(BuildContext context, dynamic place) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows sheet to take more height
      backgroundColor: Colors.transparent, // Transparent to show custom rounded corners
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75, // 75% of screen height
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 12),
                  height: 5,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              // Cover Image
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    place['image'],
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

              // Title and Category Badge
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

              // Location Coordinates
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.grey, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      "Lat: ${place['latitude']}, Lng: ${place['longitude']}",
                      style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Description
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  "About this place",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                ),
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

              // Action Buttons
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Future feature: Open Google Maps
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Opening Maps... (Coming Soon)')),
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
        // Header Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('DISCOVER PLACES', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: AppColors.textDark)),
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AllPlacesScreen()));
              },
              child: const Text('View All', style: TextStyle(fontSize: 12, color: AppColors.primaryColor, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // FutureBuilder to load data
        FutureBuilder<List<dynamic>>(
          future: _placesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: Padding(padding: EdgeInsets.all(20.0), child: CircularProgressIndicator()));
            } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Padding(padding: EdgeInsets.all(20.0), child: Text("No places available.")));
            }

            final places = snapshot.data!;
            return SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: places.length,
                itemBuilder: (context, index) {
                  final place = places[index];
                  return GestureDetector(
                    onTap: () => _showPlaceDetailsBottomSheet(context, place), // <-- Bottom Sheet Call
                    child: Container(
                      width: 180,
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.grey.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 5))
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                child: Image.network(
                                  place['image'],
                                  height: 120,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    height: 120,
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.image_not_supported, color: Colors.grey),
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
                                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        "${place['latitude']}, ${place['longitude']}",
                                        style: const TextStyle(color: Colors.grey, fontSize: 10),
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
            );
          },
        ),
      ],
    );
  }
}