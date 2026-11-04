import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../constants/app_colors.dart';
import 'place_map_screen.dart';

class FullMapScreen extends StatelessWidget {
  final List<dynamic> places;

  const FullMapScreen({Key? key, required this.places}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ডাটাবেসের সবগুলো প্লেস থেকে মার্কার তৈরি করা হচ্ছে
    List<Marker> allMarkers = places.map((place) {
      double lat = double.tryParse(place['latitude'].toString()) ?? 0.0;
      double lng = double.tryParse(place['longitude'].toString()) ?? 0.0;

      return Marker(
        point: LatLng(lat, lng),
        width: 50,
        height: 50,
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
          child: const Icon(Icons.location_on, color: Colors.red, size: 40),
        ),
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore All Places', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: const LatLng(23.6850, 90.3563), // বাংলাদেশের সেন্টার পয়েন্ট
          initialZoom: 6.5,
        ),
        children: [
          TileLayer(
            // গুগল ম্যাপের অরিজিনাল টাইলস
            urlTemplate: "https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}",
            userAgentPackageName: 'com.yourcompany.travelguide',
          ),
          MarkerLayer(markers: allMarkers),
        ],
      ),
    );
  }
}