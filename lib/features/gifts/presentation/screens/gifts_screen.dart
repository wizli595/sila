import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:sila/core/l10n/app_localizations.dart';

import '../../../../core/providers/app_prefs.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/coach_mark.dart';
import '../../../../core/widgets/error_retry.dart';
import '../../../../core/widgets/gift_badge.dart';
import '../../../../core/widgets/press_scale.dart';
import '../../../../core/widgets/staggered_item.dart';
import '../../../../core/widgets/thread_loading.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/gifts_provider.dart';

class GiftsScreen extends ConsumerStatefulWidget {
  const GiftsScreen({super.key});

  @override
  ConsumerState<GiftsScreen> createState() => _GiftsScreenState();
}

class _GiftsScreenState extends ConsumerState<GiftsScreen> {
  final _settingsKey = GlobalKey();
  final _threadsKey = GlobalKey();
  final _inboxKey = GlobalKey();
  bool _coachStarted = false;

  void _maybeStartCoachMarks(BuildContext showcaseContext) {
    if (_coachStarted) return;
    final isLoggedIn = ref.read(isAuthenticatedProvider);
    final seen = ref.read(seenFlagProvider(CoachKeys.home));
    if (!isLoggedIn || seen) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _coachStarted) return;
      // Only when this screen is the visible route — never over a
      // screen pushed on top (e.g. the sign-in screen)
      if (!(ModalRoute.of(context)?.isCurrent ?? false)) return;
      _coachStarted = true;
      ShowCaseWidget.of(
        showcaseContext,
      ).startShowCase([_inboxKey, _threadsKey, _settingsKey]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(
      onFinish: () =>
          ref.read(seenFlagProvider(CoachKeys.home).notifier).markSeen(),
      builder: (showcaseContext) {
        _maybeStartCoachMarks(showcaseContext);
        return _buildScreen(showcaseContext);
      },
    );
  }

  Widget _buildScreen(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final giftTypes = ref.watch(giftTypesProvider);
    final locale = Localizations.localeOf(context).languageCode == 'ar'
        ? 'ar'
        : 'fr';
    final isLoggedIn = ref.watch(isAuthenticatedProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Quiet navigation — settings on one side, inbox + history on
            // the other. Guests get a single sign-in link instead.
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                0,
              ),
              child: isLoggedIn
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        coachMark(
                          key: _settingsKey,
                          description: l10n.coachSettings,
                          child: _NavButton(
                            tooltip: l10n.settings,
                            icon: Icons.settings_outlined,
                            onTap: () =>
                                context.pushNamed(RouteNames.settings),
                          ),
                        ),
                        Row(
                          children: [
                            coachMark(
                              key: _threadsKey,
                              description: l10n.coachThreads,
                              child: _NavButton(
                                tooltip: l10n.myThreads,
                                icon: Icons.history_rounded,
                                onTap: () =>
                                    context.pushNamed(RouteNames.myThreads),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            coachMark(
                              key: _inboxKey,
                              description: l10n.coachInbox,
                              child: _NavButton(
                                tooltip: l10n.inbox,
                                icon: Icons.mail_outline_rounded,
                                onTap: () =>
                                    context.pushNamed(RouteNames.inbox),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: TextButton(
                        onPressed: () => context.pushNamed(RouteNames.auth),
                        child: Text(
                          l10n.signIn,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.irisDeep,
                          ),
                        ),
                      ),
                    ),
            ),

            Expanded(
              child: giftTypes.when(
                loading: () => const ThreadLoading(),
                error: (err, _) => ErrorRetry(
                  onRetry: () => ref.invalidate(giftTypesProvider),
                ),
                data: (types) => RefreshIndicator(
                  color: AppColors.watermelonDeep,
                  onRefresh: () async => ref.invalidate(giftTypesProvider),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.sm,
                      AppSpacing.lg,
                      AppSpacing.md,
                    ),
                    children: [
                      _Header(
                        title: l10n.chooseGift,
                        subtitle: l10n.homeSubtitle,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      for (final (index, type) in types.indexed) ...[
                        StaggeredItem(
                          index: index,
                          child: _GiftCard(
                            name: type.name(locale),
                            impact: type.impact(locale),
                            iconName: type.icon,
                            heroTag: 'gift-${type.id}',
                            onTap: () {
                              ref
                                      .read(selectedGiftTypeProvider.notifier)
                                      .state =
                                  type;
                              // Fresh choices for a fresh gift
                              ref.read(selectedAmountProvider.notifier).state =
                                  null;
                              ref.read(giveAnonymouslyProvider.notifier).state =
                                  false;
                              context.pushNamed(RouteNames.confirm);
                            },
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                      const SizedBox(height: AppSpacing.md),
                      StaggeredItem(
                        index: types.length,
                        child: _HadithCard(
                          quote: l10n.homeHadith,
                          reference: l10n.homeHadithRef,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Floating white icon button — quiet nav that matches the card language.
class _NavButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Tooltip(
            message: tooltip,
            child: Icon(icon, color: AppColors.softGray),
          ),
        ),
      ),
    );
  }
}

/// Headline + subtitle beside the giving illustration.
class _Header extends StatelessWidget {
  final String title;
  final String subtitle;

  const _Header({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.headlineLarge),
              const SizedBox(height: AppSpacing.xs),
              Text(
                subtitle,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.softGray,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              // Coral accent stroke under the words
              Container(
                width: 56,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.watermelon,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Image.asset(
          'assets/images/home_hero.png',
          width: 130,
          excludeFromSemantics: true,
        ),
      ],
    );
  }
}

class _GiftCard extends StatelessWidget {
  final String name;
  final String? impact;
  final String iconName;
  final String heroTag;
  final VoidCallback onTap;

  const _GiftCard({
    required this.name,
    required this.impact,
    required this.iconName,
    required this.heroTag,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final impact = this.impact;

    return PressScale(
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: 12,
            ),
            child: Row(
              children: [
                // Hero — the badge flies to the confirm screen
                Hero(
                  tag: heroTag,
                  child: GiftBadge(iconName: iconName),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: AppTypography.titleLarge),
                      if (impact != null && impact.isNotEmpty)
                        Text(
                          impact,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.softGray,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppColors.softGray,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Hadith on generosity — closes the list the way the verse opens the app.
class _HadithCard extends StatelessWidget {
  final String quote;
  final String reference;

  const _HadithCard({required this.quote, required this.reference});

  @override
  Widget build(BuildContext context) {
    // Naskh needs generous leading; Latin reads tighter
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Container(
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: AppColors.mango.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          PositionedDirectional(
            bottom: 0,
            end: 0,
            child: Icon(
              Icons.favorite_outline_rounded,
              size: 28,
              color: AppColors.watermelon.withValues(alpha: 0.3),
            ),
          ),
          Row(
            children: [
              Image.asset(
                'assets/images/quote_sprout.png',
                width: 56,
                excludeFromSemantics: true,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '« $quote »',
                      style: AppTypography.verse.copyWith(
                        fontSize: isArabic ? 18 : 15,
                        height: isArabic ? 1.9 : 1.5,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      reference,
                      style: AppTypography.verseRef.copyWith(
                        color: AppColors.watermelonDeep,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
