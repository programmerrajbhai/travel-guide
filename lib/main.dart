import 'package:flutter/material.dart';
import 'constants/app_colors.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(const MuslimTravelApp());
}

class MuslimTravelApp extends StatelessWidget {
  const MuslimTravelApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Muslim Travel App',
      theme: ThemeData(
        primaryColor: AppColors.primaryColor,
        scaffoldBackgroundColor: AppColors.backgroundColor,
        fontFamily: 'San Francisco', // Apnar jodi kono custom font thake
      ),
      home: const MainScreen(), // Ekhane HomeScreen er bodole MainScreen hobe
    );
  }
}