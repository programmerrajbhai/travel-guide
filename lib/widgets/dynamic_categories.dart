import 'package:flutter/material.dart';
import '../services/backend_service.dart';
import '../constants/app_colors.dart';
import '../screens/category_places_screen.dart';

class DynamicCategories extends StatefulWidget {
  const DynamicCategories({Key? key}) : super(key: key);

  @override
  State<DynamicCategories> createState() => _DynamicCategoriesState();
}

class _DynamicCategoriesState extends State<DynamicCategories> {
  late Future<List<dynamic>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = BackendService.fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('EXPLORE CATEGORIES', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: AppColors.textDark)),
            GestureDetector(
              onTap: () {
                // View All action (mabalin nga idugtong iti sabali a screen inton kua)
              },
              child: const Text('View All', style: TextStyle(fontSize: 12, color: AppColors.primaryColor, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        FutureBuilder<List<dynamic>>(
          future: _categoriesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No categories found."));
            }

            final categories = snapshot.data!;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 16,
                crossAxisSpacing: 12,
                childAspectRatio: 0.75, // In-adjust tapno adda espasio para iti text
              ),
              itemBuilder: (context, index) {
                final cat = categories[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CategoryPlacesScreen(
                          categoryId: cat['id'].toString(),
                          categoryName: cat['name'],
                        ),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(color: Colors.grey.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4))
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16), // Siguraduen a nagtimbukel ti suli ti ladawan
                            child: Image.network(
                              cat['icon'],
                              fit: BoxFit.cover, // Punnuenna ti sibubukel a kahon
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.category, color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        cat['name'],
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textDark),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}