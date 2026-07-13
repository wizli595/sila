import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sila/core/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/sila_thread.dart';
import '../providers/auth_provider.dart';

/// Shown after sign-up when email confirmation is enabled.
class CheckEmailScreen extends ConsumerWidget {
  const CheckEmailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.paddingLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              Icon(
                Icons.mark_email_unread_outlined,
                size: 64,
                color: AppColors.mango,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                l10n.checkYourEmail,
                style: AppTypography.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.checkYourEmailDesc,
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
              TextButton(
                onPressed: () {
                  ref.read(authProvider.notifier).clearEmailConfirm();
                  context.goNamed(RouteNames.auth);
                },
                child: Text(
                  l10n.backToSignIn,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.irisDeep,
                  ),
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
