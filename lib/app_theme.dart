import 'package:flutter/material.dart';

/// UIndy-inspired crimson/gray palette, centralized so screens never
/// hardcode colors directly.
class AppColors {
  AppColors._();

  static const crimson = Color(0xFFA6192E);
  static const gray = Color(0xFF939598);
}

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.crimson,
      primary: AppColors.crimson,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.crimson,
      foregroundColor: Colors.white,
      centerTitle: false,
    ),
    cardTheme: const CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.crimson,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );
}
