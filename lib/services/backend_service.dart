import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class BackendService {
  // এমুলেটরের জন্য 'http://10.0.2.2/travel_admin' ব্যবহার করুন।
  // রিয়েল ডিভাইসের জন্য আপনার ngrok বা লোকাল IP দিন।
  static const String baseUrl = 'http://10.0.2.2/travel_admin';

  // ================= 1. Fetch Categories =================
  static Future<List<dynamic>> fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get_categories.php'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    }
    return [];
  }

  // ================= 2. Fetch Places =================
  static Future<List<dynamic>> fetchPlaces() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get_places.php'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      debugPrint('Error fetching places: $e');
    }
    return [];
  }

  // ================= 3. Fetch City Guides =================
  static Future<List<dynamic>> fetchGuides() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get_guides.php'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') return data['data'];
      }
    } catch (e) {
      debugPrint("Error fetching guides: $e");
    }
    return [];
  }

  // ================= 4. Fetch All Reviews =================
  static Future<List<dynamic>> fetchReviews() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get_reviews.php'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') return data['data'];
      }
    } catch (e) {
      debugPrint("Error fetching reviews: $e");
    }
    return [];
  }

  // ================= 5. Fetch Meetups =================
  static Future<List<dynamic>> fetchMeetups() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get_meetups.php'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') return data['data'];
      }
    } catch (e) {
      debugPrint("Error fetching meetups: $e");
    }
    return [];
  }

  // ================= 6. Fetch Reviews for a Specific Place =================
  static Future<List<dynamic>> fetchReviewsForPlace(String placeName) async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/get_reviews.php'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['status'] == 'success') {
          List<dynamic> allReviews = data['data'];
          // Filter reviews by matching the place name
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

  // ================= 7. NEW: Fetch Items (Menu/Product/Facility) for a Specific Place =================
  static Future<List<dynamic>> fetchItemsForPlace(String placeName) async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/get_items.php'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['status'] == 'success') {
          List<dynamic> allItems = data['data'];
          // Filter items by matching the place name
          return allItems.where((item) =>
          item['place_name'].toString().toLowerCase() == placeName.toLowerCase()
          ).toList();
        }
      }
    } catch (e) {
      debugPrint("Items Error: $e");
    }
    return [];
  }
}