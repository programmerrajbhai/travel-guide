import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../../constants/app_colors.dart';
import '../../services/api_service.dart';
import '../place_map_screen.dart';
import '../business_detail/business_detail_screen.dart';

class TravelModeScreen extends StatefulWidget {
  const TravelModeScreen({Key? key}) : super(key: key);

  @override
  State<TravelModeScreen> createState() => _TravelModeScreenState();
}

class _TravelModeScreenState extends State<TravelModeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  bool _isSearchingLocations = false;

  String _destinationName = "";
  String _destinationFullAddress = "";
  double? _destLat;
  double? _destLng;

  List<dynamic> _locationSuggestions = [];
  Map<String, dynamic>? _prayerTimes;
  List<dynamic> _destinationMosques = [];

  // ১. শহরের নামের সাজেশন আনা (যাতে রংপুর সার্চ দিলে বাংলাদেশ সিলেক্ট করা যায়)
  Future<void> _fetchLocationSuggestions(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _locationSuggestions = []);
      return;
    }

    setState(() => _isSearchingLocations = true);

    try {
      // বাংলাদেশের লোকেশনকে প্রাধান্য দেওয়ার সাথে গ্লোবাল সার্চ (limit=6)
      final encodedQuery = Uri.encodeComponent(query.trim());
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$encodedQuery&format=json&addressdetails=1&limit=6',
      );
      final response = await http.get(
        url,
        headers: {'User-Agent': 'HalalTravelGuideApp/1.0'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // বাংলাদেশের লোকেশনগুলোকে লিস্টের উপরে দেখানোর জন্য সর্টিং
        data.sort((a, b) {
          final aCountry = a['address']?['country']?.toString().toLowerCase() ?? '';
          final bCountry = b['address']?['country']?.toString().toLowerCase() ?? '';
          if (aCountry.contains('bangladesh') && !bCountry.contains('bangladesh')) return -1;
          if (!aCountry.contains('bangladesh') && bCountry.contains('bangladesh')) return 1;
          return 0;
        });

        if (mounted) {
          setState(() {
            _locationSuggestions = data;
            _isSearchingLocations = false;
          });
        }
        return;
      }
    } catch (e) {
      debugPrint("Suggestion Error: $e");
    }

    if (mounted) {
      setState(() => _isSearchingLocations = false);
    }
  }

  // ২. নির্দিষ্ট গন্তব্য সিলেক্ট করলে সেখানকার নামাজের সময় ও লাইভ মসজিদ লোড করা
  Future<void> _selectDestination(dynamic locationData) async {
    FocusScope.of(context).unfocus();

    double lat = double.tryParse(locationData['lat'].toString()) ?? 0.0;
    double lng = double.tryParse(locationData['lon'].toString()) ?? 0.0;
    String displayName = locationData['display_name'].toString();
    String shortName = locationData['name']?.toString() ?? displayName.split(',')[0];

    setState(() {
      _locationSuggestions = [];
      _searchController.text = shortName;
      _isLoading = true;
      _destinationName = shortName;
      _destinationFullAddress = displayName;
      _destLat = lat;
      _destLng = lng;
    });

    try {
      // গন্তব্যের নামাজের সময় এবং লাইভ মসজিদ একসাথে ফেচ করা
      final results = await Future.wait([
        ApiService.getPrayerTimes(lat, lng),
        _fetchLiveMosquesAroundDestination(lat, lng),
      ]);

      if (mounted) {
        setState(() {
          _prayerTimes = results[0] as Map<String, dynamic>?;
          _destinationMosques = results[1] as List<dynamic>;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Load Destination Data Error: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ৩. সরাসরি তীর বাটনে বা কিবোর্ড এন্টার চাপলে প্রথম সঠিক লোকেশনটি সিলেক্ট করা
  Future<void> _directSearch(String query) async {
    if (query.trim().isEmpty) return;
    await _fetchLocationSuggestions(query);
    if (_locationSuggestions.isNotEmpty) {
      await _selectDestination(_locationSuggestions.first);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Destination not found. Try another city name.')),
        );
      }
    }
  }

  // ৪. OpenStreetMap Overpass API দিয়ে গন্তব্যের আশেপাশের আসল মসজিদ খুঁজে বের করা
  Future<List<dynamic>> _fetchLiveMosquesAroundDestination(double lat, double lng) async {
    try {
      // ৫০০০ মিটার (৫ কিমি) রেডিয়াসের মধ্যে সব মসজিদ খোঁজার Overpass Query
      final overpassQuery = '''
        [out:json][timeout:25];
        (
          node["amenity"="place_of_worship"]["religion"="muslim"](around:5000,$lat,$lng);
          way["amenity"="place_of_worship"]["religion"="muslim"](around:5000,$lat,$lng);
        );
        out center 20;
      ''';

      final url = Uri.parse(
        'https://overpass-api.de/api/interpreter?data=${Uri.encodeComponent(overpassQuery)}',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final List<dynamic> elements = data['elements'] ?? [];

        List<dynamic> mosques = [];
        for (var el in elements) {
          final tags = el['tags'] ?? {};
          double? mLat = el['lat'] != null
              ? double.tryParse(el['lat'].toString())
              : (el['center'] != null ? double.tryParse(el['center']['lat'].toString()) : null);
          double? mLng = el['lon'] != null
              ? double.tryParse(el['lon'].toString())
              : (el['center'] != null ? double.tryParse(el['center']['lon'].toString()) : null);

          if (mLat != null && mLng != null) {
            String name = tags['name:en']?.toString() ??
                tags['name']?.toString() ??
                tags['name:bn']?.toString() ??
                'Local Jumu\'ah Masjid';

            double distMeters = Geolocator.distanceBetween(lat, lng, mLat, mLng);
            double distKm = distMeters / 1000.0;

            mosques.add({
              'name': name,
              'category_name': 'Masjid',
              'latitude': mLat,
              'longitude': mLng,
              'distance': distKm,
              'address': tags['addr:full']?.toString() ??
                  tags['addr:street']?.toString() ??
                  'Near $_destinationName',
              'description':
              'Mosque located ${distKm.toStringAsFixed(2)} km from $_destinationName center. Daily 5 waqt prayers and Jumu\'ah congregation held here.',
              'image':
              'https://images.unsplash.com/photo-1584551246679-0daf3d275d0f?auto=format&fit=crop&w=600&q=80',
            });
          }
        }

        // সবচেয়ে কাছের মসজিদগুলো আগে দেখানোর জন্য সর্ট করা
        mosques.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));
        return mosques;
      }
    } catch (e) {
      debugPrint("Overpass Mosque Fetch Error: $e");
    }
    return [];
  }

  String _formatTime(String? time24) {
    if (time24 == null) return "--:--";
    try {
      final cleanTime = time24.split(' ')[0];
      final parts = cleanTime.split(':');
      int hour = int.parse(parts[0]);
      final minute = parts[1];
      String period = hour >= 12 ? 'PM' : 'AM';
      if (hour == 0) {
        hour = 12;
      } else if (hour > 12) {
        hour -= 12;
      }
      return "$hour:$minute $period";
    } catch (e) {
      return time24;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF115C49),
        elevation: 0,
        title: const Text(
          'Smart Travel Assistant',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Search Bar & Dropdown Section
          Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
            decoration: const BoxDecoration(
              color: Color(0xFF115C49),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    if (val.length >= 2) {
                      _fetchLocationSuggestions(val);
                    } else {
                      setState(() => _locationSuggestions = []);
                    }
                  },
                  onSubmitted: _directSearch,
                  style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    hintText: 'Search Destination (e.g. Rangpur, Sylhet)',
                    hintStyle: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.normal),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF115C49)),
                    suffixIcon: _isSearchingLocations
                        ? const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF115C49)),
                      ),
                    )
                        : IconButton(
                      icon: const Icon(Icons.arrow_circle_right, color: Color(0xFF115C49), size: 30),
                      onPressed: () => _directSearch(_searchController.text),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                // লোকেশন সাজেশন ড্রপডাউন (যাতে ভুল শহর সিলেক্ট না হয়)
                if (_locationSuggestions.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    constraints: const BoxConstraints(maxHeight: 220),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 15, offset: const Offset(0, 5))
                      ],
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _locationSuggestions.length,
                      separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade200),
                      itemBuilder: (context, index) {
                        final item = _locationSuggestions[index];
                        final display = item['display_name'].toString();
                        return ListTile(
                          dense: true,
                          leading: const Icon(Icons.location_on, color: Color(0xFF115C49)),
                          title: Text(
                            display.split(',')[0],
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark),
                          ),
                          subtitle: Text(
                            display,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          onTap: () => _selectDestination(item),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // Main Body Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF115C49)))
                : _destinationName.isEmpty
                ? _buildEmptyState()
                : _buildTripDetails(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF1ED),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.explore_outlined, size: 64, color: Color(0xFF115C49)),
            ),
            const SizedBox(height: 20),
            Text(
              'Plan Your Halal Trip',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Type any city or area name above to get accurate prayer times and discover real mosques around your destination.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripDetails() {
    final timings = _prayerTimes?['timings'];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ১. গন্তব্যের হেডার কার্ড
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F4C36), Color(0xFF1B6A4E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: const Color(0xFF115C49).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.location_on, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'YOUR DESTINATION',
                        style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _destinationName,
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _destinationFullAddress,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // ২. গন্তব্যের নামাজের সময়সূচী
          const Text(
            'PRAYER TIMES AT DESTINATION',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark, letterSpacing: 0.8),
          ),
          const SizedBox(height: 14),
          if (timings != null)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildPrayerBox('Fajr', timings['Fajr']?.toString(), Icons.wb_twilight, const Color(0xFF3949AB)),
                  _buildPrayerBox('Dhuhr', timings['Dhuhr']?.toString(), Icons.wb_sunny, const Color(0xFFFB8C00)),
                  _buildPrayerBox('Asr', timings['Asr']?.toString(), Icons.wb_cloudy, const Color(0xFF039BE5)),
                  _buildPrayerBox('Maghrib', timings['Maghrib']?.toString(), Icons.nights_stay_outlined, const Color(0xFFE53935)),
                  _buildPrayerBox('Isha', timings['Isha']?.toString(), Icons.nights_stay, const Color(0xFF5E35B1)),
                ],
              ),
            ),
          const SizedBox(height: 28),

          // ৩. গন্তব্যের আশেপাশের মসজিদ এবং জামাতের/ওয়াক্তের সময়
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'MOSQUES AROUND DESTINATION',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark, letterSpacing: 0.8),
              ),
              Text(
                '${_destinationMosques.length} Found',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF115C49)),
              ),
            ],
          ),
          const SizedBox(height: 14),

          if (_destinationMosques.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: const [
                  Icon(Icons.mosque_outlined, size: 48, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    "No mapped mosques found within 5 km.",
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _destinationMosques.length,
              itemBuilder: (context, index) {
                final mosque = _destinationMosques[index];
                final double distanceKm = mosque['distance'] as double;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAF1ED),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.mosque, color: Color(0xFF115C49), size: 30),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  mosque['name'].toString(),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.directions_walk, size: 14, color: Color(0xFF115C49)),
                                    const SizedBox(width: 4),
                                    Text(
                                      "${distanceKm.toStringAsFixed(2)} km from destination",
                                      style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PlaceMapScreen(
                                    placeName: mosque['name'].toString(),
                                    latitude: mosque['latitude'] as double,
                                    longitude: mosque['longitude'] as double,
                                  ),
                                ),
                              );
                            },
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF115C49),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.directions, size: 18, color: Colors.white),
                            ),
                          ),
                        ],
                      ),

                      // প্রতিটি মসজিদের কার্ডের ভেতরেই নামাজের ওয়াক্তের ব্যাজ
                      if (timings != null) ...[
                        const SizedBox(height: 14),
                        const Divider(height: 1),
                        const SizedBox(height: 10),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildMiniPrayerChip('Fajr', _formatTime(timings['Fajr']?.toString())),
                              _buildMiniPrayerChip('Dhuhr', _formatTime(timings['Dhuhr']?.toString())),
                              _buildMiniPrayerChip('Asr', _formatTime(timings['Asr']?.toString())),
                              _buildMiniPrayerChip('Maghrib', _formatTime(timings['Maghrib']?.toString())),
                              _buildMiniPrayerChip('Isha', _formatTime(timings['Isha']?.toString())),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildMiniPrayerChip(String label, String time) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7F6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF115C49)),
          ),
          Text(
            time,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textDark),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerBox(String name, String? time24, IconData icon, Color color) {
    return Container(
      width: 105,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 10),
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark)),
          const SizedBox(height: 4),
          Text(
            _formatTime(time24),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: color),
          ),
        ],
      ),
    );
  }
}