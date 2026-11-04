import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'home_screen.dart';
import 'explore/explore_screen.dart';
import 'map_discover/map_discover_screen.dart';
import 'community/community_screen.dart';
import 'profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ExploreScreen(),
    const MapDiscoverScreen(),
    const CommunityScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _screens[_currentIndex],
      bottomNavigationBar: _buildFloatingBottomNav(),
    );
  }

  Widget _buildFloatingBottomNav() {
    return SafeArea(
      child: Container(
        // ৫টি আইটেমের জন্য বাইরের মার্জিন একটু কমিয়ে দেওয়া হয়েছে (20 থেকে 12)
        margin: const EdgeInsets.only(left: 12, right: 12, bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 10))
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavItem(Icons.home_outlined, Icons.home, 'Home', 0),
            _buildNavItem(Icons.search_outlined, Icons.search, 'Explore', 1),
            _buildNavItem(Icons.map_outlined, Icons.map, 'Map', 2),
            _buildNavItem(Icons.people_outline, Icons.people, 'Social', 3),
            _buildNavItem(Icons.person_outline, Icons.person, 'Profile', 4),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData outlineIcon, IconData filledIcon, String label, int index) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        // আনসিলেক্টেড অবস্থায় প্যাডিং কমিয়ে স্পেস বাঁচানো হয়েছে
        padding: EdgeInsets.symmetric(horizontal: isSelected ? 12 : 8, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min, // এটি ওভারফ্লো ঠেকানোর জন্য খুব জরুরি
          children: [
            Icon(
              isSelected ? filledIcon : outlineIcon,
              color: isSelected ? Colors.white : Colors.grey.shade600,
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 4), // আইকন ও টেক্সটের মাঝের গ্যাপ কমানো হয়েছে
              Text(
                label,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11 // ৫টি আইটেম বসানোর জন্য ফন্ট সাইজ সামান্য কমানো হয়েছে
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}