import 'dart:convert';
import 'package:http/http.dart' as http;

class BackendService {
  // এমুলেটরের জন্য লোকালহোস্ট আইপি
  static const String baseUrl = 'https://a0d1-103-190-205-158.ngrok-free.app/travel_admin';

  // ক্যাটাগরি ফেচ করার ফাংশন
  static Future<List<dynamic>> fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get_categories.php'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    }
  }

  // প্লেস ফেচ করার ফাংশন
  static Future<List<dynamic>> fetchPlaces() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get_places.php'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load places');
      }
    } catch (e) {
      print('Error fetching places: $e');
      return [];
    }
  }



  static Future<List<dynamic>> fetchGuides() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2/travel_admin/get_guides.php'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return [];
    } catch (e) {
      print("Error fetching guides: $e");
      return [];
    }
  }

  static Future<List<dynamic>> fetchReviews() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2/travel_admin/get_reviews.php'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return [];
    } catch (e) {
      print("Error fetching reviews: $e");
      return [];
    }
  }
  static Future<dynamic> fetchMeetups() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2/travel_admin/get_meetups.php'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return [];
    } catch (e) {
      print("Error fetching meetups: $e");
      return [];
    }
  }




}