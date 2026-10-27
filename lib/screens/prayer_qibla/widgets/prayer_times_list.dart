import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

class PrayerTimesList extends StatelessWidget {
  const PrayerTimesList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final prayers = [
      {'name': 'Fajr', 'time': '4:12 AM', 'icon': Icons.brightness_3, 'isActive': false, 'isMuted': false},
      {'name': 'Sunrise', 'time': '5:39 AM', 'icon': Icons.wb_sunny_outlined, 'isActive': false, 'isMuted': true},
      {'name': 'Dhuhr', 'time': '1:05 PM', 'icon': Icons.wb_sunny, 'isActive': false, 'isMuted': false},
      {'name': 'Asr', 'time': '5:03 PM', 'icon': Icons.wb_cloudy, 'isActive': true, 'isMuted': false},
      {'name': 'Maghrib', 'time': '8:28 PM', 'icon': Icons.nights_stay_outlined, 'isActive': false, 'isMuted': false},
      {'name': 'Isha', 'time': '9:55 PM', 'icon': Icons.nights_stay, 'isActive': false, 'isMuted': true},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('TODAY\'S PRAYER TIMES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textLight, letterSpacing: 0.5)),
        const SizedBox(height: 12),
        ...prayers.map((prayer) => _buildPrayerRow(prayer)).toList(),
      ],
    );
  }

  Widget _buildPrayerRow(Map<String, dynamic> prayer) {
    final bool isActive = prayer['isActive'];
    final bool isMuted = prayer['isMuted'];
    final color = isActive ? AppColors.primaryColor : AppColors.textDark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: isActive ? AppColors.primaryColor.withOpacity(0.08) : Colors.transparent, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Icon(prayer['icon'], size: 18, color: color),
          const SizedBox(width: 16),
          Expanded(child: Text(prayer['name'], style: TextStyle(fontSize: 14, fontWeight: isActive ? FontWeight.bold : FontWeight.w500, color: color))),
          Text(prayer['time'], style: TextStyle(fontSize: 14, fontWeight: isActive ? FontWeight.bold : FontWeight.w500, color: color)),
          const SizedBox(width: 16),
          Icon(isMuted ? Icons.volume_off : (isActive ? Icons.notifications_active : Icons.volume_up), size: 18, color: isActive ? AppColors.primaryColor : AppColors.textLight),
        ],
      ),
    );
  }
}