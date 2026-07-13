import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sila/core/l10n/app_localizations.dart';

import '../router/route_names.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';
import 'sila_thread.dart';

/// Fallback for unknown routes and navigation errors.
class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

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
              const SizedBox(
                height: 120,
                child: SilaThread.ambient(thickness: 2),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                l10n.unexpectedError,
                style: AppTypography.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 3),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () => context.goNamed(RouteNames.gifts),
                  child: Text(l10n.goHome),
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
