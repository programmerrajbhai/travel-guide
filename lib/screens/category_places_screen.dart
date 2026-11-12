import 'package:flutter/material.dart';
import '../services/backend_service.dart';
import '../constants/app_colors.dart';
import 'business_detail/business_detail_screen.dart';
import 'place_map_screen.dart';

class CategoryPlacesScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const CategoryPlacesScreen({
    Key? key,
    required this.categoryId,
    required this.categoryName,
  }) : super(key: key);

  @override
  State<CategoryPlacesScreen> createState() => _CategoryPlacesScreenState();
}

class _CategoryPlacesScreenState extends State<CategoryPlacesScreen> {
  late Future<List<dynamic>> _placesFuture;

  @override
  void initState() {
    super.initState();
    _placesFuture = BackendService.fetchPlaces();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        title: Text(
          widget.categoryName,
          style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _placesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryColor));
          } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No places available."));
          }

          // Filter places by category ID
          final categoryPlaces = snapshot.data!.where((place) {
            return place['category_id'].toString() == widget.categoryId.toString();
          }).toList();

          if (categoryPlaces.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 60, color: Colors.grey[300]),
                  const SizedBox(height: 10),
                  Text("No places found in ${widget.categoryName}", style: const TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            physics: const BouncingScrollPhysics(),
            itemCount: categoryPlaces.length,
            itemBuilder: (context, index) {
              final place = categoryPlaces[index];
              return GestureDetector(
                onTap: () {
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
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8))
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image & Badges
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                            child: Image.network(
                              place['image']?.toString() ?? 'https://via.placeholder.com/400',
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                height: 200,
                                color: Colors.grey[200],
                                child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 40),
                              ),
                            ),
                          ),
                          // Category Badge
                          Positioned(
                            top: 16,
                            left: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(20)),
                              child: Text(
                                place['category_name']?.toString() ?? widget.categoryName,
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          // Rating Badge
                          Positioned(
                            top: 16,
                            right: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                              child: Row(
                                children: const [
                                  Icon(Icons.star, color: Colors.orange, size: 14),
                                  SizedBox(width: 4),
                                  Text('4.8', style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Details Section
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    place['name']?.toString() ?? 'Unknown Place',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppColors.textDark),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: const Icon(Icons.directions, color: AppColors.primaryColor, size: 28),
                                  onPressed: () {
                                    double lat = double.tryParse(place['latitude'].toString()) ?? 0.0;
                                    double lng = double.tryParse(place['longitude'].toString()) ?? 0.0;
                                    Navigator.push(context, MaterialPageRoute(
                                        builder: (context) => PlaceMapScreen(placeName: place['name'].toString(), latitude: lat, longitude: lng)
                                    ));
                                  },
                                )
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    place['address']?.toString() ?? "${place['latitude'] ?? ''}, ${place['longitude'] ?? ''}",
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Tags
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                                  child: const Text('Open Now', style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                                  child: const Text('Verified', style: TextStyle(color: Colors.blue, fontSize: 11, fontWeight: FontWeight.bold)),
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
          );
        },
      ),
    );
  }
}