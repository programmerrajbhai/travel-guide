import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

class NearbyPlacesSheet extends StatelessWidget {
  const NearbyPlacesSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.45,
      minChildSize: 0.2,
      maxChildSize: 0.9,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          padding: const EdgeInsets.only(top: 12, left: 20, right: 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
          ),
          child: Column(
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Nearby Places', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  Row(
                    children: const [
                      Text('Sort: Distance', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
                      Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.textLight),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.only(bottom: 20),
                  children: [
                    _buildPlaceItem(
                      title: 'Islamic Center Albany',
                      rating: '4.8 (210)',
                      distance: '0.6 mi',
                      address: '20 Warren St, Albany, NY 12202',
                      imgUrl: 'https://images.unsplash.com/photo-1564769625905-50e93615e769?auto=format&fit=crop&q=80&w=150&h=150',
                      tags: [
                        {'icon': Icons.local_parking, 'label': 'Parking'},
                        {'icon': Icons.water_drop, 'label': 'Wudu'},
                        {'icon': Icons.people, 'label': 'Sisters Area'},
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildPlaceItem(
                      title: 'Halal Kitchen',
                      rating: '4.6 (86)',
                      distance: '0.7 mi',
                      address: '233 Lark St, Albany, NY 12210',
                      imgUrl: 'https://images.unsplash.com/photo-1565557623262-b51c2513a641?auto=format&fit=crop&q=80&w=150&h=150',
                      tags: [
                        {'icon': Icons.verified, 'label': 'Halal Verified'},
                        {'icon': Icons.restaurant, 'label': 'Dine-in'},
                        {'icon': Icons.shopping_bag, 'label': 'Takeaway'},
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlaceItem({required String title, required String rating, required String distance, required String address, required String imgUrl, required List<Map<String, dynamic>> tags}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(16)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(imgUrl, width: 80, height: 80, fit: BoxFit.cover)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark))),
                    Text(distance, style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.orange, size: 14),
                    const SizedBox(width: 4),
                    Text(rating, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                    const SizedBox(width: 8),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(4)), child: const Text('Open', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold))),
                  ],
                ),
                const SizedBox(height: 4),
                Text(address, style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: tags.map((tag) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(tag['icon'], size: 10, color: AppColors.textDark),
                        const SizedBox(width: 4),
                        Text(tag['label'], style: const TextStyle(fontSize: 9, color: AppColors.textDark, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  )).toList(),
                )
              ],
            ),
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(color: AppColors.primaryColor, borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: const [
                    Icon(Icons.directions, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text('Directions', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Icon(Icons.bookmark_border, color: AppColors.textDark, size: 20),
            ],
          )
        ],
      ),
    );
  }
}