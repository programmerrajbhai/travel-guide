import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

class CategoryChips extends StatelessWidget {
  const CategoryChips({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categories = [
      {
        'label': 'Masjids',
        'icon': Icons.mosque,
        'isSelected': true,
        'color': AppColors.primaryColor,
      },
      {
        'label': 'Restaurants',
        'icon': Icons.restaurant,
        'isSelected': false,
        'color': Colors.orange,
      },
      {
        'label': 'Grocery',
        'icon': Icons.shopping_cart,
        'isSelected': false,
        'color': Colors.green,
      },
      {
        'label': 'Butchers',
        'icon': Icons.set_meal,
        'isSelected': false,
        'color': Colors.redAccent,
      },
      {
        'label': 'More',
        'icon': Icons.keyboard_arrow_down,
        'isSelected': false,
        'color': AppColors.textDark,
      },
    ];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final bool isSelected = cat['isSelected'] as bool;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryColor : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: isSelected
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Row(


              children: [
                Icon(
                  cat['icon'] as IconData,
                  size: 16,
                  color: isSelected ? Colors.white : (cat['color'] as Color),
                ),
                if (cat['label'] != 'More') const SizedBox(width: 6),
                Text(
                  cat['label'] as String,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textDark,

                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,

                    fontSize: 13,
                  ),
                ),
              ],


            ),
          );
        },
      ),
    );
  }
}
