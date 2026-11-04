import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // মার্জিন কমিয়ে রেস্পন্সিভ করা হয়েছে
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // সমান দূরত্ব বজায় রাখবে
        children: [
          _buildNavItem(0, Icons.home_filled, "Home"),
          _buildNavItem(1, Icons.search, "Explore"),
          _buildNavItem(2, Icons.map_outlined, "Map"),
          _buildNavItem(3, Icons.people_outline, "Community"),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isActive = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        // অ্যাক্টিভ এবং ইনঅ্যাক্টিভ অবস্থায় ডাইনামিক প্যাডিং
        padding: EdgeInsets.symmetric(
            horizontal: isActive ? 16.0 : 10.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF115C49) : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : Colors.grey.shade600,
              size: 24,
            ),
            // শুধু অ্যাক্টিভ থাকলে টেক্সট দেখাবে, এতে জায়গা বাঁচবে
            if (isActive) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis, // এক্সট্রা সেফটির জন্য
              ),
            ]
          ],
        ),
      ),
    );
  }
}