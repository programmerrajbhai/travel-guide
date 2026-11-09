import 'package:flutter/material.dart';
import '../../../../constants/app_colors.dart';

class PrayerHeaderCard extends StatelessWidget {
  final String locationName;
  final String hijriDate;
  final String nextPrayer;
  final String timeRemaining;

  const PrayerHeaderCard({
    Key? key,
    required this.locationName,
    required this.hijriDate,
    required this.nextPrayer,
    required this.timeRemaining,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(locationName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(hijriDate, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textLight)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.calendar_month_outlined, size: 20, color: AppColors.textLight),
            )
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF0F4C36), Color(0xFF1B6A4E)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: const Color(0xFF0F4C36).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20, bottom: -20,
                child: Opacity(opacity: 0.15, child: Image.network('https://cdn3d.iconscout.com/3d/premium/thumb/mosque-5353597-4468685.png', width: 140)),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('NEXT PRAYER', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  const SizedBox(height: 12),
                  Text(nextPrayer, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
                  const SizedBox(height: 4),
                  Text(timeRemaining, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('Remaining Time', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}