import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> items = [
      {'icon': Icons.mosque, 'label': 'Masjids', 'color': Colors.green},
      {'icon': Icons.explore, 'label': 'Qibla', 'color': Colors.teal},
      {'icon': Icons.map, 'label': 'Map', 'color': Colors.blue},
      {'icon': Icons.restaurant, 'label': 'Restaurants', 'color': Colors.orange},
      {'icon': Icons.shopping_cart, 'label': 'Grocery', 'color': Colors.green},
      {'icon': Icons.set_meal, 'label': 'Butcher', 'color': Colors.red},
      {'icon': Icons.hotel, 'label': 'Hotels', 'color': Colors.purple},
      {'icon': Icons.local_hospital, 'label': 'Clinics', 'color': Colors.blueAccent},
    ];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('QUICK ACTIONS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Text('View All', style: TextStyle(color: AppColors.primaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.8,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 4)],
                  ),
                  child: Icon(items[index]['icon'], color: items[index]['color'], size: 28),
                ),
                const SizedBox(height: 8),
                Text(items[index]['label'], style: const TextStyle(fontSize: 11, color: Colors.black87)),
              ],
            );
          },
        ),
      ],
    );
  }
}