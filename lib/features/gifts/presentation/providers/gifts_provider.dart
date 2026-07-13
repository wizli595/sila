import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/repositories/gift_repository_impl.dart';
import '../../domain/entities/gift.dart';
import '../../domain/entities/gift_type.dart';
import '../../domain/repositories/gift_repository.dart';

final giftRepositoryProvider = Provider<GiftRepository>(
  (_) => GiftRepositoryImpl(Supabase.instance.client),
);

// Fetch gift types from Supabase
final giftTypesProvider = FutureProvider<List<GiftType>>((ref) async {
  final result = await ref.read(giftRepositoryProvider).getGiftTypes();
  return result.fold((failure) => throw failure, (types) => types);
});

// Selected gift type for the confirm screen
final selectedGiftTypeProvider = StateProvider<GiftType?>((_) => null);

// "Give without my name" — chosen on confirm, read by the payment screens
final giveAnonymouslyProvider = StateProvider<bool>((_) => false);

// Chosen amount in centimes — null means the gift type's default price
final selectedAmountProvider = StateProvider<int?>((_) => null);

// Latest gift — shown on the waiting screen
final latestGiftProvider = FutureProvider<Gift?>((ref) async {
  final result = await ref.read(giftRepositoryProvider).getMyGifts();
  return result.fold(
    (failure) => throw failure,
    (gifts) => gifts.isEmpty ? null : gifts.first,
  );
});
