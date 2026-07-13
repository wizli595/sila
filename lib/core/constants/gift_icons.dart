import 'package:flutter/material.dart';

/// Maps gift_types.icon names from the DB to Flutter icons.
const giftIcons = <String, IconData>{
  'food_basket': Icons.shopping_basket_rounded,
  'school': Icons.menu_book_rounded,
  'clothing': Icons.checkroom_rounded,
  'medicine': Icons.medical_services_rounded,
  'water': Icons.water_drop_rounded,
};

IconData giftIcon(String name) =>
    giftIcons[name] ?? Icons.card_giftcard_rounded;
