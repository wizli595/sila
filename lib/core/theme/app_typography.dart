import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract final class AppTypography {
  static const _fontFamily = 'Cairo';

  static const headlineLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.charcoal,
    height: 1.3,
  );

  static const headlineMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.charcoal,
    height: 1.3,
  );

  static const titleLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.charcoal,
    height: 1.4,
  );

  // Arabic breathes with looser leading (RTL best practice: 1.65+)
  static const bodyLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.charcoal,
    height: 1.65,
  );

  static const bodyMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.charcoal,
    height: 1.65,
  );

  static const labelLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    height: 1.4,
  );

  // Quranic verse — Amiri, classical naskh
  static const verse = TextStyle(
    fontFamily: 'Amiri',
    fontSize: 24,
    fontWeight: FontWeight.w400,
    color: AppColors.charcoal,
    height: 2.0,
  );

  static const verseRef = TextStyle(
    fontFamily: 'Amiri',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.softGray,
    height: 1.4,
  );
}
