import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:sila/core/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/shimmer_box.dart';
import '../../../../core/widgets/sila_thread.dart';
import '../../domain/entities/connection.dart';

/// The emotional payoff — one connection, full screen.
class ConnectionDetailScreen extends StatelessWidget {
  final Connection? connection;

  const ConnectionDetailScreen({super.key, required this.connection});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Deep-linked without data — back to the inbox
    if (connection == null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.goNamed(RouteNames.inbox),
      );
      return const Scaffold(body: SizedBox.shrink());
    }

    final c = connection!;
    final locale = Localizations.localeOf(context).languageCode;
    final note = c.note(locale);
    final date = c.deliveredAt ?? c.createdAt;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.thankYou)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.paddingLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (c.photoUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CachedNetworkImage(
                    imageUrl: c.photoUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => const ShimmerBox(height: 320),
                    errorWidget: (_, _, _) => Container(
                      height: 320,
                      color: AppColors.lightGray,
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        color: AppColors.softGray,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: AppSpacing.lg),
              if (c.recipientName != null)
                Text(
                  c.recipientName!,
                  style: AppTypography.headlineMedium,
                  textAlign: TextAlign.center,
                ),
              if (note != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  note,
                  style: AppTypography.verse.copyWith(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              Text(
                DateFormat.yMMMMd(locale).format(date),
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.softGray,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              const SizedBox(height: 140, child: SilaThread.tied()),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
