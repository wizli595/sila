import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sila/core/l10n/app_localizations.dart';

import '../../../../core/providers/app_prefs.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/sila_thread.dart';

/// Shown once, right after the first gift — the moment the one
/// notification ("your connection arrived") has obvious value.
class NotifyPrimeScreen extends ConsumerWidget {
  const NotifyPrimeScreen({super.key});

  Future<void> _finish(
    BuildContext context,
    WidgetRef ref, {
    required bool enable,
  }) async {
    if (enable) {
      await Permission.notification.request();
    }
    await ref.read(notificationPrimedProvider.notifier).markPrimed();
    if (context.mounted) context.goNamed(RouteNames.waiting);
  }

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
              const Icon(
                Icons.notifications_active_outlined,
                size: 56,
                color: AppColors.mango,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                l10n.notifyPrimeTitle,
                style: AppTypography.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.notifyPrimeDesc,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.softGray,
                  height: 1.6,
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
                  onPressed: () => _finish(context, ref, enable: true),
                  child: Text(l10n.enableNotifications),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: () => _finish(context, ref, enable: false),
                child: Text(
                  l10n.notNow,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.softGray,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}
