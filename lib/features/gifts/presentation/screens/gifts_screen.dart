import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:sila/core/l10n/app_localizations.dart';

import '../../../../core/constants/gift_icons.dart';
import '../../../../core/providers/app_prefs.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/coach_mark.dart';
import '../../../../core/widgets/error_retry.dart';
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

    _coachStarted = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ShowCaseWidget.of(
          showcaseContext,
        ).startShowCase([_inboxKey, _threadsKey, _settingsKey]);
      }
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
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final isLoggedIn = ref.watch(isAuthenticatedProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.paddingLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Quiet navigation — settings on one side, inbox + history on
              // the other. Guests get a single sign-in link instead.
              if (isLoggedIn)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    coachMark(
                      key: _settingsKey,
                      description: l10n.coachSettings,
                      child: IconButton(
                        tooltip: l10n.settings,
                        icon: const Icon(
                          Icons.settings_outlined,
                          color: AppColors.softGray,
                        ),
                        onPressed: () => context.pushNamed(RouteNames.settings),
                      ),
                    ),
                    Row(
                      children: [
                        coachMark(
                          key: _threadsKey,
                          description: l10n.coachThreads,
                          child: IconButton(
                            tooltip: l10n.myThreads,
                            icon: const Icon(
                              Icons.history_rounded,
                              color: AppColors.softGray,
                            ),
                            onPressed: () =>
                                context.pushNamed(RouteNames.myThreads),
                          ),
                        ),
                        coachMark(
                          key: _inboxKey,
                          description: l10n.coachInbox,
                          child: IconButton(
                            tooltip: l10n.inbox,
                            icon: const Icon(
                              Icons.mail_outline_rounded,
                              color: AppColors.softGray,
                            ),
                            onPressed: () =>
                                context.pushNamed(RouteNames.inbox),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              else
                Align(
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
              const SizedBox(height: AppSpacing.md),

              Text(
                l10n.chooseGift,
                style: AppTypography.headlineLarge,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.xl),

              Expanded(
                child: giftTypes.when(
                  loading: () => const ThreadLoading(),
                  error: (err, _) => ErrorRetry(
                    onRetry: () => ref.invalidate(giftTypesProvider),
                  ),
                  data: (types) => RefreshIndicator(
                    color: AppColors.watermelonDeep,
                    onRefresh: () async => ref.invalidate(giftTypesProvider),
                    child: ListView.separated(
                      itemCount: types.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final type = types[index];
                        return StaggeredItem(
                          index: index,
                          child: _GiftCard(
                            name: type.name(isArabic ? 'ar' : 'fr'),
                            icon: giftIcon(type.icon),
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
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GiftCard extends StatelessWidget {
  final String name;
  final IconData icon;
  final String heroTag;
  final VoidCallback onTap;

  const _GiftCard({
    required this.name,
    required this.icon,
    required this.heroTag,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PressScale(
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                // Hero — the icon flies to the confirm screen
                Hero(
                  tag: heroTag,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.mango.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: AppColors.mango),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Text(name, style: AppTypography.titleLarge),
                const Spacer(),
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
