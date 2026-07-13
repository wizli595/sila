import 'dart:typed_data';

import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/supabase_constants.dart';
import '../../core/error/error_handler.dart';
import '../../core/error/failures.dart';
import '../../core/logger/app_logger.dart';
import '../../features/gifts/data/models/gift_model.dart';
import '../../features/gifts/data/models/gift_type_model.dart';
import '../../features/gifts/domain/entities/gift.dart';
import '../../features/gifts/domain/entities/gift_type.dart';

class AdminStats {
  final int pending;
  final int paid;
  final int delivered;
  final int thanked;
  final int connections;

  const AdminStats({
    required this.pending,
    required this.paid,
    required this.delivered,
    required this.thanked,
    required this.connections,
  });
}

/// A gift with its type and giver names, for admin lists.
class AdminGift {
  final Gift gift;
  final String typeName;
  final String giverName;

  const AdminGift({
    required this.gift,
    required this.typeName,
    required this.giverName,
  });
}

class AdminRepository {
  final SupabaseClient _client;

  AdminRepository(this._client);

  Future<Either<Failure, AdminStats>> getStats() async {
    try {
      final gifts = await _client
          .from(SupabaseConstants.giftsTable)
          .select('payment_status');
      final connections = await _client
          .from(SupabaseConstants.connectionsTable)
          .select('id');

      int count(String status) =>
          (gifts as List).where((g) => g['payment_status'] == status).length;

      return Right(
        AdminStats(
          pending: count('pending'),
          paid: count('paid'),
          delivered: count('delivered'),
          thanked: count('thanked'),
          connections: (connections as List).length,
        ),
      );
    } catch (e) {
      logError('Stats: $e', tag: 'Admin');
      return Left(mapException(e));
    }
  }

  Future<Either<Failure, List<GiftType>>> getGiftTypes() async {
    try {
      final data = await _client
          .from(SupabaseConstants.giftTypesTable)
          .select()
          .order('id', ascending: true);
      return Right(
        (data as List).map((j) => GiftTypeModel.fromJson(j)).toList(),
      );
    } catch (e) {
      logError('Gift types: $e', tag: 'Admin');
      return Left(mapException(e));
    }
  }

  Future<Either<Failure, void>> addGiftType({
    required String nameAr,
    required String nameFr,
    required String icon,
    required int priceCentimes,
    String? impactAr,
    String? impactFr,
  }) async {
    try {
      await _client.from(SupabaseConstants.giftTypesTable).insert({
        'name_ar': nameAr,
        'name_fr': nameFr,
        'icon': icon,
        'default_price': priceCentimes,
        'impact_ar': impactAr,
        'impact_fr': impactFr,
      });
      return const Right(null);
    } catch (e) {
      logError('Add gift type: $e', tag: 'Admin');
      return Left(mapException(e));
    }
  }

  Future<Either<Failure, void>> updateGiftType({
    required int id,
    required String nameAr,
    required String nameFr,
    required String icon,
    required int priceCentimes,
    String? impactAr,
    String? impactFr,
  }) async {
    try {
      await _client
          .from(SupabaseConstants.giftTypesTable)
          .update({
            'name_ar': nameAr,
            'name_fr': nameFr,
            'icon': icon,
            'default_price': priceCentimes,
            'impact_ar': impactAr,
            'impact_fr': impactFr,
          })
          .eq('id', id);
      return const Right(null);
    } catch (e) {
      logError('Update gift type: $e', tag: 'Admin');
      return Left(mapException(e));
    }
  }

  Future<Either<Failure, void>> setGiftTypeActive(int id, bool active) async {
    try {
      await _client
          .from(SupabaseConstants.giftTypesTable)
          .update({'is_active': active})
          .eq('id', id);
      return const Right(null);
    } catch (e) {
      logError('Toggle gift type: $e', tag: 'Admin');
      return Left(mapException(e));
    }
  }

  Future<Either<Failure, List<AdminGift>>> getGifts() async {
    try {
      final data = await _client
          .from(SupabaseConstants.giftsTable)
          .select('*, gift_types(name_fr), profiles(full_name)')
          .order('created_at', ascending: false);

      final gifts = (data as List).map((j) {
        final gift = GiftModel.fromJson(j);
        return AdminGift(
          gift: gift,
          typeName: (j['gift_types']?['name_fr'] as String?) ?? '—',
          // Respect the giver's choice — no name anywhere
          giverName: gift.isAnonymous
              ? 'Anonyme'
              : (j['profiles']?['full_name'] as String?) ?? '—',
        );
      }).toList();

      return Right(gifts);
    } catch (e) {
      logError('Gifts: $e', tag: 'Admin');
      return Left(mapException(e));
    }
  }

  Future<Either<Failure, void>> markPaid(String giftId) async {
    try {
      await _client
          .from(SupabaseConstants.giftsTable)
          .update({'payment_status': 'paid'})
          .eq('id', giftId);
      logInfo('Gift $giftId marked paid', tag: 'Admin');
      return const Right(null);
    } catch (e) {
      logError('Mark paid: $e', tag: 'Admin');
      return Left(mapException(e));
    }
  }

  /// Delivers a gift: uploads the thank-you photo, creates the connection,
  /// and marks the gift as delivered.
  Future<Either<Failure, void>> deliver({
    required String giftId,
    String? recipientName,
    String? noteAr,
    String? noteFr,
    Uint8List? photoBytes,
  }) async {
    try {
      String? photoUrl;
      if (photoBytes != null) {
        final path = '$giftId.jpg';
        await _client.storage
            .from(SupabaseConstants.thankYouPhotosBucket)
            .uploadBinary(
              path,
              photoBytes,
              fileOptions: const FileOptions(
                contentType: 'image/jpeg',
                upsert: true,
              ),
            );
        photoUrl = _client.storage
            .from(SupabaseConstants.thankYouPhotosBucket)
            .getPublicUrl(path);
      }

      await _client.from(SupabaseConstants.connectionsTable).insert({
        'gift_id': giftId,
        'recipient_name': recipientName,
        'photo_url': photoUrl,
        'note_ar': noteAr,
        'note_fr': noteFr,
        'delivered_at': DateTime.now().toIso8601String(),
      });

      await _client
          .from(SupabaseConstants.giftsTable)
          .update({'payment_status': 'delivered'})
          .eq('id', giftId);

      logInfo('Gift $giftId delivered', tag: 'Admin');
      return const Right(null);
    } catch (e) {
      logError('Deliver: $e', tag: 'Admin');
      return Left(mapException(e));
    }
  }
}
