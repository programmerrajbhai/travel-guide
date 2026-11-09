import 'package:flutter/material.dart';
import '../../../../constants/app_colors.dart';
import '../live_qibla_screen.dart';

class PrayerQuickActions extends StatelessWidget {
  final double qiblaDirection;

  const PrayerQuickActions({Key? key, required this.qiblaDirection}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('QUICK ACTIONS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textLight, letterSpacing: 0.5)),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildActionCard(context, Icons.explore, 'Qibla', Colors.green),
            _buildActionCard(context, Icons.notifications_active_outlined, 'Alerts', AppColors.textDark),
            _buildActionCard(context, Icons.calendar_month_outlined, 'Calendar', AppColors.textDark),
            _buildActionCard(context, Icons.settings_outlined, 'Settings', AppColors.textDark),
          ],
        )
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, IconData icon, String label, Color iconColor) {
    return GestureDetector(
      onTap: () async {
        if (label == 'Calendar') {
          // ১. ক্যালেন্ডারে চাপলে আসল ক্যালেন্ডার ওপেন হবে
          await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(primary: AppColors.primaryColor, onPrimary: Colors.white, onSurface: AppColors.textDark),
                ),
                child: child!,
              );
            },
          );
        } else if (label == 'Qibla') {
          // ২. কিবলাতে চাপলে লাইভ কম্পাস ওপেন হবে
          Navigator.push(context, MaterialPageRoute(builder: (_) => LiveQiblaScreen(qiblaDirection: qiblaDirection)));
        } else {
          // ৩. অন্যগুলোতে চাপলে সুন্দর পপ-আপ আসবে
          _showBottomSheet(context, label);
        }
      },
      child: Container(
        width: 75,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey.shade100), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textDark)),
          ],
        ),
      ),
    );
  }

  void _showBottomSheet(BuildContext context, String title) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            Icon(title == 'Alerts' ? Icons.notifications_active : Icons.settings, size: 50, color: AppColors.primaryColor),
            const SizedBox(height: 16),
            Text('$title Preferences', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 12),
            Text('Manage your $title settings from here.', style: const TextStyle(color: AppColors.textLight)),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('Close', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}