import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../screens/category_places_screen.dart';
import '../screens/map_discover/map_discover_screen.dart';
import '../screens/prayer_qibla/prayer_qibla_screen.dart';
import 'nearby_mosques_section.dart';
import '../services/backend_service.dart';

class QuickActionsSection extends StatefulWidget {
  const QuickActionsSection({super.key});

  @override
  State<QuickActionsSection> createState() => _QuickActionsSectionState();
}

class _QuickActionsSectionState extends State<QuickActionsSection> {
  late Future<List<dynamic>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    // Fetch real categories from the database
    _categoriesFuture = BackendService.fetchCategories();
  }

  void openScreen(Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => screen),
    );
  }

  // ================= SMART CATEGORY MATCHER =================
  // এটি ডাটাবেসের নামের সাথে বিভিন্ন কিওয়ার্ড মিলিয়ে ক্যাটাগরি খুঁজে বের করবে
  void openCategory(String searchKeywords, String fallbackName, List<dynamic> dbCategories) {
    final keywords = searchKeywords.toLowerCase().split(',');

    dynamic matchingCategory;

    for (var cat in dbCategories) {
      final dbName = cat['name'].toString().toLowerCase().trim();
      // যদি ডাটাবেসের ক্যাটাগরির নামের সাথে আমাদের কোনো একটি কিওয়ার্ড মিলে যায়
      if (keywords.any((kw) => dbName.contains(kw) || kw.contains(dbName))) {
        matchingCategory = cat;
        break;
      }
    }

    if (matchingCategory != null) {
      openScreen(
        CategoryPlacesScreen(
          categoryId: matchingCategory['id'].toString(),
          categoryName: matchingCategory['name'].toString(), // ডাটাবেসের আসল নাম দেখাবে
        ),
      );
    } else {
      // যদি ডাটাবেসে আসলেই এই রিলেটেড কোনো ক্যাটাগরি না থাকে
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$fallbackName category not found. Please add it in Admin Panel.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
        future: _categoriesFuture,
        builder: (context, snapshot) {
          final dbCategories = snapshot.data ?? [];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'QUICK ACTIONS',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 14),
              GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                primary: false,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 8,
                mainAxisSpacing: 12,
                mainAxisExtent: 86,
                children: [
                  // ================= FIXED SCREENS =================
                  _ActionTile(
                    label: 'Masjids',
                    icon: Icons.mosque,
                    color: Colors.green,
                    onTap: () => openScreen(const NearbyMosquesScreen()),
                  ),
                  _ActionTile(
                    label: 'Qibla',
                    icon: Icons.explore,
                    color: Colors.teal,
                    onTap: () => openScreen(const PrayerQiblaScreen()),
                  ),
                  _ActionTile(
                    label: 'Map',
                    icon: Icons.map,
                    color: Colors.blue,
                    onTap: () => openScreen(const MapDiscoverScreen()),
                  ),

                  // ================= DYNAMIC DATABASE CATEGORIES =================
                  _ActionTile(
                    label: 'Restaurants',
                    icon: Icons.restaurant,
                    color: Colors.orange,
                    // 'restaurant, food, cafe, dining' এর যেকোনো একটি ডাটাবেসে থাকলেই কাজ করবে
                    onTap: () => openCategory('restaurant,food,cafe,dining', 'Restaurants', dbCategories),
                  ),
                  _ActionTile(
                    label: 'Grocery',
                    icon: Icons.shopping_cart,
                    color: Colors.green,
                    // 'grocery, shop, market, supermarket' এর যেকোনো একটি থাকলেই কাজ করবে
                    onTap: () => openCategory('grocery,supermarket,market,shop', 'Grocery', dbCategories),
                  ),
                  _ActionTile(
                    label: 'Butcher',
                    icon: Icons.set_meal,
                    color: Colors.redAccent,
                    onTap: () => openCategory('butcher,meat,beef,chicken', 'Butcher', dbCategories),
                  ),
                  _ActionTile(
                    label: 'Hotels',
                    icon: Icons.hotel,
                    color: Colors.purple,
                    onTap: () => openCategory('hotel,motel,resort,stay', 'Hotels', dbCategories),
                  ),
                  _ActionTile(
                    label: 'Clinics',
                    icon: Icons.local_hospital,
                    color: Colors.blueAccent,
                    onTap: () => openCategory('clinic,hospital,medical,doctor', 'Clinics', dbCategories),
                  ),
                ],
              ),
            ],
          );
        }
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 27),
              const SizedBox(height: 7),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}