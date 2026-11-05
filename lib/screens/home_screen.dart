import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:adhan/adhan.dart';
import '../../constants/app_colors.dart';
import '../../services/api_service.dart';
import '../../services/location_service.dart';
import '../../widgets/travel_assistant_card.dart';
import '../../widgets/quick_actions_section.dart';
import '../../widgets/map_preview_section.dart';
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
  String _temperature = "--°C";
  String _weatherStatus = "Loading";

  String _nextPrayerName = "Loading";
  String _nextPrayerTime = "--:--";
  String _timeRemaining = "00:00:00";
  double _sunProgress = 0.0;

  List<dynamic> _nearbyMasjids = [];
  Timer? _prayerTimer;
  bool _isLoadingMasjids = true;

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
    // ১. লাইভ জিপিএস লোকেশন ফেচ করা
    final position = await LocationService.getCurrentLocation();

    // লোকেশন না পেলে ডিফল্ট ঢাকা সেট করা
    double lat = position?.latitude ?? 23.8103;
    double lon = position?.longitude ?? 90.4125;

    // ২. শহরের নাম, ওয়েদার এবং কাছাকাছি মসজিদ ফেচ করা
    _fetchLocationData(lat, lon);

    // ৩. নামাজের সময় সেট করা
    _setupPrayerTimes(lat, lon);
  }

  Future<void> _fetchLocationData(double lat, double lon) async {
    // API Call গুলো একসাথে করা
    final city = await LocationService.getCityName(lat, lon);
    final weatherData = await ApiService.getWeather(lat, lon);
    final masjids = await ApiService.getNearbyMasjids(lat, lon);

    if (mounted) {
      setState(() {
        _cityName = city;

        if (weatherData != null) {
          // ওয়েদার API থেকে Fahrenheit-এ ডাটা আসলে Celsius-এ কনভার্ট করা
          double tempF = weatherData['main']['temp'].toDouble();
          double tempC = (tempF - 32) * 5 / 9;
          _temperature = "${tempC.round()}°C";
          _weatherStatus = weatherData['weather'][0]['main'];
        }

        if (masjids != null) {
          _nearbyMasjids = masjids.take(2).toList();
        }
        _isLoadingMasjids = false;
      });
    }
  }

  void _setupPrayerTimes(double lat, double lon) {
    final myCoordinates = Coordinates(lat, lon);
    final params = CalculationMethod.karachi.getParameters();
    params.madhab = Madhab.hanafi;

    _prayerTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final prayerTimes = PrayerTimes.today(myCoordinates, params);
      var next = prayerTimes.nextPrayer();
      var nextPrayerDateTime = prayerTimes.timeForPrayer(next);

      if (next == Prayer.none) {
        final tomorrow = now.add(const Duration(days: 1));
        final tomorrowPrayerTimes = PrayerTimes(
            myCoordinates,
            DateComponents(tomorrow.year, tomorrow.month, tomorrow.day),
            params
        );
        next = Prayer.fajr;
        nextPrayerDateTime = tomorrowPrayerTimes.fajr;
      }

      if (nextPrayerDateTime != null && mounted) {
        final diff = nextPrayerDateTime.difference(now);

        String twoDigits(int n) => n.toString().padLeft(2, "0");
        String hours = twoDigits(diff.inHours);
        String minutes = twoDigits(diff.inMinutes.remainder(60));
        String seconds = twoDigits(diff.inSeconds.remainder(60));

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

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    const TravelAssistantCard(),

                    const SizedBox(height: 28),
                    const QuickActionsSection(), // Quick Actions (Mosque, Qibla, etc.)

                    const SizedBox(height: 28),
                    const DynamicCategories(),

                    const SizedBox(height: 28),
                    const DynamicPlaces(),

                    const SizedBox(height: 28),
                    _buildDynamicNearbyMasjids(), // লাইভ নিয়ারবাই মসজিদ

                    const SizedBox(height: 28),
                    const MapPreviewSection(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
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
        if (_isLoadingMasjids)
          const Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
        else if (_nearbyMasjids.isEmpty)
          const Center(child: Text("No masjids found nearby.", style: TextStyle(color: Colors.grey)))
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
                  child: const Icon(Icons.mosque, color: Colors.grey, size: 30),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(masjid['name'] ?? 'Unknown Mosque', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark), maxLines: 1, overflow: TextOverflow.ellipsis),
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