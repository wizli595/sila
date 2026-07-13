import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:sila/core/l10n/app_localizations.dart';

import '../../../../core/providers/app_prefs.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/coach_mark.dart';
import '../../../../core/widgets/sila_thread.dart';
import '../../../gifts/domain/entities/gift.dart';
import '../../../gifts/presentation/providers/gifts_provider.dart';

class WaitingScreen extends ConsumerStatefulWidget {
  const WaitingScreen({super.key});

  @override
  ConsumerState<WaitingScreen> createState() => _WaitingScreenState();
}

class _WaitingScreenState extends ConsumerState<WaitingScreen> {
  final _homeKey = GlobalKey();
  bool _coachStarted = false;

  String _statusLabel(AppLocalizations l10n, GiftStatus status) {
    return switch (status) {
      GiftStatus.pending => l10n.statusPending,
      GiftStatus.paid => l10n.statusPaid,
      GiftStatus.delivered => l10n.statusDelivered,
      GiftStatus.thanked => l10n.statusThanked,
    };
  }

  void _maybeStartCoach(BuildContext showcaseContext) {
    if (_coachStarted || ref.read(seenFlagProvider(CoachKeys.waiting))) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _coachStarted) return;
      // Only when this screen is the visible route
      if (!(ModalRoute.of(context)?.isCurrent ?? false)) return;
      _coachStarted = true;
      ShowCaseWidget.of(showcaseContext).startShowCase([_homeKey]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(
      onFinish: () =>
          ref.read(seenFlagProvider(CoachKeys.waiting).notifier).markSeen(),
      builder: (showcaseContext) {
        _maybeStartCoach(showcaseContext);
        return _buildScreen(showcaseContext);
      },
    );
  }

  Widget _buildScreen(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final latestGift = ref.watch(latestGiftProvider);
    final giftTypes = ref.watch(giftTypesProvider);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return PopScope(
      canPop: false,
      // The gift is sent — back always means "go home", never "undo"
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.goNamed(RouteNames.gifts);
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              // The journey thread — extends from giver outward
              const Positioned.fill(child: SilaThread.journey(thickness: 2.5)),

              // Home
              PositionedDirectional(
                top: AppSpacing.sm,
                start: AppSpacing.sm,
                child: coachMark(
                  key: _homeKey,
                  description: l10n.coachHome,
                  child: IconButton(
                    tooltip: l10n.chooseGift,
                    icon: const Icon(
                      Icons.home_outlined,
                      color: AppColors.softGray,
                    ),
                    onPressed: () => context.goNamed(RouteNames.gifts),
                  ),
                ),
              ),

              // Content on top
              Padding(
                padding: AppSpacing.paddingLg,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 3),

                    // The gratitude moment
                    Text(
                      l10n.thankYou,
                      style: AppTypography.headlineLarge,
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    Text(
                      l10n.giftOnItsWay,
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.softGray,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Latest gift: type name + status
                    latestGift.when(
                      loading: () => const SizedBox.shrink(),
                      error: (_, _) => const SizedBox.shrink(),
                      data: (gift) {
                        if (gift == null) return const SizedBox.shrink();
                        final typeName = giftTypes.value
                            ?.where((t) => t.id == gift.giftTypeId)
                            .firstOrNull
                            ?.name(isArabic ? 'ar' : 'fr');
                        return Column(
                          children: [
                            if (typeName != null)
                              Text(
                                typeName,
                                style: AppTypography.titleLarge,
                                textAlign: TextAlign.center,
                              ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              _statusLabel(l10n, gift.status),
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.softGray,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        );
                      },
                    ),

                    const Spacer(flex: 4),

                    TextButton(
                      onPressed: () => context.pushNamed(RouteNames.inbox),
                      child: Text(
                        l10n.inbox,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.irisDeep,
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
      ),
    );
  }
}
