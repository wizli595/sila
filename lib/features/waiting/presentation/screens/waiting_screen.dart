import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sila/core/l10n/app_localizations.dart';

import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/sila_thread.dart';

class WaitingScreen extends StatelessWidget {
  const WaitingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // The journey thread — extends from giver outward
            const Positioned.fill(
              child: SilaThread.journey(),
            ),

            // Content on top
            Padding(
              padding: AppSpacing.paddingLg,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),

                  Text(
                    l10n.giftOnItsWay,
                    style: AppTypography.headlineMedium,
                    textAlign: TextAlign.center,
                  ),

                  const Spacer(flex: 4),

                  // Temp: navigate to inbox
                  TextButton(
                    onPressed: () => context.goNamed(RouteNames.inbox),
                    child: Text(
                      l10n.inbox,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.iris,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
