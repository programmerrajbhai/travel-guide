import 'package:flutter/material.dart';

class BusinessHeroSection extends StatelessWidget {
  const BusinessHeroSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background Image
        Image.network(
          'https://images.unsplash.com/photo-1589302168068-964664d93dc0?auto=format&fit=crop&q=80&w=1080&h=800', // Biryani image
          width: double.infinity,
          height: 250,
          fit: BoxFit.cover,
        ),
        // Gradient overlay for better icon visibility
        Container(
          height: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black.withOpacity(0.6), Colors.transparent],
            ),
          ),
        ),
        // Custom App Bar Icons
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 22),
                  onPressed: () => Navigator.pop(context),
                ),
                Row(
                  children: [
                    IconButton(icon: const Icon(Icons.favorite_border, color: Colors.white, size: 24), onPressed: () {}),
                    IconButton(icon: const Icon(Icons.share_outlined, color: Colors.white, size: 24), onPressed: () {}),
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}