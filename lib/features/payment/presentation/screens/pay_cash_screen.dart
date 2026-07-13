import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sila/core/l10n/app_localizations.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/thread_loading.dart';
import '../../../gifts/presentation/providers/gifts_provider.dart';
import '../place_gift.dart';

/// Mock CashPlus payment — shows a demo payment code.
/// Swap the generated code for the real CashPlus API when available.
class PayCashScreen extends ConsumerStatefulWidget {
  const PayCashScreen({super.key});

  @override
  ConsumerState<PayCashScreen> createState() => _PayCashScreenState();
}

class _PayCashScreenState extends ConsumerState<PayCashScreen> {
  late final String _code = (10000000 + Random().nextInt(90000000)).toString();
  bool _processing = false;

  Future<void> _done() async {
    setState(() => _processing = true);
    final ok = await placeGift(context, ref, method: 'cashplus');
    if (!ok && mounted) setState(() => _processing = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final giftType = ref.watch(selectedGiftTypeProvider);

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

    final centimes = ref.watch(selectedAmountProvider) ?? giftType.defaultPrice;
    final amount = (centimes / 100).toStringAsFixed(2);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.payByCash)),
      body: SafeArea(
        child: _processing
            ? const ThreadLoading()
            : Padding(
                padding: AppSpacing.paddingLg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(),
                    Text(
                      '$amount MAD',
                      style: AppTypography.headlineLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      l10n.cashPlusCode,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.softGray,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Card(
                      child: Padding(
                        padding: AppSpacing.paddingLg,
                        child: Text(
                          _code,
                          style: AppTypography.headlineLarge.copyWith(
                            letterSpacing: 6,
                            color: AppColors.irisDeep,
                          ),
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.ltr,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      l10n.cashPlusInstructions,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.softGray,
                        height: 1.7,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.mango.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        l10n.payDemoNote,
                        style: AppTypography.bodyMedium.copyWith(fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const Spacer(flex: 2),
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _done,
                        child: Text(l10n.done),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ),
              ),
      ),
    );
  }
}
