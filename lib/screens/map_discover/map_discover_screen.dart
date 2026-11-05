import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../constants/app_colors.dart';
import '../../services/backend_service.dart';
import '../../services/location_service.dart';

class MapDiscoverScreen extends StatefulWidget {
  const MapDiscoverScreen({Key? key}) : super(key: key);

  @override
  State<MapDiscoverScreen> createState() => _MapDiscoverScreenState();
}

class _MapDiscoverScreenState extends State<MapDiscoverScreen> {
  final MapController _mapController = MapController();
  List<Marker> _markers = [];
  LatLng _currentCenter = const LatLng(23.8103, 90.4125); // ডিফল্ট ঢাকা
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    // ১. ইউজারের লাইভ লোকেশন বের করা
    final position = await LocationService.getCurrentLocation();
    if (position != null) {
      _currentCenter = LatLng(position.latitude, position.longitude);
    }

    // ২. ডাটাবেস থেকে প্লেসগুলো ফেচ করা
    final places = await BackendService.fetchPlaces();

    List<Marker> newMarkers = [];

    // ৩. ইউজারের নিজের লোকেশনের জন্য নীল রঙের একটি মার্কার অ্যাড করা
    if (position != null) {
      newMarkers.add(
        Marker(
          point: _currentCenter,
          width: 50,
          height: 50,
          child: const Icon(Icons.my_location, color: Colors.blue, size: 30),
        ),
      );
    }

    // ৪. ডাটাবেস থেকে পাওয়া প্রতিটি প্লেসের জন্য লাল রঙের মার্কার অ্যাড করা
    for (var place in places) {
      double lat = double.tryParse(place['latitude'].toString()) ?? 0.0;
      double lng = double.tryParse(place['longitude'].toString()) ?? 0.0;

      if (lat != 0.0 && lng != 0.0) {
        newMarkers.add(
          Marker(
            point: LatLng(lat, lng),
            width: 50,
            height: 50,
            child: GestureDetector(
              onTap: () => _showPlaceInfo(place),
              child: const Icon(Icons.location_on, color: Colors.redAccent, size: 40),
            ),
          ),
        );
      }
    }

    setState(() {
      _markers = newMarkers;
      _isLoading = false;
    });
  }

  // ম্যাপের কোনো পিনে ক্লিক করলে নিচ থেকে বিস্তারিত তথ্য দেখাবে
  void _showPlaceInfo(dynamic place) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 5,
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 16),
                Text(place['name'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.category, color: AppColors.primaryColor, size: 16),
                    const SizedBox(width: 8),
                    Text(place['category_name'] ?? 'Place', style: const TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  place['description'] ?? 'No details available.',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Close', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Map Discover', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w900, fontSize: 24)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
          : FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _currentCenter,
          initialZoom: 13.0,
        ),
        children: [
          TileLayer(
            // OpenStreetMap (OSM) ফ্রি টাইল সার্ভার
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.travel_guide',
          ),
          MarkerLayer(markers: _markers),
          RichAttributionWidget(
            attributions: [
              TextSourceAttribution('© OpenStreetMap contributors'),
            ],
          ),
        ],
      ),
      // এই বাটনে চাপলে ম্যাপ আবার ইউজারের লোকেশনে ফিরে আসবে
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryColor,
        onPressed: () {
          _mapController.move(_currentCenter, 14.0);
        },
        child: const Icon(Icons.my_location, color: Colors.white),
      ),
    );
  }
}