import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import 'widgets/community_tabs.dart';
import 'widgets/recent_reviews_section.dart';
import 'widgets/collections_section.dart';
import 'widgets/city_guides_section.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        title: const Text('Community', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const CommunityTabs(),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  RecentReviewsSection(),
                  SizedBox(height: 32),
                  CollectionsSection(),
                  SizedBox(height: 32),
                  CityGuidesSection(),
                  SizedBox(height: 80), // Fab space
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppColors.primaryColor,
        icon: const Icon(Icons.edit, color: Colors.white, size: 18),
        label: const Text('Write Review', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}