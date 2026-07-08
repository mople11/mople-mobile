import 'package:flutter/material.dart';

import 'core/constants/color.dart';
import 'core/constants/font.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '어디가남',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: AppFont.family,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.brandPrimary,
          primary: AppColors.brandPrimary,
          secondary: AppColors.brandSecondary,
          tertiary: AppColors.brandAccent,
          error: AppColors.danger,
          surface: AppColors.surfaceCard,
        ),
        scaffoldBackgroundColor: AppColors.surfacePage,
      ),
      home: const Scaffold(
        body: Center(child: Text('어디가남', style: AppTextStyle.h2)),
      ),
    );
  }
}
