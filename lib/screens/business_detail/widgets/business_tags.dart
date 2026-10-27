import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

class BusinessTags extends StatelessWidget {
  const BusinessTags({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _buildTagItem(Icons.verified, 'Halal\nVerified')),
            const SizedBox(width: 12),
            Expanded(child: _buildTagItem(Icons.person, 'Muslim\nOwned')),
            const SizedBox(width: 12),
            Expanded(child: _buildTagItem(Icons.family_restroom, 'Family\nFriendly')),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildTagItem(Icons.mosque, 'Prayer Space')),
            const SizedBox(width: 12),
            const Expanded(flex: 2, child: SizedBox()), // empty space
          ],
        ),
        const SizedBox(height: 24),
        const Text('ABOUT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textLight, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        const Text('Delicious halal food made with fresh ingredients.\nDine-in, Takeaway & Catering available.', style: TextStyle(fontSize: 13, color: AppColors.textDark, height: 1.4)),
        const SizedBox(height: 8),
        Row(
          children: const [
            Icon(Icons.access_time, size: 14, color: AppColors.textDark),
            SizedBox(width: 6),
            Text('Open Daily: 10:00 AM - 10:00 PM', style: TextStyle(fontSize: 13, color: AppColors.textDark)),
          ],
        )
      ],
    );
  }

  Widget _buildTagItem(IconData icon, String label) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primaryColor),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark, height: 1.2))),
      ],
    );
  }
}