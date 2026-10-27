import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import 'widgets/search_filter_bar.dart';
import 'widgets/category_chips.dart';
import 'widgets/nearby_places_sheet.dart';

class MapDiscoverScreen extends StatelessWidget {
  const MapDiscoverScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50, // Map background placeholder color
      body: Stack(
        children: [
          // 1. Map View Placeholder (Full Screen Background)
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1524661135-423995f22d0b?auto=format&fit=crop&q=80&w=1080&h=1920', // Static map image
              fit: BoxFit.cover,
              color: Colors.white.withOpacity(0.4),
              colorBlendMode: BlendMode.lighten,
            ),
          ),

          // Simulated Map Pins
          Positioned(top: 250, left: 150, child: _buildMapPin(Icons.mosque, AppColors.primaryColor)),
          Positioned(top: 350, right: 100, child: _buildMapPin(Icons.restaurant, Colors.orange)),
          Positioned(top: 300, left: 80, child: _buildMapPin(Icons.local_gas_station, Colors.blue)),

          // Simulated Current Location
          Positioned(
            top: MediaQuery.of(context).size.height * 0.4,
            left: MediaQuery.of(context).size.width * 0.45,
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: Colors.blue.withOpacity(0.3), shape: BoxShape.circle),
              child: Center(
                child: Container(width: 16, height: 16, decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle, border: Border.fromBorderSide(BorderSide(color: Colors.white, width: 3)))),
              ),
            ),
          ),

          // 2. Top Elements (Search & Chips)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 16, left: 20, right: 20),
              child: Column(
                children: const [
                  SearchFilterBar(),
                  SizedBox(height: 16),
                  CategoryChips(),
                ],
              ),
            ),
          ),

          // Floating Action Buttons on the Map (Right Side)
          Positioned(
            right: 20,
            bottom: MediaQuery.of(context).size.height * 0.48,
            child: Column(
              children: [
                _buildMapFab(Icons.my_location),
                const SizedBox(height: 12),
                _buildMapFab(Icons.layers_outlined),
              ],
            ),
          ),

          // List View Toggle Button (Left Side)
          Positioned(
            left: 20,
            bottom: MediaQuery.of(context).size.height * 0.48,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
              child: Row(
                children: const [
                  Icon(Icons.format_list_bulleted, size: 18, color: AppColors.textDark),
                  SizedBox(width: 6),
                  Text('Show List', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark)),
                ],
              ),
            ),
          ),

          // 3. Draggable Bottom Sheet
          const NearbyPlacesSheet(),
        ],
      ),
    );
  }

  Widget _buildMapPin(IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2), boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6, offset: const Offset(0, 3))]),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
      ],
    );
  }

  Widget _buildMapFab(IconData icon) {
    return Container(
      width: 45, height: 45,
      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))]),
      child: Icon(icon, color: AppColors.textDark, size: 22),
    );
  }
}