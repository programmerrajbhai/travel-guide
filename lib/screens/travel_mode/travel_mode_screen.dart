import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import 'widgets/travel_prayer_card.dart';
import 'widgets/nearest_masjid_card.dart';
import 'widgets/route_info_tile.dart';
import 'widgets/voice_assistant_widget.dart';

class TravelModeScreen extends StatelessWidget {
  const TravelModeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    const TravelPrayerCard(),
                    const SizedBox(height: 24),
                    const NearestMasjidCard(),
                    const SizedBox(height: 16),

                    RouteInfoTile(
                      icon: Icons.restaurant,
                      iconColor: Colors.green,
                      title: 'HALAL FOOD NEARBY',
                      subtitle: 'Halal Kitchen',
                      desc: '2 mins from masjid',
                      trailing: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network('https://images.unsplash.com/photo-1565557623262-b51c2513a641?auto=format&fit=crop&q=80&w=60&h=60', width: 45, height: 45, fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(height: 12),
                    RouteInfoTile(
                      icon: Icons.local_gas_station,
                      iconColor: Colors.blueAccent,
                      title: 'FUEL STATION',
                      subtitle: 'Shell',
                      desc: '1 min away',
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.purple.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                        child: const Text('\$3.59/gal', style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    RouteInfoTile(
                      icon: Icons.warning_amber_rounded,
                      iconColor: Colors.orange,
                      title: 'TRAFFIC AHEAD',
                      subtitle: 'Moderate traffic',
                      desc: 'Slowdown in 4.2 mi',
                      trailing: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network('https://images.unsplash.com/photo-1524661135-423995f22d0b?auto=format&fit=crop&q=80&w=60&h=60', width: 45, height: 45, fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(height: 20),

                    const VoiceAssistantWidget(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 20, color: AppColors.textDark),
            onPressed: () => Navigator.pop(context),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.directions_car, color: AppColors.primaryColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Driving to Toronto, ON', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                const SizedBox(height: 2),
                Row(
                  children: const [
                    Icon(Icons.add_road, size: 14, color: AppColors.textLight),
                    SizedBox(width: 4),
                    Text('245 mi  •  ETA 3h 45m', style: TextStyle(fontSize: 12, color: AppColors.textLight, fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.more_horiz, color: AppColors.textDark), onPressed: () {}),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5))]),
      child: Row(
        children: [


          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.skip_next, color: AppColors.textDark, size: 18),
              label: const Text('Skip Stop', style: TextStyle(color: AppColors.textDark)),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), side: BorderSide(color: Colors.grey.shade300), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            ),
          ),


          const SizedBox(width: 12),


          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.bookmark_border, color: AppColors.textDark, size: 18),
              label: const Text('Save Stop', style: TextStyle(color: AppColors.textDark)),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), side: BorderSide(color: Colors.grey.shade300), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.navigation, color: Colors.white, size: 18),
              label: const Text('Navigate', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            ),
          ),




        ],
      ),
    );
  }
}