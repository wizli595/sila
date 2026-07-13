import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sila/core/l10n/app_localizations.dart';

import '../../../../core/providers/app_prefs.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/sila_thread.dart';

/// First-run intro: Give. Wait. Connect. — one thread mode per step.
/// Also reachable later from the welcome screen link.
class HowItWorksScreen extends ConsumerStatefulWidget {
  const HowItWorksScreen({super.key});

  @override
  ConsumerState<HowItWorksScreen> createState() => _HowItWorksScreenState();
}

class _HowItWorksScreenState extends ConsumerState<HowItWorksScreen> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _finish() {
    ref.read(introSeenProvider.notifier).markSeen();
    // Browse first — the account is asked for at confirm time
    context.goNamed(RouteNames.gifts);
  }

  void _next() {
    if (_page == 2) {
      _finish();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final pages = [
      _IntroPage(
        thread: const SilaThread.ambient(thickness: 2.5),
        icon: Icons.volunteer_activism_rounded,
        color: AppColors.watermelon,
        title: l10n.howGiveTitle,
        description: l10n.howGiveDesc,
      ),
      _IntroPage(
        thread: const SilaThread.journey(),
        icon: Icons.hourglass_top_rounded,
        color: AppColors.mango,
        title: l10n.howWaitTitle,
        description: l10n.howWaitDesc,
      ),
      _IntroPage(
        thread: const SilaThread.tied(),
        icon: Icons.favorite_rounded,
        color: AppColors.iris,
        title: l10n.howConnectTitle,
        description: l10n.howConnectDesc,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                onPressed: _finish,
                child: Text(
                  l10n.skip,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.softGray,
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                children: pages,
              ),
            ),

            // Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < 3; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _page ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _page
                          ? AppColors.watermelon
                          : AppColors.softGray.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),

            Padding(
              padding: AppSpacing.paddingLg,
              child: GradientButton(
                onPressed: _next,
                child: Text(_page == 2 ? l10n.begin.toLowerCase() : l10n.next),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IntroPage extends StatelessWidget {
  final Widget thread;
  final IconData icon;
  final Color color;
  final String title;
  final String description;

  const _IntroPage({
    required this.thread,
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.paddingLg,
      child: Column(
        children: [
          Expanded(child: thread),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            title,
            style: AppTypography.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            description,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.softGray,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}
