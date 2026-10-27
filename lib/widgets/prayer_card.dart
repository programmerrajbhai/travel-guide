import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class PrayerCard extends StatelessWidget {
  const PrayerCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left Section: Texts & Button
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NEXT PRAYER',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Asr',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '01:24:35',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'remaining',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'View Prayer Times',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white.withOpacity(0.9),
                          size: 10
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),

          // Middle Section: Sun Arc Graphic
          SizedBox(
            width: 140,
            height: 125,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                // Draw the Custom Dotted Arc & Inner Track
                Positioned(
                  top: 20,
                  child: CustomPaint(
                    size: const Size(140, 70), // Width 140, Height 70 (Semi-circle)
                    painter: SunArcPainter(progress: 0.65), // 65% day elapsed
                  ),
                ),
                // Precisely position the Sun icon on the arc
                Positioned(
                  left: (140 / 2) + (70 * cos(pi + pi * 0.65)) - 14, // Center + Radius * Cos(angle) - half icon size
                  top: 20 + (70 * sin(pi + pi * 0.65)) - 14,       // Top offset + Radius * Sin(angle) - half icon size
                  child: const Icon(
                    Icons.wb_sunny,
                    color: Color(0xFFFFD600),
                    size: 28,
                  ),
                ),
                // Time & Status Text below the arc
                Positioned(
                  bottom: 0,
                  child: Column(
                    children: [
                      const Text(
                        '4:25 PM',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14
                        ),
                      ),
                      Text(
                        'Today',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 11
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Right Section: Speaker Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: const Icon(
              Icons.volume_up,
              color: Colors.black87,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter to draw the exact dotted line and green progress bar
class SunArcPainter extends CustomPainter {
  final double progress;
  SunArcPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;

    // 1. Draw Dotted Outer Arc
    final dotPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    int dotCount = 26; // Number of dots across the semi-circle
    for (int i = 0; i <= dotCount; i++) {
      double angle = pi + (pi * (i / dotCount));
      double x = center.dx + radius * cos(angle);
      double y = center.dy + radius * sin(angle);
      canvas.drawCircle(Offset(x, y), 2.0, dotPaint);
    }

    // 2. Draw Inner Solid Track (Background)
    final innerRadius = radius - 14;
    final trackPaint = Paint()
      ..color = Colors.black.withOpacity(0.2) // Dark shade for remaining time
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    // 3. Draw Inner Progress Track (Elapsed Time)
    final progressPaint = Paint()
      ..color = const Color(0xFF2EA866) // Vibrant green color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    // Draw full background track
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: innerRadius),
      pi,
      pi,
      false,
      trackPaint,
    );

    // Draw green progress track
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: innerRadius),
      pi,
      pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}