import 'package:flutter/material.dart';
import '../../widgets/live_guide_panel.dart';

class PrayerQiblaScreen extends StatelessWidget {
  const PrayerQiblaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prayer & Qibla')),
      body: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: LiveGuidePanel(view: GuideView.prayer),
        ),
      ),
    );
  }
}