import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/logger/app_logger.dart';
import '../../domain/entities/gift.dart';
import '../../domain/entities/gift_type.dart';
import '../../domain/repositories/gift_repository.dart';
import '../models/gift_model.dart';
import '../models/gift_type_model.dart';

class GiftRepositoryImpl implements GiftRepository {
  final SupabaseClient _client;

  GiftRepositoryImpl(this._client);

  @override
  Future<Either<Failure, List<GiftType>>> getGiftTypes() async {
    try {
      final data = await _client
          .from(SupabaseConstants.giftTypesTable)
          .select()
          .eq('is_active', true)
          .order('id');

      final types = (data as List)
          .map((json) => GiftTypeModel.fromJson(json))
          .toList();

      logInfo('Fetched ${types.length} gift types', tag: 'Gifts');
      return Right(types);
    } on PostgrestException catch (e) {
      logError('Fetch gift types: ${e.message}', tag: 'Gifts');
      return Left(ServerFailure(e.message));
    } catch (e) {
      logError('Fetch gift types: $e', tag: 'Gifts');
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Gift>> createGift({
    required int giftTypeId,
    required String paymentMethod,
    bool isAnonymous = false,
    int? amountCentimes,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return const Left(AuthFailure('Not authenticated'));

      // Get the gift type to know the price
      final typeData = await _client
          .from(SupabaseConstants.giftTypesTable)
          .select()
          .eq('id', giftTypeId)
          .single();

      final giftType = GiftTypeModel.fromJson(typeData);

      final gift = GiftModel(
        id: '',
        giverId: user.id,
        giftTypeId: giftTypeId,
        amount: amountCentimes ?? giftType.defaultPrice,
        paymentMethod: paymentMethod,
        status: GiftStatus.pending,
        isAnonymous: isAnonymous,
        createdAt: DateTime.now(),
      );

      final inserted = await _client
          .from(SupabaseConstants.giftsTable)
          .insert(gift.toInsertJson())
          .select()
          .single();

      logInfo('Gift created: ${inserted['id']}', tag: 'Gifts');
      return Right(GiftModel.fromJson(inserted));
    } on PostgrestException catch (e) {
      logError('Create gift: ${e.message}', tag: 'Gifts');
      return Left(ServerFailure(e.message));
    } catch (e) {
      logError('Create gift: $e', tag: 'Gifts');
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Gift>>> getMyGifts() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return const Left(AuthFailure('Not authenticated'));

      final data = await _client
          .from(SupabaseConstants.giftsTable)
          .select()
          .eq('giver_id', user.id)
          .order('created_at', ascending: false);

      final gifts = (data as List)
          .map((json) => GiftModel.fromJson(json))
          .toList();

      return Right(gifts);
    } on PostgrestException catch (e) {
      logError('Get my gifts: ${e.message}', tag: 'Gifts');
      return Left(ServerFailure(e.message));
    } catch (e) {
      logError('Get my gifts: $e', tag: 'Gifts');
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
