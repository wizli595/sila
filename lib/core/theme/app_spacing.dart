import 'package:flutter/material.dart';

/// 4px grid system
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 64;

  // Padding helpers
  static const paddingSm = EdgeInsets.all(sm);
  static const paddingMd = EdgeInsets.all(md);
  static const paddingLg = EdgeInsets.all(lg);

  static const paddingHorizontalMd = EdgeInsets.symmetric(horizontal: md);
  static const paddingHorizontalLg = EdgeInsets.symmetric(horizontal: lg);
}
