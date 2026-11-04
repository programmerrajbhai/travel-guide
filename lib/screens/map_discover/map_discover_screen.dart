import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../constants/app_colors.dart';
import '../../services/backend_service.dart';
import 'widgets/search_filter_bar.dart';
import 'widgets/category_chips.dart';
import 'widgets/nearby_places_sheet.dart';
import '../place_map_screen.dart'; // ম্যাপ পিন থেকে ডিটেইলসে যাওয়ার জন্য

class MapDiscoverScreen extends StatefulWidget {
  const MapDiscoverScreen({Key? key}) : super(key: key);

  @override
  State<MapDiscoverScreen> createState() => _MapDiscoverScreenState();
}

class _MapDiscoverScreenState extends State<MapDiscoverScreen> {
  final MapController _mapController = MapController();
  late Future<List<dynamic>> _placesFuture;
  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    // ১. ডাটাবেস থেকে রিয়েল প্লেস ফেচ
    _placesFuture = BackendService.fetchPlaces();
    // ২. ইউজারের রিয়েল লাইভ লোকেশন ফেচ
    _getUserLiveLocation();
  }

  // ইউজারের কারেন্ট লোকেশন জিপিএস থেকে বের করার ফাংশন
  Future<void> _getUserLiveLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
    });

    // লোকেশন পাওয়ার সাথে সাথে ম্যাপের ক্যামেরা ইউজারের লোকেশনে মুভ করবে
    _mapController.move(_currentLocation!, 14.0);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // 1. Real Google Maps (FlutterMap) with Real Database Markers
          FutureBuilder<List<dynamic>>(
            future: _placesFuture,
            builder: (context, snapshot) {
              List<Marker> allMarkers = [];

              // ডাটাবেসের রিয়েল লোকেশন মার্কার
              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                allMarkers = snapshot.data!.map((place) {
                  double lat = double.tryParse(place['latitude'].toString()) ?? 0.0;
                  double lng = double.tryParse(place['longitude'].toString()) ?? 0.0;

                  return Marker(
                    point: LatLng(lat, lng),
                    width: 45,
                    height: 45,
                    child: GestureDetector(
                      onTap: () {
                        // পিনে ক্লিক করলে ওই প্লেসের ডিরেকশন স্ক্রিনে যাবে
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
                      child: _buildMapPin(Icons.location_on, AppColors.primaryColor),
                    ),
                  );
                }).toList();
              }

              // ইউজারের লাইভ লোকেশন মার্কার (Blue Dot)
              if (_currentLocation != null) {
                allMarkers.add(
                    Marker(
                      point: _currentLocation!,
                      width: 40,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 3),
                                  boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.5), blurRadius: 8)]
                              )
                          ),
                        ),
                      ),
                    )
                );
              }

              return FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: const LatLng(23.8103, 90.4125), // Default Center (Dhaka)
                  initialZoom: 12.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: "https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}", // Google Maps Tiles
                    userAgentPackageName: 'com.programmerrajbhai.travelguide',
                  ),
                  MarkerLayer(markers: allMarkers),
                ],
              );
            },
          ),

          // 2. Top Elements (Search & Chips)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 16, left: 20, right: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  SearchFilterBar(),
                  SizedBox(height: 16),
                  CategoryChips(),
                ],
              ),
            ),
          ),

          // 3. Floating Action Buttons (My Location & Layers)
          Positioned(
            right: 20,
            bottom: screenHeight * 0.45,
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    // My Location এ ক্লিক করলে ক্যামেরা লাইভ লোকেশনে যাবে
                    if (_currentLocation != null) {
                      _mapController.move(_currentLocation!, 15.0);
                    } else {
                      _getUserLiveLocation(); // লোকেশন না থাকলে আবার ফেচ করবে
                    }
                  },
                  child: _buildMapFab(Icons.my_location, isActive: _currentLocation != null),
                ),
                const SizedBox(height: 12),
                _buildMapFab(Icons.layers_outlined),
              ],
            ),
          ),

          // 4. List View Toggle Button
          Positioned(
            left: 20,
            bottom: screenHeight * 0.45,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 15, offset: const Offset(0, 5))]
              ),
              child: Row(
                children: const [
                  Icon(Icons.format_list_bulleted, size: 18, color: AppColors.textDark),
                  SizedBox(width: 6),
                  Text('Show List', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark)),
                ],
              ),
            ),
          ),

          // 5. Draggable Bottom Sheet (Nearby Places)
          const NearbyPlacesSheet(),
        ],
      ),
    );
  }

  // কাস্টম ম্যাপ পিন (ডাটাবেস প্লেসের জন্য)
  Widget _buildMapPin(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2.5),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.5), blurRadius: 8, offset: const Offset(0, 4))
          ]
      ),
      child: Icon(icon, color: Colors.white, size: 18),
    );
  }

  // কাস্টম ফ্লোটিং বাটন (GPS ফোকাসের জন্য)
  Widget _buildMapFab(IconData icon, {bool isActive = false}) {
    return Container(
      width: 48, height: 48,
      decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 15, offset: const Offset(0, 5))
          ]
      ),
      child: Icon(icon, color: isActive ? Colors.blue : AppColors.textDark, size: 24),
    );
  }
}