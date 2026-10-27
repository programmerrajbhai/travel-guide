import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

class RecentReviewsSection extends StatelessWidget {
  const RecentReviewsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'Recent Reviews',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            Text(
              'View All',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildReviewCard(
          name: 'Ali Khan',
          handle: '@alikhan',
          time: '2h ago',
          review:
              'Great masjid! Very clean and peaceful environment. JazakAllah khair.',
          placeName: 'Islamic Center Albany',
          userImg: 'https://randomuser.me/api/portraits/men/32.jpg',
          placeImg:
              'https://images.unsplash.com/photo-1564769625905-50e93615e769?auto=format&fit=crop&q=80&w=150&h=150',
          likes: '12',
        ),
        const SizedBox(height: 16),
        _buildReviewCard(
          name: 'Fatima Noor',
          handle: '@fatimanoor',
          time: '5h ago',
          review:
              'Excellent halal restaurant. Food was amazing and staff was friendly.',
          placeName: 'Halal Kitchen',
          userImg: 'https://randomuser.me/api/portraits/women/44.jpg',
          placeImg:
              'https://images.unsplash.com/photo-1565557623262-b51c2513a641?auto=format&fit=crop&q=80&w=150&h=150',
          likes: '8',
        ),
      ],
    );
  }

  Widget _buildReviewCard({
    required String name,
    required String handle,
    required String time,
    required String review,
    required String placeName,
    required String userImg,
    required String placeImg,
    required String likes,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(backgroundImage: NetworkImage(userImg), radius: 18),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      handle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                time,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(
              5,
              (index) => const Icon(Icons.star, color: Colors.orange, size: 14),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            review,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textDark,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 14,
                color: AppColors.textLight,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  placeName,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textLight,
                  ),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  placeImg,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Colors.black12),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.thumb_up_alt_outlined,
                    size: 18,
                    color: AppColors.textLight,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    likes,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textLight,
                    ),
                  ),
                  const SizedBox(width: 20),
                  const Icon(
                    Icons.chat_bubble_outline,
                    size: 18,
                    color: AppColors.textLight,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Reply',
                    style: TextStyle(fontSize: 12, color: AppColors.textLight),
                  ),
                  const SizedBox(width: 20),
                  const Icon(
                    Icons.share_outlined,
                    size: 18,
                    color: AppColors.textLight,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Share',
                    style: TextStyle(fontSize: 12, color: AppColors.textLight),
                  ),
                ],
              ),
              const Icon(
                Icons.bookmark_border,
                size: 20,
                color: AppColors.primaryColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
