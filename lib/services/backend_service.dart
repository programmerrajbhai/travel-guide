import 'dart:convert';
import 'package:flutter/cupertino.dart';
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


// স্পেসিফিক প্লেসের জন্য রিভিউ আনার ফাংশন
  static Future<List<dynamic>> fetchReviewsForPlace(String placeName) async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/get_reviews.php'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['status'] == 'success') {
          List<dynamic> allReviews = data['data'];
          // শুধু ঐ স্পেসিফিক প্লেসের রিভিউগুলো ফিল্টার করে রিটার্ন করা হচ্ছে
          return allReviews.where((review) =>
          review['place_name'].toString().toLowerCase() == placeName.toLowerCase()
          ).toList();
        }
      }
    } catch (e) {
      debugPrint("Reviews Error: $e");
    }
    return [];
  }


  // স্পেসিফিক প্লেসের জন্য মেনু আনার ফাংশন
  static Future<List<dynamic>> fetchMenusForPlace(String placeName) async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/get_menus.php'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['status'] == 'success') {
          List<dynamic> allMenus = data['data'];
          return allMenus.where((m) => m['place_name'].toString().toLowerCase() == placeName.toLowerCase()).toList();
        }
      }
    } catch (e) {
      debugPrint("Menus Error: $e");
    }
    return [];
  }


}