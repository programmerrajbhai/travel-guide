import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import 'widgets/business_hero_section.dart';
import 'widgets/business_info_actions.dart';
import 'widgets/business_tags.dart';
import 'widgets/popular_menu_section.dart';
import 'widgets/reviews_section.dart';

class BusinessDetailScreen extends StatelessWidget {
  const BusinessDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Hero Image & Top Nav
            const BusinessHeroSection(),

            // 2. Main Content Container
            Transform.translate(
              offset: const Offset(0, -20),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    BusinessInfoActions(),
                    SizedBox(height: 24),
                    Divider(color: Colors.black12),
                    SizedBox(height: 24),
                    BusinessTags(),
                    SizedBox(height: 24),
                    PopularMenuSection(),
                    SizedBox(height: 24),
                    ReviewsSection(),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}