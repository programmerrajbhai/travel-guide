import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../services/api_service.dart';
import '../../services/location_service.dart';
class PrayerQiblaScreen extends StatefulWidget {
  const PrayerQiblaScreen({Key? key}) : super(key: key);
  @override
  State<PrayerQiblaScreen> createState() => _PrayerQiblaScreenState();
}
class _PrayerQiblaScreenState extends State<PrayerQiblaScreen> {
  bool _isLoading = true;
  String _locationName = "Locating...";
  Map<String, dynamic>? _prayerData;
  String _errorMessage = "";
  @override
  void initState() {
    super.initState();
    _fetchData();
  }
  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    try {
      // ১. ইউজারের লাইভ লোকেশন বের করা
      final position = await LocationService.getCurrentLocation();

      double lat = 23.8103; // ডিফল্ট ঢাকা (যদি ইউজার লোকেশন পারমিশন না দেয়)
      double lng = 90.4125;
      String city = "Dhaka, BD";

      if (position != null) {
        lat = position.latitude;
        lng = position.longitude;
        // ২. ল্যাটিচিউড-লঙ্গিচিউড থেকে আসল শহরের নাম বের করা
        city = await LocationService.getCityName(lat, lng);
      } else {
        city = "Dhaka, BD (Default)";
      }

      // ৩. Aladhan API থেকে সঠিক নামাজের সময় বের করা
      final data = await ApiService.getPrayerTimes(lat, lng);

      setState(() {
        _locationName = city;
        _prayerData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to load data. Please try again.";
        _isLoading = false;
      });
    }
  }
  String _formatTime(String time24) {
    try {
      final parts = time24.split(':');
      int hour = int.parse(parts[0]);
      final minute = parts[1];
      String period = hour >= 12 ? 'PM' : 'AM';

      if (hour == 0) {
        hour = 12;
      } else if (hour > 12) {
        hour -= 12;
      }
      return "${hour.toString().padLeft(2, '0')}:$minute $period";
    } catch (e) {
      return time24;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Prayer & Qibla',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF1B263B), letterSpacing: -0.5),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textDark),
            onPressed: _fetchData,
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: _buildBody(),
    );

  }
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF115C49)),
            SizedBox(height: 16),
            Text("Detecting your location...", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    if (_errorMessage.isNotEmpty || _prayerData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_off, size: 50, color: Colors.grey),
            const SizedBox(height: 16),
            Text(_errorMessage.isNotEmpty ? _errorMessage : "Failed to load prayer times", style: const TextStyle(color: Colors.grey)),
            TextButton(onPressed: _fetchData, child: const Text("Retry", style: TextStyle(color: Color(0xFF115C49)))),
          ],
        ),
      );
    }

    final timings = _prayerData!['timings'];
    final hijriDate = _prayerData!['date']['hijri'];
    final qiblaDirection = _prayerData!['meta']['qiblaDirection'];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Card (Islamic Date & Live Location)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF115C49), Color(0xFF1A7A62)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: const Color(0xFF115C49).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Today's Prayers", style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w600)),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Icon(Icons.location_on, color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              _locationName,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  "${hijriDate['day']} ${hijriDate['month']['en']} ${hijriDate['year']}",
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  hijriDate['designation']['expanded'],
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // 2. Prayer Times List
          const Text('Prayer Times', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF1B263B))),
          const SizedBox(height: 16),
          _buildPrayerTile("Fajr", timings['Fajr'], Icons.nights_stay_outlined),
          _buildPrayerTile("Sunrise", timings['Sunrise'], Icons.wb_twilight_outlined),
          _buildPrayerTile("Dhuhr", timings['Dhuhr'], Icons.wb_sunny_outlined),
          _buildPrayerTile("Asr", timings['Asr'], Icons.cloud_outlined),
          _buildPrayerTile("Maghrib", timings['Maghrib'], Icons.wb_twilight_rounded),
          _buildPrayerTile("Isha", timings['Isha'], Icons.nightlight_round),
          const SizedBox(height: 32),

          // 3. Qibla Direction Info
          const Text('Qibla Compass', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF1B263B))),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFF115C49).withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.explore, color: Color(0xFF115C49), size: 32),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Qibla Angle", style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(
                        "${(qiblaDirection as num).toStringAsFixed(2)}°",
                        style: const TextStyle(color: AppColors.textDark, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 100), // Bottom padding for Nav Bar
        ],
      ),
    );
  }
  Widget _buildPrayerTile(String name, dynamic time24, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF115C49), size: 24),
              const SizedBox(width: 16),
              Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark)),
            ],
          ),
          Text(
            _formatTime(time24.toString()),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
        ],
      ),
    );
  }
}