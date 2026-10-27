import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import 'widgets/prayer_header_card.dart';
import 'widgets/prayer_times_list.dart';
import 'widgets/prayer_quick_actions.dart';
import 'widgets/qibla_compass_section.dart';

class PrayerQiblaScreen extends StatelessWidget {
  const PrayerQiblaScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text('Prayer & Qibla', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.settings_outlined, color: Colors.white), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            PrayerHeaderCard(),
            SizedBox(height: 24),
            PrayerTimesList(),
            SizedBox(height: 24),
            PrayerQuickActions(),
            SizedBox(height: 24),
            QiblaCompassSection(),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}