import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

class CommunityTabs extends StatelessWidget {
  const CommunityTabs({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tabs = ['Reviews', 'Favorites', 'Collections', 'City Guides'];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black12, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: tabs.map((tab) {
          final isSelected = tab == 'Reviews';
          return Column(
            children: [
              Text(
                tab,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? AppColors.primaryColor : AppColors.textLight,
                ),
              ),
              const SizedBox(height: 8),
              if (isSelected)
                Container(
                  height: 3,
                  width: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                )
              else
                const SizedBox(height: 3),
            ],
          );
        }).toList(),
      ),
    );
  }
}