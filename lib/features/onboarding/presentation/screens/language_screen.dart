import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/app_prefs.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/press_scale.dart';
import '../../../../core/widgets/sila_thread.dart';

/// First launch — bilingual by design, shown before any locale exists.
class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.paddingLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              const SizedBox(
                height: 120,
                child: SilaThread.ambient(thickness: 2.5),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'اختر لغتك',
                style: AppTypography.headlineMedium,
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Choisissez votre langue',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.softGray,
                ),
                textAlign: TextAlign.center,
                textDirection: TextDirection.ltr,
              ),
              const Spacer(),
              _LanguageCard(
                label: 'العربية',
                direction: TextDirection.rtl,
                onTap: () => ref.read(localeProvider.notifier).set('ar'),
              ),
              const SizedBox(height: AppSpacing.md),
              _LanguageCard(
                label: 'Français',
                direction: TextDirection.ltr,
                onTap: () => ref.read(localeProvider.notifier).set('fr'),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  final String label;
  final TextDirection direction;
  final VoidCallback onTap;

  const _LanguageCard({
    required this.label,
    required this.direction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PressScale(
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(
              label,
              style: AppTypography.titleLarge,
              textAlign: TextAlign.center,
              textDirection: direction,
            ),
          ),
        ),
      ),
    );
  }
}
