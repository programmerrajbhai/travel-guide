import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

class CityGuidesSection extends StatelessWidget {
  const CityGuidesSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cities = [
      {'title': 'New York', 'places': '124 Places', 'img': 'https://images.unsplash.com/photo-1496442226666-8d4d0e62e6e9?auto=format&fit=crop&q=80&w=200&h=300'},
      {'title': 'Toronto', 'places': '98 Places', 'img': 'https://images.unsplash.com/photo-1507992781348-310259076fe0?auto=format&fit=crop&q=80&w=200&h=300'},
      {'title': 'Montreal', 'places': '76 Places', 'img': 'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?auto=format&fit=crop&q=80&w=200&h=300'},
      {'title': 'Chicago', 'places': '85 Places', 'img': 'https://images.unsplash.com/photo-1494522855154-9297ac14b55f?auto=format&fit=crop&q=80&w=200&h=300'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('City Guides', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            Text('View All', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryColor)),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: cities.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return Container(
                width: 90,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), image: DecorationImage(image: NetworkImage(cities[index]['img']!), fit: BoxFit.cover)),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(0.8)]),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(cities[index]['title']!, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(cities[index]['places']!, style: const TextStyle(color: Colors.white70, fontSize: 10)),
                    ],
                  ),
                ),
              );
            },
          ),
        )
      ],
    );
  }
}