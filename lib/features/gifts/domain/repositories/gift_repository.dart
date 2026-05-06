import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/gift_type.dart';
import '../entities/gift.dart';

abstract class GiftRepository {
  Future<Either<Failure, List<GiftType>>> getGiftTypes();

  Future<Either<Failure, Gift>> createGift({
    required int giftTypeId,
    required String paymentMethod,
  });

  Future<Either<Failure, List<Gift>>> getMyGifts();
}
