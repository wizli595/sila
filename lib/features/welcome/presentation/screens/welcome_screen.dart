import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sila/core/l10n/app_localizations.dart';

import '../../../../core/constants/verses.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/sila_thread.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _fadeIn = CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _slideUp = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _fadeController,
            curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
          ),
        );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final verse = ref.watch(verseProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Warm radial gradient glow
          Positioned(
            top: -60,
            left: -40,
            right: -40,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.mango.withValues(alpha: 0.25),
                    AppColors.mango.withValues(alpha: 0.08),
                    AppColors.cream.withValues(alpha: 0.0),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // Quiet iris counter-glow from below — balances the warm top
          Positioned(
            bottom: -120,
            left: -80,
            child: Container(
              width: 340,
              height: 340,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.iris.withValues(alpha: 0.10),
                    AppColors.iris.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          // Thread flowing through the glow — above the app name
          Positioned(
            top: MediaQuery.of(context).size.height * 0.18,
            left: 0,
            right: 0,
            height: 120,
            child: const SilaThread.ambient(thickness: 2.5),
          ),

          // Content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeIn,
              child: SlideTransition(
                position: _slideUp,
                child: Padding(
                  padding: AppSpacing.paddingLg,
                  child: Column(
                    children: [
                      const Spacer(flex: 5),

                      // "sila" in Latin
                      Text(
                        l10n.appNameLatin,
                        style: AppTypography.headlineLarge.copyWith(
                          fontSize: 48,
                          fontWeight: FontWeight.w400,
                          color: AppColors.charcoal,
                          letterSpacing: 4,
                        ),
                      ),

                      // "صـلـة" in Arabic
                      Text(
                        l10n.appNameArabic,
                        style: AppTypography.headlineMedium.copyWith(
                          fontSize: 22,
                          color: AppColors.iris,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xxl),

                      // Arabic verse — rotates each visit
                      Text(
                        verse.ar,
                        style: AppTypography.verse,
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      // Three dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _dot(AppColors.iris.withValues(alpha: 0.4)),
                          const SizedBox(width: 8),
                          _dot(AppColors.watermelon.withValues(alpha: 0.7)),
                          const SizedBox(width: 8),
                          _dot(AppColors.iris.withValues(alpha: 0.4)),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      // French translation — force LTR so punctuation
                      // isn't bidi-reordered inside the RTL layout
                      Text(
                        verse.fr,
                        textDirection: TextDirection.ltr,
                        style: AppTypography.bodyMedium.copyWith(
                          fontStyle: FontStyle.italic,
                          color: AppColors.softGray,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: AppSpacing.md),

                      Text(
                        verse.refLatin,
                        style: AppTypography.verseRef.copyWith(
                          letterSpacing: 3,
                          fontSize: 11,
                        ),
                        textDirection: TextDirection.ltr,
                      ),

                      const Spacer(flex: 3),

                      // Begin button — the one gradient moment
                      GradientButton(
                        onPressed: () => context.goNamed(RouteNames.gifts),
                        child: Text(l10n.begin.toLowerCase()),
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // "i have an account" · "how it works"
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () => context.goNamed(RouteNames.auth),
                            child: Text(
                              l10n.iHaveAccount,
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.softGray,
                              ),
                            ),
                          ),
                          Text(
                            '·',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.softGray,
                            ),
                          ),
                          TextButton(
                            onPressed: () =>
                                context.pushNamed(RouteNames.howItWorks),
                            child: Text(
                              l10n.howItWorksLink,
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.softGray,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.sm),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(Color color) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
