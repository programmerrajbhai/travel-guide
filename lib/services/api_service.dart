import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ApiService {
  // ১. ওয়েদার ডেটা ফেচ করা
  static Future<Map<String, dynamic>?> getWeather(double lat, double lon) async {
    try {
      final url = '${ApiConfig.weatherBaseUrl}?lat=$lat&lon=$lon&appid=${ApiConfig.weatherApiKey}&units=imperial'; // units=imperial for Fahrenheit
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print("Weather API Error: $e");
    }
    return null;
  }

  // ২. কাছাকাছি মসজিদ ফেচ করা
  static Future<List<dynamic>?> getNearbyMasjids(double lat, double lon) async {
    try {
      final url = '${ApiConfig.googlePlacesUrl}?location=$lat,$lon&radius=5000&type=mosque&keyword=islamic+center&key=${ApiConfig.googleApiKey}';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['results'];
      }
    } catch (e) {
      print("Places API Error: $e");
    }
    return null;
  }

  // ৩. ল্যাটিচিউড-লঙ্গিচিউড থেকে শহরের নাম বের করা
  static Future<String> getCityName(double lat, double lon) async {
    try {
      final url = '${ApiConfig.googleGeocodingUrl}?latlng=$lat,$lon&key=${ApiConfig.googleApiKey}';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'].isNotEmpty) {
          // Extracting city/locality name
          for (var component in data['results'][0]['address_components']) {
            if (component['types'].contains('locality')) {
              return component['long_name'];
            }
          }
        }
      }
    } catch (e) {
      print("Geocoding Error: $e");
    }
    return "Unknown Location";
  }
}