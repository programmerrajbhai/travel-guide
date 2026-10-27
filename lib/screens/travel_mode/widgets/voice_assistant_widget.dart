import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

class VoiceAssistantWidget extends StatelessWidget {
  const VoiceAssistantWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.primaryColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16)
      ),
      child: Row(
        children: [
          const Icon(Icons.mic, color: AppColors.primaryColor, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('VOICE ASSISTANT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                SizedBox(height: 4),
                Text('Prayer reminders & alerts are ON', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
              ],
            ),
          ),
          Row(
            children: List.generate(7, (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 3,
                height: index % 2 == 0 ? 16 : 8,
                decoration: BoxDecoration(color: AppColors.primaryColor, borderRadius: BorderRadius.circular(2))
            )),
          )
        ],
      ),
    );
  }
}