import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

class TravelPrayerCard extends StatelessWidget {
  const TravelPrayerCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: AppColors.primaryColor.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))
          ]
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('NEXT PRAYER', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                const SizedBox(height: 6),
                const Text('Asr', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800, height: 1.0)),
                const SizedBox(height: 8),
                const Text('38 min', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                Text('remaining', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                  child: const Icon(Icons.volume_up, color: Colors.white, size: 16),
                )
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Center(
              child: SizedBox(
                height: 110,
                width: 110,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(value: 0.65, backgroundColor: Colors.black.withOpacity(0.2), color: Colors.white, strokeWidth: 4),
                    Positioned(
                      bottom: 0,
                      child: Image.network('https://cdn3d.iconscout.com/3d/premium/thumb/mosque-5353597-4468685.png', width: 80, fit: BoxFit.contain),
                    ),
                    Positioned(right: 0, bottom: 20, child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle))),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('PRAYER TIME', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                const Text('4:25 PM', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                Text('TODAY', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10)),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text('View All Prayers', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500)),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios, color: Colors.white, size: 8),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}