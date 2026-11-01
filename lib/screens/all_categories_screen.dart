import 'package:flutter/material.dart';
import '../services/backend_service.dart';
import '../constants/app_colors.dart';

class AllCategoriesScreen extends StatefulWidget {
  const AllCategoriesScreen({Key? key}) : super(key: key);

  @override
  State<AllCategoriesScreen> createState() => _AllCategoriesScreenState();
}

class _AllCategoriesScreenState extends State<AllCategoriesScreen> {
  late Future<List<dynamic>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = BackendService.fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        title: const Text(
          'All Categories',
          style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _categoriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No categories found."));
          }

          final categories = snapshot.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(20),
            physics: const BouncingScrollPhysics(),
            itemCount: categories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // প্রতি লাইনে ৩টি ক্যাটাগরি
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              childAspectRatio: 0.85,
            ),
            itemBuilder: (context, index) {
              final cat = categories[index];
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5))
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network(
                      cat['icon'],
                      height: 40,
                      width: 40,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.category, color: Colors.grey, size: 30),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      cat['name'],
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark),
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
    );
  }
}