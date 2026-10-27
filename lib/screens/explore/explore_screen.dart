import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import 'widgets/explore_header_search.dart';
import 'widgets/explore_categories.dart';
import 'widgets/trending_destinations.dart';
import 'widgets/curated_guides_section.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              ExploreHeaderSearch(),
              SizedBox(height: 32),
              ExploreCategories(),
              SizedBox(height: 36),
              TrendingDestinations(),
              SizedBox(height: 36),
              CuratedGuidesSection(),
              SizedBox(height: 40), // Bottom spacing for Nav Bar
            ],
          ),
        ),
      ),
    );
  }
}