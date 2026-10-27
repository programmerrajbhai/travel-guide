import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

class ReviewsSection extends StatelessWidget {
  const ReviewsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('REVIEWS (312)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textLight, letterSpacing: 0.5)),
        const SizedBox(height: 16),
        _buildReviewItem('Ali Khan', '2 days ago', 'Excellent food, great service and very clean environment.', 'https://randomuser.me/api/portraits/men/32.jpg', 5),
        const Divider(height: 24, color: Colors.black12),
        _buildReviewItem('Mariam Noor', '1 week ago', 'The biryani was amazing! Highly recommend this place.', 'https://randomuser.me/api/portraits/women/44.jpg', 5),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.directions, color: Colors.white, size: 18),
            label: const Text('Get Directions', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          ),
        )
      ],
    );
  }

  Widget _buildReviewItem(String name, String time, String comment, String avatar, int stars) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(backgroundImage: NetworkImage(avatar), radius: 16),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark)),
                  Text(time, style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
                ],
              ),
              const SizedBox(height: 4),
              Text(comment, style: const TextStyle(fontSize: 13, color: AppColors.textDark)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Row(
          children: List.generate(stars, (index) => const Icon(Icons.star, color: Colors.orange, size: 12)),
        )
      ],
    );
  }
}