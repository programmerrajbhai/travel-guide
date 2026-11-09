import 'package:flutter/material.dart';
import '../../../../constants/app_colors.dart';

class PrayerTimesList extends StatefulWidget {
  final Map<String, dynamic>? timings;

  const PrayerTimesList({Key? key, required this.timings}) : super(key: key);

  @override
  State<PrayerTimesList> createState() => _PrayerTimesListState();
}

class _PrayerTimesListState extends State<PrayerTimesList> {
  // প্রতিটি নামাজের মিউট/আনমিউট স্টেট ধরে রাখার ম্যাপ
  final Map<String, bool> _muteStates = {
    'Fajr': false,
    'Sunrise': true,
    'Dhuhr': false,
    'Asr': false,
    'Maghrib': false,
    'Isha': true,
  };

  String _formatTime(String? time24) {
    if (time24 == null) return "--:--";
    try {
      final parts = time24.split(':');
      int hour = int.parse(parts[0]);
      final minute = parts[1];
      String period = hour >= 12 ? 'PM' : 'AM';
      if (hour == 0) hour = 12;
      else if (hour > 12) hour -= 12;
      return "$hour:$minute $period";
    } catch (e) {
      return time24;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.timings == null) return const SizedBox();

    final prayers = [
      {'name': 'Fajr', 'time': _formatTime(widget.timings!['Fajr']), 'icon': Icons.brightness_3, 'isActive': false},
      {'name': 'Sunrise', 'time': _formatTime(widget.timings!['Sunrise']), 'icon': Icons.wb_sunny_outlined, 'isActive': false},
      {'name': 'Dhuhr', 'time': _formatTime(widget.timings!['Dhuhr']), 'icon': Icons.wb_sunny, 'isActive': false},
      {'name': 'Asr', 'time': _formatTime(widget.timings!['Asr']), 'icon': Icons.wb_cloudy, 'isActive': true},
      {'name': 'Maghrib', 'time': _formatTime(widget.timings!['Maghrib']), 'icon': Icons.nights_stay_outlined, 'isActive': false},
      {'name': 'Isha', 'time': _formatTime(widget.timings!['Isha']), 'icon': Icons.nights_stay, 'isActive': false},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('TODAY\'S PRAYER TIMES', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textLight, letterSpacing: 0.5)),
        const SizedBox(height: 12),
        ...prayers.map((prayer) => _buildPrayerRow(prayer)).toList(),
      ],
    );
  }

  Widget _buildPrayerRow(Map<String, dynamic> prayer) {
    final String name = prayer['name'];
    final bool isActive = prayer['isActive'];
    final bool isMuted = _muteStates[name] ?? false;
    final color = isActive ? AppColors.primaryColor : AppColors.textDark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: isActive ? AppColors.primaryColor.withOpacity(0.08) : Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(prayer['icon'], size: 20, color: color),
          const SizedBox(width: 16),
          Expanded(child: Text(name, style: TextStyle(fontSize: 15, fontWeight: isActive ? FontWeight.bold : FontWeight.w600, color: color))),
          Text(prayer['time'], style: TextStyle(fontSize: 15, fontWeight: isActive ? FontWeight.bold : FontWeight.w600, color: color)),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(isMuted ? Icons.volume_off : (isActive ? Icons.notifications_active : Icons.volume_up), size: 20),
            color: isActive ? AppColors.primaryColor : (isMuted ? Colors.grey : AppColors.textDark),
            onPressed: () {
              setState(() {
                _muteStates[name] = !isMuted; // মিউট/আনমিউট টগল
              });
            },
          ),
        ],
      ),
    );
  }
}