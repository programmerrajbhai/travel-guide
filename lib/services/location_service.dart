import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class LocationService {
  // আপনার Geoapify API Key এখানে দিন (যেমন: "ac1b...6d")
  static const String _geoapifyApiKey = "c39a5aa2e8f341b79dca99e2a4a3aeea";

  static Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }

    if (permission == LocationPermission.deniedForever) return null;

    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }


  static Future<String> getCityName(double lat, double lon) async {
    try {
      // Geoapify API ব্যবহার করে লাইভ লোকেশন থেকে শহরের নাম বের করা
      final url = Uri.parse(
          "https://api.geoapify.com/v1/geocode/reverse?lat=$lat&lon=$lon&apiKey=$_geoapifyApiKey");

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['features'] != null && data['features'].isNotEmpty) {
          final properties = data['features'][0]['properties'];

          // শহর না পেলে জেলা বা স্টেটের নাম নিবে
          String city = properties['city'] ?? properties['state'] ?? properties['county'] ?? "Unknown";
          String country = properties['country'] ?? "";

          return "$city, $country";
        }
      }
    } catch (e) {
      print("Error getting city from Geoapify: $e");
    }
    return "Unknown Location";
  }
}