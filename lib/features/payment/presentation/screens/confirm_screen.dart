import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:sila/core/l10n/app_localizations.dart';

import '../../../../core/widgets/gift_badge.dart';
import '../../../../core/providers/app_prefs.dart';
import '../../../../core/widgets/coach_mark.dart';
import '../../../../core/widgets/sila_thread.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/router/route_names.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../gifts/presentation/providers/gifts_provider.dart';

class ConfirmScreen extends ConsumerStatefulWidget {
  const ConfirmScreen({super.key});

  @override
  ConsumerState<ConfirmScreen> createState() => _ConfirmScreenState();
}

class _ConfirmScreenState extends ConsumerState<ConfirmScreen> {
  final _amountKey = GlobalKey();
  final _impactKey = GlobalKey();
  final _anonKey = GlobalKey();
  bool _coachStarted = false;

  void _maybeStartCoach(BuildContext showcaseContext, bool hasImpact) {
    if (_coachStarted) return;
    if (ref.read(seenFlagProvider(CoachKeys.confirm))) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _coachStarted) return;
      // Only when this screen is the visible route
      if (!(ModalRoute.of(context)?.isCurrent ?? false)) return;
      _coachStarted = true;
      ShowCaseWidget.of(
        showcaseContext,
      ).startShowCase([_amountKey, if (hasImpact) _impactKey, _anonKey]);
    });
  }

  void _pay(String routeName) {
    // Guests browse freely — the account is asked for right here,
    // at the moment of giving. The selected gift survives sign-in.
    if (!ref.read(isAuthenticatedProvider)) {
      context.pushNamed(RouteNames.auth);
      return;
    }
    context.pushNamed(routeName);
  }

  Future<void> _pickCustomAmount() async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final entered = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.customAmount),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'MAD'),
            keyboardType: TextInputType.number,
            autofocus: true,
            validator: (v) {
              final mad = int.tryParse(v ?? '');
              return (mad == null || mad < 10 || mad > 50000)
                  ? l10n.invalidAmount
                  : null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, int.parse(controller.text) * 100);
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );

    if (entered != null) {
      ref.read(selectedAmountProvider.notifier).state = entered;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final giftType = ref.watch(selectedGiftTypeProvider);
    final anonymous = ref.watch(giveAnonymouslyProvider);
    final chosenAmount = ref.watch(selectedAmountProvider);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    if (giftType == null) {
      return Scaffold(
        body: Center(
          child: TextButton(
            onPressed: () => context.goNamed(RouteNames.gifts),
            child: Text(l10n.chooseGift),
          ),
        ),
      );
    }

    final impact = giftType.impact(isArabic ? 'ar' : 'fr');
    final amount = chosenAmount ?? giftType.defaultPrice;

    // Quick picks: the gift's own price + 50 + 100 MAD, deduplicated
    final presets = <int>{giftType.defaultPrice, 5000, 10000}.toList()..sort();
    final isCustom = !presets.contains(amount);

    return ShowCaseWidget(
      onFinish: () =>
          ref.read(seenFlagProvider(CoachKeys.confirm).notifier).markSeen(),
      builder: (showcaseContext) {
        _maybeStartCoach(showcaseContext, impact != null);

        return Scaffold(
          appBar: AppBar(),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: AppSpacing.paddingLg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(
                    height: 70,
                    child: SilaThread.ambient(thickness: 2),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Selected gift display — hero landing from the list
                  Center(
                    child: Hero(
                      tag: 'gift-${giftType.id}',
                      child: GiftBadge(iconName: giftType.icon, size: 80),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  Text(
                    giftType.name(isArabic ? 'ar' : 'fr'),
                    style: AppTypography.headlineMedium,
                    textAlign: TextAlign.center,
                  ),

                  // The concrete outcome — worth more than any amount
                  if (impact != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    coachMark(
                      key: _impactKey,
                      description: l10n.coachImpact,
                      targetRadius: BorderRadius.circular(12),
                      child: Text(
                        impact,
                        style: AppTypography.bodyLarge.copyWith(
                          color: AppColors.irisDeep,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],

                  const SizedBox(height: AppSpacing.xl),

                  // Amount — quick picks + custom
                  Text(
                    l10n.chooseAmount,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.softGray,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  coachMark(
                    key: _amountKey,
                    description: l10n.coachAmount,
                    targetRadius: BorderRadius.circular(16),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        for (final preset in presets)
                          _AmountChip(
                            label: l10n.madAmount('${preset ~/ 100}'),
                            selected: !isCustom && amount == preset,
                            onTap: () =>
                                ref
                                        .read(selectedAmountProvider.notifier)
                                        .state =
                                    preset,
                          ),
                        _AmountChip(
                          label: isCustom
                              ? l10n.madAmount('${amount ~/ 100}')
                              : l10n.customAmount,
                          selected: isCustom,
                          onTap: _pickCustomAmount,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Give without showing my name
                  coachMark(
                    key: _anonKey,
                    description: l10n.coachAnonymous,
                    targetRadius: BorderRadius.circular(16),
                    child: Card(
                      child: SwitchListTile(
                        secondary: const Icon(
                          Icons.visibility_off_outlined,
                          color: AppColors.softGray,
                        ),
                        title: Text(
                          l10n.giveAnonymously,
                          style: AppTypography.bodyLarge,
                        ),
                        value: anonymous,
                        onChanged: (v) =>
                            ref.read(giveAnonymouslyProvider.notifier).state =
                                v,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Card payment
                  _PaymentOption(
                    icon: Icons.credit_card_rounded,
                    label: l10n.payByCard,
                    color: AppColors.iris,
                    onTap: () => _pay(RouteNames.payCard),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Cash payment
                  _PaymentOption(
                    icon: Icons.payments_rounded,
                    label: l10n.payByCash,
                    color: AppColors.mango,
                    onTap: () => _pay(RouteNames.payCash),
                  ),

                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AmountChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _AmountChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.watermelonDeep : Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.watermelonDeep : AppColors.lightGray,
            ),
          ),
          child: Text(
            label,
            style: AppTypography.bodyLarge.copyWith(
              color: selected ? Colors.white : AppColors.charcoal,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _PaymentOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(label, style: AppTypography.titleLarge),
            ],
          ),
        ),
      ),
    );
  }
}
