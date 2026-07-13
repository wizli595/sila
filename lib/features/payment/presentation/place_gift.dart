import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/app_prefs.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../gifts/presentation/providers/gifts_provider.dart';

/// Creates the gift after a (mock) payment and moves the giver forward —
/// notification explainer on the first gift, waiting screen after.
/// Returns false on failure so the caller can leave its processing state.
Future<bool> placeGift(
  BuildContext context,
  WidgetRef ref, {
  required String method,
}) async {
  final giftType = ref.read(selectedGiftTypeProvider);
  if (giftType == null) return false;

  final result = await ref
      .read(giftRepositoryProvider)
      .createGift(
        giftTypeId: giftType.id,
        paymentMethod: method,
        isAnonymous: ref.read(giveAnonymouslyProvider),
        amountCentimes: ref.read(selectedAmountProvider),
      );

  if (!context.mounted) return false;

  return result.fold(
    (failure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(failure.message),
          backgroundColor: AppColors.error,
        ),
      );
      return false;
    },
    (_) {
      ref.invalidate(latestGiftProvider);
      ref.read(giveAnonymouslyProvider.notifier).state = false;
      ref.read(selectedAmountProvider.notifier).state = null;
      final primed = ref.read(notificationPrimedProvider);
      context.goNamed(primed ? RouteNames.waiting : RouteNames.notifyPrime);
      return true;
    },
  );
}
