import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> items = [
      {'icon': Icons.mosque, 'label': 'Masjids', 'color': Colors.green},
      {'icon': Icons.explore_outlined, 'label': 'Qibla', 'color': Colors.teal},
      {'icon': Icons.map_outlined, 'label': 'Map', 'color': Colors.blue},
      {'icon': Icons.restaurant_menu, 'label': 'Restaurants', 'color': Colors.orange},
      {'icon': Icons.shopping_cart_outlined, 'label': 'Grocery', 'color': Colors.green},
      {'icon': Icons.set_meal, 'label': 'Butcher', 'color': Colors.redAccent},
      {'icon': Icons.bed, 'label': 'Hotels', 'color': Colors.deepPurpleAccent},
      {'icon': Icons.local_hospital_outlined, 'label': 'Clinics', 'color': Colors.blueAccent},
    ];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('QUICK ACTIONS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark, letterSpacing: 0.5)),
            Text('View All', style: TextStyle(color: AppColors.primaryColor, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 16,
            crossAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 4))],
                  ),
                  child: Icon(items[index]['icon'], color: items[index]['color'], size: 26),
                ),
                const SizedBox(height: 8),
                Text(items[index]['label'], style: const TextStyle(fontSize: 11, color: AppColors.textDark, fontWeight: FontWeight.w500)),
              ],
            );
          },
        ),
      ],
    );
  }
}