import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/gifts/domain/entities/gift_type.dart';
import '../data/admin_repository.dart';

final adminRepositoryProvider = Provider<AdminRepository>(
  (_) => AdminRepository(Supabase.instance.client),
);

final adminStatsProvider = FutureProvider<AdminStats>((ref) async {
  final result = await ref.read(adminRepositoryProvider).getStats();
  return result.fold((f) => throw f, (stats) => stats);
});

final adminGiftTypesProvider = FutureProvider<List<GiftType>>((ref) async {
  final result = await ref.read(adminRepositoryProvider).getGiftTypes();
  return result.fold((f) => throw f, (types) => types);
});

final adminGiftsProvider = FutureProvider<List<AdminGift>>((ref) async {
  final result = await ref.read(adminRepositoryProvider).getGifts();
  return result.fold((f) => throw f, (gifts) => gifts);
});
