import 'package:geolocator/geolocator.dart';
import 'api_service.dart';

class LocationService {
  // ১. ইউজারের বর্তমান লাইভ লোকেশন বের করার মেথড
  static Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // লোকেশন সার্ভিস অন আছে কিনা চেক করা
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("Location services are disabled.");
      return null;
    }

    // লোকেশন পারমিশন চেক করা
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("Location permissions are denied");
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print("Location permissions are permanently denied.");
      return null;
    }

    // সবকিছু ঠিক থাকলে লাইভ পজিশন রিটার্ন করা
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  // ২. শহরের নাম বের করার মেথড (যা home_screen.dart খুঁজছে)
  static Future<String> getCityName(double lat, double lon) async {
    // এটি সরাসরি ApiService থেকে শহরের নাম নিয়ে আসবে
    return await ApiService.getCityName(lat, lon);
  }

}