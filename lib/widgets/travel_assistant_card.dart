import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class TravelAssistantCard extends StatelessWidget {
  const TravelAssistantCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.directions_car, color: AppColors.primaryColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('SMART TRAVEL ASSISTANT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textDark, letterSpacing: 0.5)),
                SizedBox(height: 4),
                Text('Not traveling right now', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                SizedBox(height: 2),
                Text('Plan your trip and get prayer stops', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
              ],
            ),
          ),
          const Text('Enter Destination', style: TextStyle(color: AppColors.primaryColor, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}