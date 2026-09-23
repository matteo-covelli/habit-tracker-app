import 'package:flutter/material.dart';
import 'core/constants/app_colors.dart';
import 'features/habits/presentation/screens/home_screen.dart';

class HabitTrackApp extends StatelessWidget {
  const HabitTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habit Tracker',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primaryButton,
          surface: AppColors.surface,
          error: AppColors.deleteRedText,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        cardTheme: const CardThemeData(
          color: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            side: BorderSide(color: AppColors.cardBorder, width: 1),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
