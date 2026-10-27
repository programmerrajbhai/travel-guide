import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class DynamicTopHeroSection extends StatelessWidget {
  final String cityName;
  final String temperature;
  final String weatherStatus;
  final String nextPrayerName;
  final String timeRemaining;
  final double sunProgress;

  const DynamicTopHeroSection({
    Key? key,
    required this.cityName,
    required this.temperature,
    required this.weatherStatus,
    required this.nextPrayerName,
    required this.timeRemaining,
    required this.sunProgress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          right: 0,
          top: 30,
          child: Image.network(
            'https://cdn3d.iconscout.com/3d/premium/thumb/mosque-5353597-4468685.png',
            width: screenWidth * 0.45,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const SizedBox(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildPrayerCard(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: AppColors.textDark),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      cityName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.textDark),
                ],
              ),
              const SizedBox(height: 14),
              const Text('Assalamu Alaikum,', style: TextStyle(fontSize: 13, color: AppColors.textDark, fontWeight: FontWeight.w500)),
             // const Text('MUSLIM', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5, color: AppColors.textDark)),
              const SizedBox(height: 2),
              const Text('May Allah bless your day', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
            ],
          ),
        ),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.15), blurRadius: 10, spreadRadius: 1)],
              ),
              child: Row(
                children: [
                  const Icon(Icons.wb_sunny, color: Color(0xFFFFB300), size: 16),
                  const SizedBox(width: 6),
                  Text('$temperature\n$weatherStatus', style: const TextStyle(fontSize: 10, height: 1.1, fontWeight: FontWeight.w600, color: AppColors.textDark), textAlign: TextAlign.center),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.15), blurRadius: 10)],
                  ),
                  child: const Icon(Icons.notifications_none, size: 20, color: AppColors.textDark),
                ),
                Positioned(
                  right: -2,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(color: Color(0xFFE53935), shape: BoxShape.circle),
                    child: const Text('3', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            )
          ],
        )
      ],
    );
  }

  Widget _buildPrayerCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.primaryColor.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('NEXT PRAYER', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.0)),
                const SizedBox(height: 6),
                Text(nextPrayerName, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800, height: 1.0)),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(timeRemaining, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                ),
                Text('remaining', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.12), borderRadius: BorderRadius.circular(24)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Flexible(
                        child: Text('View Prayer Times', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(width: 6),
                      Icon(Icons.arrow_forward_ios, color: Colors.white.withOpacity(0.9), size: 10),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  height: 65,
                  width: 110,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        bottom: 0,
                        child: CustomPaint(
                          size: const Size(110, 55),
                          painter: SunArcPainter(progress: sunProgress),
                        ),
                      ),
                      Positioned(
                        left: (110 / 2) + (55 * cos(pi + pi * sunProgress)) - 10,
                        bottom: (55 * sin(pi + pi * sunProgress)) - 10,
                        child: const Icon(Icons.wb_sunny, color: Color(0xFFFFD600), size: 20),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                const Text('Time', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)), // Can pass exact time if needed
                Text('Today', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
            child: const Icon(Icons.volume_up, color: Colors.black87, size: 18),
          ),
        ],
      ),
    );
  }
}

class SunArcPainter extends CustomPainter {
  final double progress;
  SunArcPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;

    final dotPaint = Paint()..color = Colors.white.withOpacity(0.5)..style = PaintingStyle.fill;
    int dotCount = 20;
    for (int i = 0; i <= dotCount; i++) {
      double angle = pi + (pi * (i / dotCount));
      double x = center.dx + radius * cos(angle);
      double y = center.dy + radius * sin(angle);
      canvas.drawCircle(Offset(x, y), 1.5, dotPaint);
    }

    final innerRadius = radius - 12;
    final trackPaint = Paint()..color = Colors.black.withOpacity(0.2)..style = PaintingStyle.stroke..strokeWidth = 3.0..strokeCap = StrokeCap.round;
    final progressPaint = Paint()..color = const Color(0xFF2EA866)..style = PaintingStyle.stroke..strokeWidth = 3.0..strokeCap = StrokeCap.round;

    canvas.drawArc(Rect.fromCircle(center: center, radius: innerRadius), pi, pi, false, trackPaint);
    canvas.drawArc(Rect.fromCircle(center: center, radius: innerRadius), pi, pi * progress, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}