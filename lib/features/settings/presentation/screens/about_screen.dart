import 'package:flutter/material.dart';
import 'package:sila/core/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/sila_thread.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.about)),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.paddingLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Text(
                l10n.appNameLatin,
                style: AppTypography.headlineLarge.copyWith(
                  fontSize: 40,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 4,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                l10n.appNameArabic,
                style: AppTypography.headlineMedium.copyWith(
                  color: AppColors.iris,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                l10n.aboutText,
                style: AppTypography.bodyLarge.copyWith(height: 1.8),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              // Transparency — where the money goes
              Text(
                l10n.whereMoneyGoesTitle,
                style: AppTypography.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.whereMoneyGoesText,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.softGray,
                  height: 1.7,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                l10n.welcomeVerse,
                style: AppTypography.verse.copyWith(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.welcomeVerseRef,
                style: AppTypography.verseRef,
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              const SizedBox(
                height: 100,
                child: SilaThread.ambient(thickness: 2),
              ),
              Text(
                '${l10n.version} 1.0.0',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.softGray,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
