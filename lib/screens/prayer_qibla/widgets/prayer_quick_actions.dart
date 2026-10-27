import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

class PrayerQuickActions extends StatelessWidget {
  const PrayerQuickActions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('QUICK ACTIONS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textLight, letterSpacing: 0.5)),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildActionCard(Icons.explore, 'Qibla'),
            _buildActionCard(Icons.notifications_active, 'Alerts'),
            _buildActionCard(Icons.calendar_month, 'Calendar'),
            _buildActionCard(Icons.settings, 'Settings'),
          ],
        )
      ],
    );
  }

  Widget _buildActionCard(IconData icon, String label) {
    return Container(
      width: 75,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 4))]),
      child: Column(
        children: [
          Icon(icon, color: AppColors.textDark, size: 24),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textDark)),
        ],
      ),
    );
  }
}