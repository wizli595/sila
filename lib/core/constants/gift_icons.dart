import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Maps gift_types.icon names from the DB to Flutter icons.
const giftIcons = <String, IconData>{
  'food_basket': Icons.shopping_basket_rounded,
  'school': Icons.menu_book_rounded,
  'clothing': Icons.checkroom_rounded,
  'medicine': Icons.medical_services_rounded,
  'water': Icons.water_drop_rounded,
};

/// Decorative tint per gift — pastel circle behind the fallback icon.
const giftTints = <String, Color>{
  'food_basket': AppColors.watermelon,
  'school': AppColors.iris,
  'clothing': AppColors.mango,
  'medicine': AppColors.success,
  'water': AppColors.watermelon,
};

/// Illustrated icons (own pastel circle baked in). Gift types without
/// one fall back to the Material icon + tint above.
const _giftImages = <String>{
  'food_basket',
  'school',
  'clothing',
  'medicine',
  'water',
};

IconData giftIcon(String name) =>
    giftIcons[name] ?? Icons.card_giftcard_rounded;

Color giftTint(String name) => giftTints[name] ?? AppColors.mango;

String? giftImage(String name) =>
    _giftImages.contains(name) ? 'assets/images/gifts/$name.png' : null;
