import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class MapPreviewSection extends StatelessWidget {
  const MapPreviewSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('MAP PREVIEW', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark, letterSpacing: 0.5)),
            Text('Open Full Map', style: TextStyle(color: AppColors.primaryColor, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          height: 140,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: const DecorationImage(
              image: NetworkImage('https://images.unsplash.com/photo-1524661135-423995f22d0b?auto=format&fit=crop&q=80&w=800&h=300'),
              fit: BoxFit.cover,
            ),
            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 24, height: 24,
                decoration: BoxDecoration(color: Colors.blue.withOpacity(0.3), shape: BoxShape.circle),
                child: Center(
                  child: Container(width: 12, height: 12, decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle, border: Border.fromBorderSide(BorderSide(color: Colors.white, width: 2)))),
                ),
              ),
              Positioned(top: 20, left: 80, child: _buildMapPin(Icons.mosque, Colors.green)),
              Positioned(bottom: 30, right: 60, child: _buildMapPin(Icons.restaurant, Colors.orange)),
              Positioned(top: 40, right: 100, child: _buildMapPin(Icons.local_hospital, Colors.redAccent)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMapPin(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4)]),
      child: Icon(icon, color: Colors.white, size: 12),
    );
  }
}