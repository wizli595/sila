import 'package:flutter/material.dart';
import 'package:sila/core/l10n/app_localizations.dart';

import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.terms)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.paddingLg,
          child: Text(
            l10n.termsText,
            style: AppTypography.bodyLarge.copyWith(height: 1.8),
          ),
        ),
      ),
    );
  }
}
