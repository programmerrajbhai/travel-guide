import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

class SearchFilterBar extends StatelessWidget {
  const SearchFilterBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: AppColors.textLight, size: 22),
                const SizedBox(width: 12),
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search masjid, restaurant, grocery...',
                      hintStyle: TextStyle(color: AppColors.textLight, fontSize: 14),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const Icon(Icons.mic_none, color: AppColors.textLight, size: 22),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(Icons.tune, color: AppColors.textDark),
              Positioned(
                right: 12,
                top: 12,
                child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.primaryColor, shape: BoxShape.circle)),
              )
            ],
          ),
        )
      ],
    );
  }
}