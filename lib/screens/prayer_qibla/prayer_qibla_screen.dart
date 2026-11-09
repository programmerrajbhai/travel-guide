import 'dart:async';
import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';
import '../../constants/app_colors.dart';
import '../../services/api_service.dart';
import '../../services/location_service.dart';
import 'widgets/prayer_header_card.dart';
import 'widgets/prayer_quick_actions.dart';
import 'widgets/prayer_times_list.dart';
import 'widgets/qibla_compass_section.dart';

class PrayerQiblaScreen extends StatefulWidget {
  const PrayerQiblaScreen({Key? key}) : super(key: key);

  @override
  State<PrayerQiblaScreen> createState() => _PrayerQiblaScreenState();
}

class _PrayerQiblaScreenState extends State<PrayerQiblaScreen> {
  String _locationName = "Locating...";
  Map<String, dynamic>? _prayerData;
  bool _isLoading = true;
  double _qiblaDirection = 0.0;
  double _makkahDistanceKm = 0.0;

  String _nextPrayerName = "Loading...";
  String _timeRemaining = "00:00:00";
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _fetchPrayerData();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchPrayerData() async {
    final position = await LocationService.getCurrentLocation();
    double lat = position?.latitude ?? 23.8103;
    double lon = position?.longitude ?? 90.4125;

    // মক্কার কোঅর্ডিনেট (কাবা শরীফ)
    const double makkahLat = 21.422487;
    const double makkahLng = 39.826206;

    // দূরত্ব ক্যালকুলেশন
    double distanceInMeters = Geolocator.distanceBetween(lat, lon, makkahLat, makkahLng);

    final city = await LocationService.getCityName(lat, lon);
    final data = await ApiService.getPrayerTimes(lat, lon);

    if (mounted) {
      setState(() {
        _locationName = city;
        _prayerData = data;
        // API থেকে কিবলা ডিরেকশন নেওয়া হচ্ছে
        _qiblaDirection = data?['meta']?['qiblaDirection']?.toDouble() ?? 245.0;
        _makkahDistanceKm = distanceInMeters / 1000;
        _isLoading = false;
      });
      _setupCountdown(lat, lon);
    }
  }

  void _setupCountdown(double lat, double lon) {
    final myCoordinates = Coordinates(lat, lon);
    final params = CalculationMethod.karachi.getParameters();
    params.madhab = Madhab.hanafi;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final prayerTimes = PrayerTimes.today(myCoordinates, params);
      var next = prayerTimes.nextPrayer();
      var nextPrayerTime = prayerTimes.timeForPrayer(next);

      if (next == Prayer.none) {
        final tomorrow = now.add(const Duration(days: 1));
        final tomorrowPrayerTimes = PrayerTimes(
            myCoordinates, DateComponents(tomorrow.year, tomorrow.month, tomorrow.day), params);
        next = Prayer.fajr;
        nextPrayerTime = tomorrowPrayerTimes.fajr;
      }

      if (nextPrayerTime != null && mounted) {
        final diff = nextPrayerTime.difference(now);
        String twoDigits(int n) => n.toString().padLeft(2, "0");
        String hours = twoDigits(diff.inHours);
        String minutes = twoDigits(diff.inMinutes.remainder(60));
        String seconds = twoDigits(diff.inSeconds.remainder(60));

        setState(() {
          _nextPrayerName = next.toString().split('.').last.toUpperCase();
          _timeRemaining = "$hours:$minutes:$seconds";
        });
      }
    });
  }

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
        title: const Text('Prayer & Qibla', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.settings_outlined, color: AppColors.textDark), onPressed: () {})
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
          : SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PrayerHeaderCard(
              locationName: _locationName,
              hijriDate: _prayerData?['date']?['hijri']?['date'] ?? "Islamic Date",
              nextPrayer: _nextPrayerName,
              timeRemaining: _timeRemaining,
            ),
            const SizedBox(height: 24),
            PrayerTimesList(timings: _prayerData?['timings']),
            const SizedBox(height: 24),
            // এখানে _qiblaDirection ডাটা পাস করা হচ্ছে
            PrayerQuickActions(qiblaDirection: _qiblaDirection),
            const SizedBox(height: 24),
            // এখানে ডিরেকশন এবং দূরত্ব পাস করা হচ্ছে
            QiblaCompassSection(direction: _qiblaDirection, distanceKm: _makkahDistanceKm),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}