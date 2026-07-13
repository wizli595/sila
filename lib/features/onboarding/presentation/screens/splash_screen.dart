import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/sila_thread.dart';

/// Shown while the session resolves — the thread draws itself.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            const Text(
              'صِلة',
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 44,
                color: AppColors.charcoal,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const SizedBox(
              height: 120,
              width: 300,
              child: SilaThread.ambient(thickness: 2.5),
            ),
            const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }
}
