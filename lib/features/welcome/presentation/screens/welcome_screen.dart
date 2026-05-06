import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sila/core/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/router/route_names.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.paddingLg,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // TODO: Replace with Lottie mascot animation
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: AppColors.mango,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  size: 48,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // App name
              Text(
                l10n.appName,
                style: AppTypography.headlineLarge.copyWith(
                  fontSize: 36,
                  color: AppColors.watermelon,
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Quranic verse
              Text(
                l10n.welcomeVerse,
                style: AppTypography.verse,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.welcomeVerseRef,
                style: AppTypography.verseRef,
              ),

              const Spacer(flex: 3),

              // Begin button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.goNamed(RouteNames.auth),
                  child: Text(l10n.begin),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
