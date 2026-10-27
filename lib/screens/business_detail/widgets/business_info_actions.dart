import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

class BusinessInfoActions extends StatelessWidget {
  const BusinessInfoActions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Halal Kitchen', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12)),
              child: const Text('Open Now', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
            )
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.star, color: Colors.orange, size: 16),
            const SizedBox(width: 4),
            const Text('4.8', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark)),
            const SizedBox(width: 4),
            Row(
              children: List.generate(4, (index) => const Icon(Icons.star, color: Colors.orange, size: 12)),
            ),
            const SizedBox(width: 6),
            const Text('(312 Reviews)', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
            const Spacer(),
            const Text('\$\$', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          ],
        ),
        const SizedBox(height: 8),
        const Text('Pakistani  •  Indian  •  Middle Eastern', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
        const SizedBox(height: 4),
        Row(
          children: const [
            Icon(Icons.location_on_outlined, size: 14, color: AppColors.textLight),
            SizedBox(width: 4),
            Text('233 Lark St, Albany, NY 12210  •  0.6 mi', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildActionButton(Icons.directions, 'Directions', isPrimary: true),
            _buildActionButton(Icons.phone_outlined, 'Call'),
            _buildActionButton(Icons.language, 'Website'),
            _buildActionButton(Icons.favorite, 'Save', iconColor: Colors.red),
          ],
        )
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, {bool isPrimary = false, Color? iconColor}) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isPrimary ? AppColors.primaryColor : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: isPrimary ? null : Border.all(color: Colors.grey.shade300),
          ),
          child: Icon(icon, color: isPrimary ? Colors.white : (iconColor ?? AppColors.textDark), size: 24),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textDark)),
      ],
    );
  }
}