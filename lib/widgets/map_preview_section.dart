import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../constants/app_colors.dart';
import '../services/backend_service.dart';
import '../screens/full_map_screen.dart';

class MapPreviewSection extends StatefulWidget {
  const MapPreviewSection({Key? key}) : super(key: key);

  @override
  State<MapPreviewSection> createState() => _MapPreviewSectionState();
}

class _MapPreviewSectionState extends State<MapPreviewSection> {
  late Future<List<dynamic>> _placesFuture;

  @override
  void initState() {
    super.initState();
    // ডাটাবেস থেকে রিয়েল প্লেস ফেচ করা হচ্ছে
    _placesFuture = BackendService.fetchPlaces();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _placesFuture,
      builder: (context, snapshot) {
        // লোডিং বা এরর থাকলে ডিফল্ট UI দেখাবে
        if (snapshot.connectionState == ConnectionState.waiting || snapshot.hasError || !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final places = snapshot.data!;

        // রিয়েল প্লেস থেকে মার্কার তৈরি
        List<Marker> previewMarkers = places.map((place) {
          double lat = double.tryParse(place['latitude'].toString()) ?? 0.0;
          double lng = double.tryParse(place['longitude'].toString()) ?? 0.0;
          return Marker(
            point: LatLng(lat, lng),
            width: 30,
            height: 30,
            child: const Icon(Icons.location_on, color: Colors.red, size: 24),
          );
        }).toList();

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('MAP PREVIEW', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark, letterSpacing: 1.0)),
                GestureDetector(
                  onTap: () {
                    // "Open Full Map" এ ক্লিক করলে ফুল স্ক্রিন ম্যাপ ওপেন হবে
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FullMapScreen(places: places)),
                    );
                  },
                  child: const Text('Open Full Map', style: TextStyle(color: AppColors.primaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 16),

            GestureDetector(
              onTap: () {
                // ম্যাপের উপর ক্লিক করলেও ফুল স্ক্রিন ম্যাপ ওপেন হবে
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FullMapScreen(places: places)),
                );
              },
              child: Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8))
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    children: [
                      // রিয়েল লাইভ মিনি ম্যাপ
                      AbsorbPointer( // ম্যাপ স্ক্রলিং অফ করার জন্য যাতে কার্ড হিসেবে কাজ করে
                        child: FlutterMap(
                          options: MapOptions(
                            initialCenter: const LatLng(23.6850, 90.3563), // বাংলাদেশ ভিউ
                            initialZoom: 5.5,
                            interactionOptions: const InteractionOptions(flags: InteractiveFlag.none), // জুম অফ
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: "https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}",
                              userAgentPackageName: 'com.yourcompany.travelguide',
                            ),
                            MarkerLayer(markers: previewMarkers),
                          ],
                        ),
                      ),

                      // ডার্ক গ্রেডিয়েন্ট এবং এক্সপ্লোর বাটন (প্রিমিয়াম লুকের জন্য)
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.black.withOpacity(0.0), Colors.black.withOpacity(0.4)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 12,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 4))],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.explore, size: 16, color: AppColors.primaryColor),
                                SizedBox(width: 6),
                                Text("Explore Map", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}