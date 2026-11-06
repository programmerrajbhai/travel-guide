import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../screens/category_places_screen.dart';
import '../screens/map_discover/map_discover_screen.dart';
import '../screens/prayer_qibla/prayer_qibla_screen.dart';
import 'nearby_mosques_section.dart';

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    void openScreen(Widget screen) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => screen,
        ),
      );
    }

    void openCategory(String id, String name) {
      openScreen(
        CategoryPlacesScreen(
          categoryId: id,
          categoryName: name,
        ),
      );
    }

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
            _ActionTile(
              label: 'Masjids',
              icon: Icons.mosque,
              color: Colors.green,
              onTap: () {
                openScreen(
                  const NearbyMosquesScreen(),
                );
              },
            ),
            _ActionTile(
              label: 'Qibla',
              icon: Icons.explore,
              color: Colors.teal,
              onTap: () {
                openScreen(
                  const PrayerQiblaScreen(),
                );
              },
            ),
            _ActionTile(
              label: 'Map',
              icon: Icons.map,
              color: Colors.blue,
              onTap: () {
                openScreen(
                  const MapDiscoverScreen(),
                );
              },
            ),
            _ActionTile(
              label: 'Restaurants',
              icon: Icons.restaurant,
              color: Colors.orange,
              onTap: () {
                openCategory('1', 'Restaurants');
              },
            ),
            _ActionTile(
              label: 'Grocery',
              icon: Icons.shopping_cart,
              color: Colors.green,
              onTap: () {
                openCategory('2', 'Grocery');
              },
            ),
            _ActionTile(
              label: 'Butcher',
              icon: Icons.set_meal,
              color: Colors.redAccent,
              onTap: () {
                openCategory('3', 'Butcher');
              },
            ),
            _ActionTile(
              label: 'Hotels',
              icon: Icons.hotel,
              color: Colors.purple,
              onTap: () {
                openCategory('4', 'Hotels');
              },
            ),
            _ActionTile(
              label: 'Clinics',
              icon: Icons.local_hospital,
              color: Colors.blueAccent,
              onTap: () {
                openCategory('5', 'Clinics');
              },
            ),
          ],
        ),
      ],
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
          padding: const EdgeInsets.symmetric(
            horizontal: 3,
            vertical: 8,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color,
                size: 27,
              ),
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