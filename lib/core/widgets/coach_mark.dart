import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';

/// Sila-styled coach mark — warm scrim, white rounded tooltip.
Showcase coachMark({
  required GlobalKey key,
  required String description,
  required Widget child,
  BorderRadius? targetRadius,
}) {
  return Showcase(
    key: key,
    description: description,
    descTextStyle: AppTypography.bodyMedium,
    tooltipBackgroundColor: Colors.white,
    overlayColor: AppColors.charcoal,
    overlayOpacity: 0.7,
    targetBorderRadius: targetRadius ?? BorderRadius.circular(24),
    targetPadding: const EdgeInsets.all(4),
    tooltipBorderRadius: BorderRadius.circular(16),
    tooltipPadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.sm,
    ),
    child: child,
  );
}
