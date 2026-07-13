import 'package:flutter/material.dart';
import 'package:sila/core/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/sila_thread.dart';

/// Blocks the app when the installed version is below the required minimum.
class UpdateRequiredScreen extends StatelessWidget {
  const UpdateRequiredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.paddingLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              const Icon(
                Icons.system_update_alt_rounded,
                size: 56,
                color: AppColors.mango,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                l10n.updateRequiredTitle,
                style: AppTypography.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.updateRequiredDesc,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.softGray,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              const SizedBox(
                height: 100,
                child: SilaThread.ambient(thickness: 2),
              ),
              const Spacer(flex: 3),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () => launchUrl(
                    Uri.parse(AppConstants.playStoreUrl),
                    mode: LaunchMode.externalApplication,
                  ),
                  child: Text(l10n.updateNow),
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
