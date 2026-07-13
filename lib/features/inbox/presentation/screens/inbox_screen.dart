import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:showcaseview/showcaseview.dart';
import 'package:sila/core/l10n/app_localizations.dart';

import '../../../../core/providers/app_prefs.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/coach_mark.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/error_retry.dart';
import '../../../../core/widgets/press_scale.dart';
import '../../../../core/widgets/shimmer_box.dart';
import '../../../../core/widgets/sila_thread.dart';
import '../../../../core/widgets/staggered_item.dart';
import '../../../../core/widgets/thread_loading.dart';
import '../../domain/entities/connection.dart';
import '../providers/inbox_provider.dart';

class InboxScreen extends ConsumerStatefulWidget {
  const InboxScreen({super.key});

  @override
  ConsumerState<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends ConsumerState<InboxScreen> {
  final _cardKey = GlobalKey();
  bool _coachStarted = false;

  // First thank-you received — point at the card once
  void _maybeStartCoach(BuildContext showcaseContext, bool hasItems) {
    if (_coachStarted || !hasItems) return;
    if (ref.read(seenFlagProvider(CoachKeys.inbox))) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _coachStarted) return;
      // Only when this screen is the visible route
      if (!(ModalRoute.of(context)?.isCurrent ?? false)) return;
      _coachStarted = true;
      ShowCaseWidget.of(showcaseContext).startShowCase([_cardKey]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(
      onFinish: () =>
          ref.read(seenFlagProvider(CoachKeys.inbox).notifier).markSeen(),
      builder: (showcaseContext) => _buildScreen(showcaseContext),
    );
  }

  Widget _buildScreen(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final connections = ref.watch(connectionsProvider);
    _maybeStartCoach(context, connections.value?.isNotEmpty ?? false);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Tied thread in the background — connection is made
            const Positioned.fill(child: SilaThread.tied()),

            // Back — RTL-aware arrow
            PositionedDirectional(
              top: AppSpacing.sm,
              start: AppSpacing.sm,
              child: BackButton(
                color: AppColors.softGray,
                onPressed: () => context.canPop()
                    ? context.pop()
                    : context.goNamed(RouteNames.gifts),
              ),
            ),

            // Content
            Padding(
              padding: AppSpacing.paddingLg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.xl),

                  Text(
                    l10n.inbox,
                    style: AppTypography.headlineLarge,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  Expanded(
                    child: connections.when(
                      loading: () => const ThreadLoading(),
                      error: (_, _) => ErrorRetry(
                        onRetry: () => ref.invalidate(connectionsProvider),
                      ),
                      data: (items) => items.isEmpty
                          ? _EmptyState(l10n: l10n)
                          : ListView.separated(
                              itemCount: items.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: AppSpacing.sm),
                              itemBuilder: (context, index) {
                                final card = _ConnectionCard(
                                  connection: items[index],
                                );
                                return StaggeredItem(
                                  index: index,
                                  child: index == 0
                                      ? coachMark(
                                          key: _cardKey,
                                          description: l10n.coachConnection,
                                          targetRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          child: card,
                                        )
                                      : card,
                                );
                              },
                            ),
                    ),
                  ),

                  // Verse
                  Padding(
                    padding: const EdgeInsets.only(
                      top: AppSpacing.md,
                      bottom: AppSpacing.lg,
                    ),
                    child: Column(
                      children: [
                        Text(
                          l10n.welcomeVerse,
                          style: AppTypography.verse.copyWith(fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          l10n.welcomeVerseRef,
                          style: AppTypography.verseRef,
                        ),
                      ],
                    ),
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

class _EmptyState extends StatelessWidget {
  final AppLocalizations l10n;

  const _EmptyState({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.mail_outline_rounded,
            size: 64,
            color: AppColors.softGray.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.noConnectionsYet,
            style: AppTypography.titleLarge.copyWith(color: AppColors.softGray),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.giveFirst,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.softGray),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ConnectionCard extends StatelessWidget {
  final Connection connection;

  const _ConnectionCard({required this.connection});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final note = connection.note(locale);
    final date = connection.deliveredAt ?? connection.createdAt;

    return PressScale(
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () =>
              context.pushNamed(RouteNames.connection, extra: connection),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (connection.photoUrl != null)
                CachedNetworkImage(
                  imageUrl: connection.photoUrl!,
                  height: 180,
                  fit: BoxFit.cover,
                  placeholder: (_, _) =>
                      const ShimmerBox(height: 180, borderRadius: 0),
                  errorWidget: (_, _, _) => Container(
                    height: 180,
                    color: AppColors.lightGray,
                    child: const Icon(
                      Icons.image_not_supported_outlined,
                      color: AppColors.softGray,
                    ),
                  ),
                ),
              Padding(
                padding: AppSpacing.paddingMd,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (connection.recipientName != null)
                      Text(
                        connection.recipientName!,
                        style: AppTypography.titleLarge,
                      ),
                    if (note != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(note, style: AppTypography.bodyLarge),
                    ],
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        const Icon(
                          Icons.favorite_rounded,
                          size: 14,
                          color: AppColors.watermelon,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          DateFormat.yMMMMd(locale).format(date),
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.softGray,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
