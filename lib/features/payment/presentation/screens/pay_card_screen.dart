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

/// Mock card payment — demo only, no money moves.
/// Swap the simulated delay for Stripe/CMI when the merchant account exists.
class PayCardScreen extends ConsumerStatefulWidget {
  const PayCardScreen({super.key});

  @override
  ConsumerState<PayCardScreen> createState() => _PayCardScreenState();
}

class _PayCardScreenState extends ConsumerState<PayCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _number = TextEditingController();
  final _expiry = TextEditingController();
  final _cvv = TextEditingController();
  bool _processing = false;

  @override
  void dispose() {
    _number.dispose();
    _expiry.dispose();
    _cvv.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _processing = true);

    // Simulated gateway roundtrip
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final ok = await placeGift(context, ref, method: 'card');
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
      appBar: AppBar(title: Text(l10n.payByCard)),
      body: SafeArea(
        child: _processing
            ? ThreadLoading(label: l10n.processingPayment)
            : SingleChildScrollView(
                padding: AppSpacing.paddingLg,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        '$amount MAD',
                        style: AppTypography.headlineLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _DemoNote(text: l10n.payDemoNote),
                      const SizedBox(height: AppSpacing.xl),
                      TextFormField(
                        controller: _number,
                        decoration: InputDecoration(
                          hintText: l10n.cardNumber,
                          suffixIcon: const Icon(
                            Icons.credit_card_rounded,
                            color: AppColors.softGray,
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            (v == null || v.replaceAll(' ', '').length < 12)
                            ? 'invalid'
                            : null,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _expiry,
                              decoration: InputDecoration(
                                hintText: l10n.cardExpiry,
                              ),
                              keyboardType: TextInputType.datetime,
                              validator: (v) => (v == null || v.length < 4)
                                  ? 'invalid'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: TextFormField(
                              controller: _cvv,
                              decoration: const InputDecoration(
                                hintText: 'CVV',
                              ),
                              keyboardType: TextInputType.number,
                              obscureText: true,
                              validator: (v) => (v == null || v.length < 3)
                                  ? 'invalid'
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _pay,
                          child: Text(l10n.payAmount(amount)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class _DemoNote extends StatelessWidget {
  final String text;

  const _DemoNote({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.mango.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: AppTypography.bodyMedium.copyWith(fontSize: 12),
        textAlign: TextAlign.center,
      ),
    );
  }
}
