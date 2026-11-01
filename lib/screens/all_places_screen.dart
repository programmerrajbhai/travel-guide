import 'package:flutter/material.dart';
import '../services/backend_service.dart';
import '../constants/app_colors.dart';

class AllPlacesScreen extends StatefulWidget {
  const AllPlacesScreen({Key? key}) : super(key: key);

  @override
  State<AllPlacesScreen> createState() => _AllPlacesScreenState();
}

class _AllPlacesScreenState extends State<AllPlacesScreen> {
  late Future<List<dynamic>> _placesFuture;

  @override
  void initState() {
    super.initState();
    _placesFuture = BackendService.fetchPlaces();
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
                    place['image'], height: 220, width: double.infinity, fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(height: 220, color: Colors.grey[200], child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey)),
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
                    Expanded(child: Text(place['name'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: AppColors.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: Text(place['category_name'] ?? 'Place', style: const TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
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
                    Text("Lat: ${place['latitude']}, Lng: ${place['longitude']}", style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500)),
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
                  child: Text(place['description'] ?? 'No description available.', style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5)),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        title: const Text(
          'Discover Places',
          style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _placesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No places available."));
          }

          final places = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            physics: const BouncingScrollPhysics(),
            itemCount: places.length,
            itemBuilder: (context, index) {
              final place = places[index];
              return GestureDetector(
                onTap: () => _showPlaceDetailsBottomSheet(context, place),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        child: Image.network(
                          place['image'], height: 180, width: double.infinity, fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(height: 180, color: Colors.grey[200], child: const Icon(Icons.image_not_supported, color: Colors.grey)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(place['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textDark), maxLines: 1, overflow: TextOverflow.ellipsis),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: AppColors.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                  child: Text(place['category_name'] ?? '', style: const TextStyle(color: AppColors.primaryColor, fontSize: 10, fontWeight: FontWeight.bold)),
                                )
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text("${place['latitude']}, ${place['longitude']}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
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