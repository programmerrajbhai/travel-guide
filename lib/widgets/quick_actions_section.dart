import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../screens/prayer_qibla/prayer_qibla_screen.dart';
import '../screens/map_discover/map_discover_screen.dart';
import '../screens/category_places_screen.dart';

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ডাটা টাইপ সিম্প্লিফাই করা হলো যাতে কম্পাইলার কনফিউজড না হয়
    final actionsList = [
      {'icon': Icons.mosque, 'color': Colors.green, 'label': 'Masjids', 'action': 'category', 'id': 'masjids'},
      {'icon': Icons.explore, 'color': Colors.teal, 'label': 'Qibla', 'action': 'qibla'},
      {'icon': Icons.map, 'color': Colors.blue, 'label': 'Map', 'action': 'map'},
      {'icon': Icons.restaurant, 'color': Colors.orange, 'label': 'Restaurants', 'action': 'category', 'id': '1'},
      {'icon': Icons.shopping_cart, 'color': Colors.green, 'label': 'Grocery', 'action': 'category', 'id': '2'},
      {'icon': Icons.set_meal, 'color': Colors.redAccent, 'label': 'Butcher', 'action': 'category', 'id': '3'},
      {'icon': Icons.hotel, 'color': Colors.purple, 'label': 'Hotels', 'action': 'category', 'id': '4'},
      {'icon': Icons.local_hospital, 'color': Colors.blueAccent, 'label': 'Clinics', 'action': 'category', 'id': '5'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('QUICK ACTIONS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark, letterSpacing: 0.5)),
            Text('View All', style: TextStyle(color: AppColors.primaryColor, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 20),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: actionsList.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 20,
            crossAxisSpacing: 10,
            childAspectRatio: 0.75,
          ),
          itemBuilder: (context, index) {
            final action = actionsList[index];
            return GestureDetector(
              onTap: () {
                if (action['action'] == 'qibla') {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const PrayerQiblaScreen()));
                } else if (action['action'] == 'map') {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const MapDiscoverScreen()));
                } else if (action['action'] == 'category') {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) => CategoryPlacesScreen(
                      categoryId: action['id'].toString(),
                      categoryName: action['label'].toString(),
                    ),
                  ));
                }
              },
              child: Column(
                children: [
                  Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
                      ],
                    ),
                    child: Icon(
                      action['icon'] as IconData,
                      color: action['color'] as Color,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    action['label'].toString(),
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textDark),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}