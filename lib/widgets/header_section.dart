import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../constants/app_colors.dart';

class HeaderSection extends StatefulWidget {
  const HeaderSection({Key? key}) : super(key: key);

  @override
  State<HeaderSection> createState() => _HeaderSectionState();
}

class _HeaderSectionState extends State<HeaderSection> {
  String _currentLocation = "Detecting Location...";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _requestPermissionAndFetchLocation();
  }

  // App open howar sathe sathei Location Access chaibe
  Future<void> _requestPermissionAndFetchLocation() async {
    setState(() {
      _isLoading = true;
      _currentLocation = "Detecting Location...";
    });

    try {
      // ১. GPS on ache kina check korbe
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _currentLocation = "Turn on GPS (Tap to retry)";
          _isLoading = false;
        });
        return;
      }

      // ২. Permission check & request korbe (ekhanei popup asbe)
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission(); // Popup will appear here
        if (permission == LocationPermission.denied) {
          setState(() {
            _currentLocation = "Permission Denied";
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _currentLocation = "Location Disabled in Settings";
          _isLoading = false;
        });
        return;
      }

      // ৩. Location fetch korbe (City name er jonno 'low' ba 'medium' accuracy fast kaaj kore)
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium);

      // ৪. Latitude & Longitude theke city/country name ber korbe
      List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          String city = place.locality != null && place.locality!.isNotEmpty
              ? place.locality!
              : place.subAdministrativeArea ?? "Unknown City";
          String country = place.country ?? "";

          _currentLocation = "$city, $country";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _currentLocation = "Failed to get location";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Location Section (Clickable for retry)
              Expanded(
                child: GestureDetector(
                  onTap: _requestPermissionAndFetchLocation, // Tap korle abar try korbe
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on, color: AppColors.textDark, size: 20),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          _currentLocation,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      if (_isLoading)
                        const SizedBox(
                          height: 12,
                          width: 12,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryColor),
                        )
                      else
                        const Icon(Icons.keyboard_arrow_down, color: AppColors.textDark),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // Weather and Notification Section
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.wb_sunny, color: Colors.amber, size: 16),
                        const SizedBox(width: 6),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('30°C', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, height: 1.0)),
                            Text('Sunny', style: TextStyle(fontSize: 9, color: Colors.grey, height: 1.0)),
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
                          ],
                        ),
                        child: const Icon(Icons.notifications_outlined, color: AppColors.textDark, size: 22),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Text(
                            '3',
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Greeting Text
          const Text(
            'Assalamu Alaikum,',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
          const SizedBox(height: 4),
          Text(
            'May Allah bless your day',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}