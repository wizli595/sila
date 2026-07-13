import 'package:flutter/material.dart';

import '../constants/gift_icons.dart';

/// A gift type's circular badge — the illustrated icon when one is
/// bundled, otherwise a tinted circle with the Material icon. Used as
/// the Hero child on both the list and confirm screens, so the flight
/// morphs between identical widgets.
class GiftBadge extends StatelessWidget {
  final String iconName;
  final double size;

  const GiftBadge({super.key, required this.iconName, this.size = 48});

  @override
  Widget build(BuildContext context) {
    final image = giftImage(iconName);
    if (image != null) {
      return Image.asset(
        image,
        width: size,
        height: size,
        filterQuality: FilterQuality.medium,
        excludeFromSemantics: true,
      );
    }
    final tint = giftTint(iconName);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.18),
        shape: BoxShape.circle,
      ),
      child: Icon(giftIcon(iconName), color: tint, size: size * 0.45),
    );
  }
}
