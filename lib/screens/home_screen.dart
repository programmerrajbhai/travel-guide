import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:adhan/adhan.dart';
import '../../constants/app_colors.dart';
import '../../services/api_service.dart';
// আপনার আগের তৈরি করা উইজেটগুলো ইম্পোর্ট করুন
import '../../widgets/travel_assistant_card.dart';
import '../../widgets/quick_actions_section.dart';
import '../../widgets/map_preview_section.dart';
import '../services/location_service.dart';
import '../widgets/dynamic_categories.dart';
import '../widgets/dynamic_places.dart';
import '../widgets/top_hero_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // State Variables
  String _cityName = "Locating...";
  String _temperature = "--°F";
  String _weatherStatus = "Loading";

  String _nextPrayerName = "Loading";
  String _nextPrayerTime = "--:--";
  String _timeRemaining = "00:00:00";
  double _sunProgress = 0.0;

  List<dynamic> _nearbyMasjids = [];
  Timer? _prayerTimer;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _prayerTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeData() async {
    if (mounted) {
      setState(() => _cityName = "Locating...");
    }

    // ১. লাইভ জিপিএস লোকেশন ফেচ করা
    final position = await LocationService.getCurrentLocation();

    // লোকেশন না পেলে ডিফল্ট ঢাকা সেট করা
    double lat = position?.latitude ?? 23.8103;
    double lon = position?.longitude ?? 90.4125;

    // ২. শহরের নাম বের করা
    String city = await LocationService.getCityName(lat, lon);

    if (mounted) {
      setState(() {
        _cityName = city;
      });
    }

    // ৩. লাইভ লোকেশন দিয়ে ওয়েদার এবং নামাজের সময় সেট করা
    final weatherData = await ApiService.getWeather(lat, lon);
    if (mounted && weatherData != null) {
      setState(() {
        _temperature = "${weatherData['main']['temp'].round()}°C";
        _weatherStatus = weatherData['weather'][0]['main'];
      });
    }

    _setupPrayerTimes(lat, lon);
  }

  Future<void> _fetchWeatherAndCity(double lat, double lon) async {
    final city = await ApiService.getCityName(lat, lon);
    final weatherData = await ApiService.getWeather(lat, lon);

    if (mounted) {
      setState(() {
        _cityName = city;
        if (weatherData != null) {
          _temperature = "${weatherData['main']['temp'].round()}°F";
          _weatherStatus = weatherData['weather'][0]['main'];
        }
      });
    }
  }

  Future<void> _fetchMasjids(double lat, double lon) async {
    final masjids = await ApiService.getNearbyMasjids(lat, lon);
    if (mounted && masjids != null) {
      setState(() {
        _nearbyMasjids = masjids.take(2).toList(); // Show top 2
      });
    }
  }
  void _setupPrayerTimes(double lat, double lon) {
    final myCoordinates = Coordinates(lat, lon);
    final params = CalculationMethod.karachi.getParameters();
    params.madhab = Madhab.hanafi;

    _prayerTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();

      // Ajker prayer times calculate kora
      final prayerTimes = PrayerTimes.today(myCoordinates, params);
      var next = prayerTimes.nextPrayer();
      var nextPrayerDateTime = prayerTimes.timeForPrayer(next);

      // Jodi Isha er por hoy (Orthot ajker r kono namaz baki nai)
      if (next == Prayer.none) {
        // Agamikal er date ber kora
        final tomorrow = now.add(const Duration(days: 1));
        final tomorrowPrayerTimes = PrayerTimes(
            myCoordinates,
            DateComponents(tomorrow.year, tomorrow.month, tomorrow.day),
            params
        );
        // Next prayer hisabe agamikal er Fajr set kora
        next = Prayer.fajr;
        nextPrayerDateTime = tomorrowPrayerTimes.fajr;
      }

      if (nextPrayerDateTime != null && mounted) {
        final diff = nextPrayerDateTime.difference(now);

        // Time formatting
        String twoDigits(int n) => n.toString().padLeft(2, "0");
        String hours = twoDigits(diff.inHours);
        String minutes = twoDigits(diff.inMinutes.remainder(60));
        String seconds = twoDigits(diff.inSeconds.remainder(60));

        // Sun progress calculation
        double progress = 1.0 - (diff.inMinutes / (6 * 60));

        setState(() {
          _nextPrayerName = next.toString().split('.').last.toUpperCase();
          _timeRemaining = "$hours:$minutes:$seconds";
          _sunProgress = progress.clamp(0.0, 1.0);
        });
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dynamic Top Hero Section
              DynamicTopHeroSection(
                cityName: _cityName,
                temperature: _temperature,
                weatherStatus: _weatherStatus,
                nextPrayerName: _nextPrayerName,
                timeRemaining: _timeRemaining,
                sunProgress: _sunProgress,
              ),

              // ... আগের কোড
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    const TravelAssistantCard(),

                    const SizedBox(height: 28),
                    const DynamicCategories(), // <-- নতুন ক্যাটাগরি উইজেট

                    const SizedBox(height: 28),
                    const DynamicPlaces(), // <-- নতুন প্লেস উইজেট

                    const SizedBox(height: 28),
                    const MapPreviewSection(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
// ... পরের কোড
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicNearbyMasjids() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('NEARBY MASJIDS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark, letterSpacing: 0.5)),
            Text('View All', style: TextStyle(color: AppColors.primaryColor, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 16),
        if (_nearbyMasjids.isEmpty)
          const Center(child: CircularProgressIndicator())
        else
          ..._nearbyMasjids.map((masjid) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))]),
            child: Row(
              children: [
                Container(
                  width: 70, height: 70,
                  decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.mosque, color: Colors.grey),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(masjid['name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.orange, size: 14),
                          const SizedBox(width: 4),
                          Text('${masjid['rating'] ?? '4.5'}', style: const TextStyle(fontSize: 12, color: AppColors.textLight, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade200)),
                  child: const Icon(Icons.near_me_outlined, size: 18, color: AppColors.textDark),
                )
              ],
            ),
          )).toList(),
      ],
    );
  }
}