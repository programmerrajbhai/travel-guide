// import 'package:flutter/material.dart';
// import '../services/backend_service.dart';
// import '../constants/app_colors.dart';
// import '../screens/category_places_screen.dart';
//
// class DynamicCategories extends StatefulWidget {
//   const DynamicCategories({Key? key}) : super(key: key);
//
//   @override
//   State<DynamicCategories> createState() => _DynamicCategoriesState();
// }
//
// class _DynamicCategoriesState extends State<DynamicCategories> {
//   late Future<List<dynamic>> _categoriesFuture;
//
//   @override
//   void initState() {
//     super.initState();
//     _categoriesFuture = BackendService.fetchCategories();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             const Text(
//               'EXPLORE CATEGORIES',
//               style: TextStyle(
//                 fontSize: 13,
//                 fontWeight: FontWeight.bold,
//                 letterSpacing: 0.5,
//                 color: AppColors.textDark,
//               ),
//             ),
//             GestureDetector(
//               onTap: () {
//                 // View All Action
//               },
//               child: const Text(
//                 'View All',
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: AppColors.primaryColor,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 16),
//         FutureBuilder<List<dynamic>>(
//           future: _categoriesFuture,
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(child: CircularProgressIndicator());
//             } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
//               return const Center(child: Text("No categories found."));
//             }
//
//             final categories = snapshot.data!;
//
//             // GridView এর ঝামেলা এড়াতে আমরা Wrap ব্যবহার করেছি, যা নিজে থেকেই সুন্দরভাবে সাজিয়ে নেয়।
//             return Wrap(
//               spacing: 12, // পাশাপাশি স্পেস
//               runSpacing: 20, // উপর-নিচ স্পেস
//               children: categories.map((cat) {
//
//                 // স্ক্রিনের সাইজ অনুযায়ী প্রতিটি আইটেমের পারফেক্ট Width বের করছি (যাতে ১ লাইনে ঠিক ৪টি করে বসে)
//                 double itemWidth = (MediaQuery.of(context).size.width - 40 - (12 * 3)) / 4;
//
//                 return GestureDetector(
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => CategoryPlacesScreen(
//                           categoryId: cat['id'].toString(),
//                           categoryName: cat['name'],
//                         ),
//                       ),
//                     );
//                   },
//                   child: SizedBox(
//                     width: itemWidth,
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       children: [
//                         Container(
//                           height: itemWidth, // বক্সটিকে একদম স্কয়ার (Square) বানাবে
//                           width: itemWidth,
//                           padding: const EdgeInsets.all(12), // ছবির চারপাশে সুন্দর ফাঁকা জায়গা (Padding) তৈরি করবে
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(16),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.04),
//                                 blurRadius: 10,
//                                 offset: const Offset(0, 4),
//                               )
//                             ],
//                           ),
//                           child: Image.network(
//                             cat['icon'],
//                             fit: BoxFit.contain, // ছবিকে না কেটে পারফেক্ট রেশিওতে বসাবে
//                             errorBuilder: (context, error, stackTrace) => const Icon(Icons.category, color: Colors.grey),
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           cat['name'],
//                           style: const TextStyle(
//                             fontSize: 11,
//                             fontWeight: FontWeight.w600,
//                             color: AppColors.textDark,
//                           ),
//                           textAlign: TextAlign.center,
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               }).toList(),
//             );
//           },
//         ),
//       ],
//     );
//   }
// }