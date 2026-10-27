import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

class ExploreHeaderSearch extends StatelessWidget {
  const ExploreHeaderSearch({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Where to next?',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textDark, letterSpacing: -0.5),
        ),
        const SizedBox(height: 8),
        const Text(
          'Discover halal-friendly destinations around the world.',
          style: TextStyle(fontSize: 14, color: AppColors.textLight, height: 1.4),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 54,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
                ),
                child: Row(
                  children: const [
                    Icon(Icons.search, color: AppColors.primaryColor, size: 24),
                    SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search destinations, places...',
                          hintStyle: TextStyle(color: AppColors.textLight, fontSize: 14, fontWeight: FontWeight.w500),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              height: 54,
              width: 54,
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: AppColors.primaryColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: const Icon(Icons.tune, color: Colors.white, size: 24),
            )
          ],
        )
      ],
    );
  }
}