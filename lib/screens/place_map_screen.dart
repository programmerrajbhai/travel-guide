import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_colors.dart';
import '../services/location_service.dart';

class PlaceMapScreen extends StatefulWidget {
  final String placeName;
  final double latitude;
  final double longitude;

  const PlaceMapScreen({
    Key? key,
    required this.placeName,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);

  @override
  State<PlaceMapScreen> createState() => _PlaceMapScreenState();
}

class _PlaceMapScreenState extends State<PlaceMapScreen> {
  final MapController _mapController = MapController();
  late LatLng _targetLocation;
  LatLng? _myLocation;
  LatLng? _midRoutePoint; // ম্যাপের রাস্তার মাঝখানে সময় দেখানোর জন্য

  final List<Marker> _markers = [];
  final List<Polyline> _polylines = [];

  bool _isRouting = false;
  bool _routeFound = false;
  String _distance = "";
  String _duration = "";

  // Geoapify API Key
  final String geoapifyApiKey = "c39a5aa2e8f341b79dca99e2a4a3aeea";

  @override
  void initState() {
    super.initState();
    _targetLocation = LatLng(widget.latitude, widget.longitude);
    _setTargetMarker();
    _loadUserLocationAndRoute();
  }

  void _setTargetMarker() {
    _markers.add(
      Marker(
        point: _targetLocation,
        width: 60,
        height: 60,
        child: const Icon(Icons.location_on, color: Colors.red, size: 45),
      ),
    );
  }

  Future<void> _loadUserLocationAndRoute() async {
    setState(() => _isRouting = true);

    Position? pos = await LocationService.getCurrentLocation();
    if (pos != null) {
      setState(() {
        _myLocation = LatLng(pos.latitude, pos.longitude);
      });
      await _fetchRoute();
    } else {
      setState(() => _isRouting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('GPS Error. Could not get current location.')),
      );
    }
  }

  Future<void> _fetchRoute() async {
    if (_myLocation == null) return;

    String waypoints = "${_myLocation!.latitude},${_myLocation!.longitude}|${_targetLocation.latitude},${_targetLocation.longitude}";
    String url = "https://api.geoapify.com/v1/routing?waypoints=$waypoints&mode=drive&apiKey=$geoapifyApiKey";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['features'] != null && data['features'].isNotEmpty) {
          final feature = data['features'][0];
          final geometry = feature['geometry'];
          final properties = feature['properties'];

          double distMeters = properties['distance'].toDouble();
          double timeSeconds = properties['time'].toDouble();

          String calculatedDistance = (distMeters / 1000).toStringAsFixed(0) + " km";
          int mins = (timeSeconds / 60).round();
          String calculatedTime = mins > 60 ? "${(mins ~/ 60)} hr ${mins % 60} min" : "$mins min";

          final coordinates = geometry['coordinates'][0];
          List<LatLng> routePoints = [];
          for (var coord in coordinates) {
            routePoints.add(LatLng(coord[1], coord[0]));
          }

          setState(() {
            _distance = calculatedDistance;
            _duration = calculatedTime;
            _routeFound = true;
            _midRoutePoint = routePoints[routePoints.length ~/ 2]; // রাস্তার মাঝখানের পয়েন্ট

            _polylines.add(
              Polyline(
                points: routePoints,
                color: const Color(0xFF1A73E8), // Google Maps Blue
                strokeWidth: 6.0,
                borderStrokeWidth: 2.0,
                borderColor: const Color(0xFF0D47A1), // Dark blue border
              ),
            );
          });

          var bounds = LatLngBounds.fromPoints([_myLocation!, _targetLocation, ...routePoints]);
          _mapController.fitCamera(CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(80)));
        }
      }
    } catch (e) {
      print("Routing Error: $e");
    }

    setState(() => _isRouting = false);
  }

  Future<void> _openGoogleMapsApp() async {
    final Uri url = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=${widget.latitude},${widget.longitude}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Marker> allMarkers = List.from(_markers);

    // User Location Marker
    if (_myLocation != null) {
      allMarkers.add(
        Marker(
          point: _myLocation!,
          width: 40,
          height: 40,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blue, width: 2),
            ),
            child: const Center(
              child: CircleAvatar(backgroundColor: Colors.blue, radius: 8),
            ),
          ),
        ),
      );
    }

    // Floating Time Bubble on the Route (Google Maps style)
    if (_routeFound && _midRoutePoint != null) {
      allMarkers.add(
        Marker(
          point: _midRoutePoint!,
          width: 120,
          height: 45,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF1A73E8),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
            ),
            child: Center(
              child: Text(
                _duration,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Map Background
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _targetLocation,
              initialZoom: 14.0,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}",
                userAgentPackageName: 'com.yourcompany.travelguide',
              ),
              PolylineLayer(polylines: _polylines),
              MarkerLayer(markers: allMarkers),
            ],
          ),

          // 1. Top Input Card (Google Maps Style)
          Positioned(
            top: 50,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, color: Colors.black87),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(backgroundColor: Colors.blue, radius: 4),
                            const SizedBox(width: 12),
                            const Text("Your location", style: TextStyle(fontSize: 15, color: Colors.black87)),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 3.0, top: 4, bottom: 4),
                          child: Icon(Icons.more_vert, size: 16, color: Colors.grey),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.red, size: 14),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                widget.placeName,
                                style: const TextStyle(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.w500),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.swap_vert, color: Colors.grey),
                ],
              ),
            ),
          ),

          // FABs
          if (_myLocation != null)
            Positioned(
              bottom: 230,
              right: 16,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: Colors.white,
                onPressed: () => _mapController.move(_myLocation!, 15.0),
                child: const Icon(Icons.my_location, color: Colors.blue),
              ),
            ),

          // 2. Bottom Sheet UI (Exact Google Maps Style)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, -5))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                    ),
                  ),

                  // Transport Tabs
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildTransportTab(Icons.directions_car, _duration.isNotEmpty ? _duration : "-", true),
                      _buildTransportTab(Icons.directions_transit, "--", false),
                      _buildTransportTab(Icons.directions_walk, "--", false),
                    ],
                  ),
                  const Divider(height: 30),

                  if (_isRouting)
                    const Center(child: CircularProgressIndicator())
                  else if (_routeFound)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(text: _duration, style: const TextStyle(color: Colors.green, fontSize: 24, fontWeight: FontWeight.bold)),
                              TextSpan(text: "  ($_distance)", style: const TextStyle(color: Colors.black54, fontSize: 18)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text("Fastest route, despite the usual traffic", style: TextStyle(color: Colors.black54, fontSize: 14)),
                        const SizedBox(height: 20),

                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: ElevatedButton.icon(
                                onPressed: _openGoogleMapsApp,
                                icon: const Icon(Icons.navigation, color: Colors.white),
                                label: const Text("Start", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1A73E8), // Google Maps Blue
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 1,
                              child: OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  side: BorderSide(color: Colors.grey.shade300),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                ),
                                child: const Text("Steps", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        )
                      ],
                    )
                  else
                    const Center(child: Text("Could not calculate route.", style: TextStyle(color: Colors.red))),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  // Helper widget for Transport Tabs
  Widget _buildTransportTab(IconData icon, String time, bool isSelected) {
    return Column(
      children: [
        Icon(icon, color: isSelected ? const Color(0xFF1A73E8) : Colors.black54, size: 28),
        const SizedBox(height: 4),
        Text(time, style: TextStyle(color: isSelected ? const Color(0xFF1A73E8) : Colors.black54, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }
}