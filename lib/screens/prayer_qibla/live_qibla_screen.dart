import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'dart:math' as math;
import '../../constants/app_colors.dart';

class LiveQiblaScreen extends StatelessWidget {
  final double qiblaDirection;

  const LiveQiblaScreen({Key? key, required this.qiblaDirection}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Live Qibla Guidance', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: StreamBuilder<CompassEvent>(
        stream: FlutterCompass.events,
        builder: (context, snapshot) {
          double? heading;

          if (snapshot.hasError) {
            // সেন্সর এরর হলে ডিফল্ট ডিরেকশন দেখাবে
            heading = 0.0;
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryColor));
          } else {
            // ইমুলেটরে ডাটা না পেলে ডিফল্ট 0.0 ধরবে, আসল ফোনে রিয়েল ডাটা নিবে
            heading = snapshot.data?.heading ?? 0.0;
          }

          // ডিরেকশন ক্যালকুলেশন
          double compassAngle = -heading * (math.pi / 180);
          double qiblaNeedleAngle = (qiblaDirection - heading) * (math.pi / 180);

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${heading.toStringAsFixed(0)}°',
                style: const TextStyle(fontSize: 50, fontWeight: FontWeight.w900, color: AppColors.textDark),
              ),
              const SizedBox(height: 10),
              const Text('Align the Green Arrow to the top', style: TextStyle(color: AppColors.textLight, fontSize: 16)),
              const SizedBox(height: 60),
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // কম্পাসের ব্যাকগ্রাউন্ড
                    Transform.rotate(
                      angle: compassAngle,
                      child: Container(
                        width: 300, height: 300,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.shade300, width: 2),
                            color: Colors.white,
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))]
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Positioned(top: 15, child: Text('N', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red.shade400))),
                            Positioned(bottom: 15, child: Text('S', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey.shade400))),
                            Positioned(left: 15, child: Text('W', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey.shade400))),
                            Positioned(right: 15, child: Text('E', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey.shade400))),
                          ],
                        ),
                      ),
                    ),
                    // কিবলার নিডল (তীর)
                    Transform.rotate(
                      angle: qiblaNeedleAngle,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(Icons.arrow_upward_rounded, size: 140, color: Color(0xFF0F4C36)),
                          Positioned(
                              top: -10,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(color: Color(0xFF0F4C36), shape: BoxShape.circle),
                                child: const Icon(Icons.mosque, color: Colors.white, size: 24),
                              )
                          )
                        ],
                      ),
                    ),
                    // মাঝখানের গোল বিন্দু
                    Container(
                      width: 20, height: 20,
                      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: const Color(0xFF0F4C36), width: 5)),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 80),
            ],
          );
        },
      ),
    );
  }
}