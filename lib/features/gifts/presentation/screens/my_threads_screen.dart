import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:sila/core/l10n/app_localizations.dart';

import '../../../../core/constants/gift_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/error_retry.dart';
import '../../../../core/widgets/staggered_item.dart';
import '../../../../core/widgets/thread_loading.dart';
import '../../domain/entities/gift.dart';
import '../providers/gifts_provider.dart';

// Every gift the user has given, newest first
final myGiftsProvider = FutureProvider<List<Gift>>((ref) async {
  final result = await ref.read(giftRepositoryProvider).getMyGifts();
  return result.fold((f) => throw f, (gifts) => gifts);
});

class MyThreadsScreen extends ConsumerWidget {
  const MyThreadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final gifts = ref.watch(myGiftsProvider);
    final giftTypes = ref.watch(giftTypesProvider);
    final locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.myThreads)),
      body: gifts.when(
        loading: () => const ThreadLoading(),
        error: (_, _) =>
            ErrorRetry(onRetry: () => ref.invalidate(myGiftsProvider)),
        data: (items) => items.isEmpty
            ? Center(
                child: Text(
                  l10n.noGiftsYet,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.softGray,
                  ),
                ),
              )
            : ListView.separated(
                padding: AppSpacing.paddingLg,
                itemCount: items.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final gift = items[index];
                  final type = giftTypes.value
                      ?.where((t) => t.id == gift.giftTypeId)
                      .firstOrNull;
                  return StaggeredItem(
                    index: index,
                    child: _GiftHistoryCard(
                      gift: gift,
                      typeName: type?.name(locale) ?? l10n.chooseGift,
                      icon: giftIcon(type?.icon ?? ''),
                      dateLabel: DateFormat.yMMMMd(
                        locale,
                      ).format(gift.createdAt),
                      statusLabel: _statusLabel(l10n, gift.status),
                    ),
                  );
                },
              ),
      ),
    );
  }

  String _statusLabel(AppLocalizations l10n, GiftStatus status) {
    return switch (status) {
      GiftStatus.pending => l10n.statusPending,
      GiftStatus.paid => l10n.statusPaid,
      GiftStatus.delivered => l10n.statusDelivered,
      GiftStatus.thanked => l10n.statusThanked,
    };
  }
}

class _GiftHistoryCard extends StatelessWidget {
  final Gift gift;
  final String typeName;
  final IconData icon;
  final String dateLabel;
  final String statusLabel;

  const _GiftHistoryCard({
    required this.gift,
    required this.typeName,
    required this.icon,
    required this.dateLabel,
    required this.statusLabel,
  });

  Color get _statusColor => switch (gift.status) {
    GiftStatus.pending => AppColors.mango,
    GiftStatus.paid => AppColors.iris,
    GiftStatus.delivered => AppColors.success,
    GiftStatus.thanked => AppColors.watermelon,
  };

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.mango.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.mango),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(typeName, style: AppTypography.titleLarge),
                  Text(
                    dateLabel,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.softGray,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: _statusColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    statusLabel,
                    style: AppTypography.bodyMedium.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
