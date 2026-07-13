import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

abstract final class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    fontFamily: 'Cairo',
    scaffoldBackgroundColor: AppColors.cream,
    colorScheme: const ColorScheme.light(
      primary: AppColors.watermelonDeep,
      secondary: AppColors.iris,
      tertiary: AppColors.mango,
      surface: AppColors.cream,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.charcoal,
      error: AppColors.error,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.cream,
      foregroundColor: AppColors.charcoal,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.watermelonDeep,
        foregroundColor: Colors.white,
        textStyle: AppTypography.labelLarge,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        // Warm glow — depth marks the primary action
        elevation: 6,
        shadowColor: AppColors.watermelonDeep.withValues(alpha: 0.4),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.charcoal,
        textStyle: AppTypography.labelLarge.copyWith(color: AppColors.charcoal),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        side: const BorderSide(color: AppColors.lightGray, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.lightGray),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.lightGray),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.iris, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.softGray),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      // Soft warm shadow — cards float just above the cream
      elevation: 4,
      shadowColor: const Color(0x30B5651D),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.lightGray, width: 1),
      ),
      margin: const EdgeInsets.symmetric(vertical: 6),
    ),
  );
}
