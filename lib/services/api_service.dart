import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ApiService {
  // 1. Weather Data (Mocking for now to show UI)
  static Future<dynamic> getWeather(double lat, double lon) async {
    // API key na thakai ami ekta fake response dicchi jate UI show kore
    return {
      'main': {'temp': 28.5}, // 28.5 Celsius
      'weather': [{'main': 'Clear'}]
    };
  }

  // 2. Nearby Mosque (Mocking using dummy data)
  static Future<dynamic> getNearbyMasjids(double lat, double lon) async {
    // API key na thakai fake kacher 2ta mosque dicchi
    return [


      {
        'name': 'Baitul Mukarram National Mosque',
        'rating': '4.8',
        'latitude': 23.7276,
        'longitude': 90.4125
      },
      {
        'name': 'Gulshan Society Mosque',
        'rating': '4.6',
        'latitude': 23.7937,
        'longitude': 90.4143
      }



    ];
  }

  // 3. City Name
  static Future<String> getCityName(double lat, double lon) async {
    // Google API kaj na korle default Dhaka return korbe
    return "Dhaka, BD";
  }

  // 4. Aladhan API - Get Prayer Times (Eta kaj korbe karon ekhane key lagbe na)
  static Future<dynamic> getPrayerTimes(double lat, double lng) async {
    try {
      final date = DateTime.now();
      final formattedDate = "${date.day}-${date.month}-${date.year}";

      final url = Uri.parse('https://api.aladhan.com/v1/timings/$formattedDate?latitude=$lat&longitude=$lng&method=1');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      } else {
        print("Aladhan API Error: ${response.statusCode}");
        return null;
      }


    } catch (e) {
      print("Exception in getPrayerTimes: $e");
      return null;
    }
  }
}