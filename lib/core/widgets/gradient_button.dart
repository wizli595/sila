import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Hero CTA — warm gradient with a soft glow. Reserved for the
/// moments that matter (begin, first steps); everything else uses
/// the standard ElevatedButton.
class GradientButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final double height;

  const GradientButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: AlignmentDirectional.centerStart,
          end: AlignmentDirectional.centerEnd,
          colors: [AppColors.watermelonDeep, AppColors.watermelon],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.watermelonDeep.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed == null
              ? null
              : () {
                  HapticFeedback.lightImpact();
                  onPressed!();
                },
          child: Center(
            child: DefaultTextStyle(
              style: AppTypography.labelLarge.copyWith(
                fontSize: 18,
                letterSpacing: 1,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
