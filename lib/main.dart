import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mople_mobile/core/constants/color.dart';
import 'package:mople_mobile/core/constants/font.dart';
import 'package:mople_mobile/presentation/pages/app_start_page.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
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
      debugShowCheckedModeBanner: false,
      home: const AppStartPage(),
    );
  }
}
