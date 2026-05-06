import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sila/core/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/router/route_names.dart';

class ConfirmScreen extends StatelessWidget {
  const ConfirmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.paddingLg,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),

              Text(
                l10n.confirmGift,
                style: AppTypography.headlineLarge,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Card payment
              _PaymentOption(
                icon: Icons.credit_card_rounded,
                label: l10n.payByCard,
                color: AppColors.iris,
                onTap: () {
                  // TODO: Integrate card payment
                  context.goNamed(RouteNames.waiting);
                },
              ),

              const SizedBox(height: AppSpacing.md),

              // Cash payment
              _PaymentOption(
                icon: Icons.payments_rounded,
                label: l10n.payByCash,
                color: AppColors.mango,
                onTap: () {
                  // TODO: Integrate CashPlus
                  context.goNamed(RouteNames.waiting);
                },
              ),

              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _PaymentOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(label, style: AppTypography.titleLarge),
            ],
          ),
        ),
      ),
    );
  }
}
