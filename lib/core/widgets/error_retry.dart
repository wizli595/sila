import 'package:flutter/material.dart';
import 'package:sila/core/l10n/app_localizations.dart';

import '../network/network_info.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';

/// Shared error state — distinguishes "you're offline" from
/// "something went wrong", with a retry action.
class ErrorRetry extends StatelessWidget {
  final VoidCallback onRetry;

  const ErrorRetry({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return FutureBuilder<bool>(
      future: isConnected(),
      builder: (context, snapshot) {
        final offline = snapshot.data == false;
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                offline ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
                size: 48,
                color: AppColors.softGray.withValues(alpha: 0.6),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                offline ? l10n.networkError : l10n.unexpectedError,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.softGray,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              TextButton(onPressed: onRetry, child: Text(l10n.retry)),
            ],
          ),
        );
      },
    );
  }
}
