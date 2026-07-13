import 'package:flutter/material.dart';

abstract final class AppColors {
  // Primary palette — decorative (thread, dots, icon tints)
  static const cream = Color(0xFFFFF8F0);
  static const watermelon = Color(0xFFE8636A);
  static const mango = Color(0xFFF5B041);
  static const iris = Color(0xFF7C83BC);

  // Functional — WCAG AA on cream/white (see DESIGN.md)
  static const watermelonDeep = Color(
    0xFFC7414A,
  ); // filled buttons, 4.9:1 w/ white
  static const irisDeep = Color(0xFF5A628F); // interactive text, 5.6:1

  // Neutrals
  static const charcoal = Color(0xFF33302B); // warm ink, 12.5:1
  static const softGray = Color(0xFF75695C); // warm taupe, 5.1:1
  static const lightGray = Color(0xFFF2EDE7);

  // Semantic
  static const success = Color(0xFF6BBF8A);
  static const error = Color(0xFFD94F4F);

  // Thread
  static const thread = iris;
}
