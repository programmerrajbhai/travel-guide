import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';
import '../../../../constants/app_colors.dart';
import '../live_qibla_screen.dart';

class QiblaCompassSection extends StatelessWidget {
  final double direction;
  final double distanceKm;

  const QiblaCompassSection({Key? key, required this.direction, required this.distanceKm}) : super(key: key);

  String _getDirectionText(double degree) {
    if (degree >= 22.5 && degree < 67.5) return 'North East';
    if (degree >= 67.5 && degree < 112.5) return 'East';
    if (degree >= 112.5 && degree < 157.5) return 'South East';
    if (degree >= 157.5 && degree < 202.5) return 'South';
    if (degree >= 202.5 && degree < 247.5) return 'South West';
    if (degree >= 247.5 && degree < 292.5) return 'West';
    if (degree >= 292.5 && degree < 337.5) return 'North West';
    return 'North';
  }

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat("#,##0", "en_US");
    String formattedDistance = formatCurrency.format(distanceKm);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('DIRECTION TO KAABA', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textLight, letterSpacing: 0.5)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade100), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))]),
          child: Row(
            children: [
              Container(
                width: 130, height: 130,
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade200, width: 1.5)),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(top: 8, child: Text('N', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade400))),
                    Positioned(bottom: 8, child: Text('S', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade400))),
                    Positioned(left: 8, child: Text('W', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade400))),
                    Positioned(right: 8, child: Text('E', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade400))),
                    Transform.rotate(
                      angle: direction * (math.pi / 180),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(Icons.navigation, size: 80, color: const Color(0xFF1B6A4E).withOpacity(0.9)),
                          const Positioned(bottom: -15, child: Icon(Icons.airplanemode_active, size: 20, color: Colors.black)),
                        ],
                      ),
                    ),
                    Container(width: 12, height: 12, decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: const Color(0xFF1B6A4E), width: 3))),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${direction.toStringAsFixed(0)}°', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: AppColors.textDark, height: 1.1)),
                    Text(_getDirectionText(direction), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFF0F4C36), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.mosque, size: 16, color: Colors.white)),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Makkah', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                            Text('$formattedDistance km', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                          ],
                        )
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => LiveQiblaScreen(qiblaDirection: direction)));
            },
            icon: const Icon(Icons.location_on_outlined, color: Colors.white, size: 20),
            label: const Text('Start Qibla Guidance', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F4C36), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 2),
          ),
        )
      ],
    );
  }
}