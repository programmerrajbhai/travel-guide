import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

class PrayerHeaderCard extends StatelessWidget {
  const PrayerHeaderCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Albany, NY, USA', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                SizedBox(height: 4),
                Text('15 Muharram 1446 AH', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.calendar_today, size: 18, color: AppColors.textDark),
            )
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF0F4C36), Color(0xFF1B6A4E)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: AppColors.primaryColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20, bottom: -20,
                child: Opacity(
                  opacity: 0.2,
                  child: Image.network('https://cdn3d.iconscout.com/3d/premium/thumb/mosque-5353597-4468685.png', width: 120),
                ),
              ),
              Column(
                children: const [
                  Text('NEXT PRAYER', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  SizedBox(height: 8),
                  Text('ASR', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: 1.0)),
                  SizedBox(height: 4),
                  Text('01:12:35', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600)),
                  Text('Remaining Time', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}