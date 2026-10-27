import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

class QiblaCompassSection extends StatelessWidget {
  const QiblaCompassSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('DIRECTION TO KAABA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textLight, letterSpacing: 0.5)),
        const SizedBox(height: 12),
        Row(
          children: [
            Container(
              width: 120, height: 120,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade300, width: 1)),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.explore, size: 100, color: Colors.green),
                  Positioned(top: 8, child: Text('N', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade400))),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('245°', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                  const Text('South West', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textLight)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)), child: const Icon(Icons.mosque, size: 14, color: AppColors.textDark)),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Makkah', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                          Text('9,870 km', style: TextStyle(fontSize: 11, color: AppColors.textLight)),
                        ],
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.location_on, color: Colors.white, size: 18),
            label: const Text('Start Qibla Guidance', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          ),
        )
      ],
    );
  }
}