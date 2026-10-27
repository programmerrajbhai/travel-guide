import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

class ExploreCategories extends StatelessWidget {
  const ExploreCategories({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'icon': Icons.mosque, 'name': 'Mosques', 'color': const Color(0xFF2EA866)},
      {'icon': Icons.restaurant_menu, 'name': 'Halal Food', 'color': const Color(0xFFF59E0B)},
      {'icon': Icons.hotel, 'name': 'Hotels', 'color': const Color(0xFF3B82F6)},
      {'icon': Icons.museum, 'name': 'Heritage', 'color': const Color(0xFF8B5CF6)},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: categories.map((cat) {
        return Column(
          children: [
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: (cat['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(cat['icon'] as IconData, color: cat['color'] as Color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(cat['name'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark)),
          ],
        );
      }).toList(),
    );
  }
}