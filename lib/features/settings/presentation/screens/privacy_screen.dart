import 'package:flutter/material.dart';
import 'package:sila/core/l10n/app_localizations.dart';

import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.privacyPolicy)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.paddingLg,
          child: Text(
            l10n.privacyText,
            style: AppTypography.bodyLarge.copyWith(height: 1.8),
          ),
        ),
      ),
    );
  }
}
