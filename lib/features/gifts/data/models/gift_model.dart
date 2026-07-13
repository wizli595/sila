import '../../domain/entities/gift.dart';

class GiftModel extends Gift {
  const GiftModel({
    required super.id,
    required super.giverId,
    required super.giftTypeId,
    required super.amount,
    required super.paymentMethod,
    required super.status,
    super.isAnonymous,
    required super.createdAt,
  });

  factory GiftModel.fromJson(Map<String, dynamic> json) {
    return GiftModel(
      id: json['id'] as String,
      giverId: json['giver_id'] as String,
      giftTypeId: json['gift_type_id'] as int,
      amount: json['amount'] as int,
      paymentMethod: json['payment_method'] as String,
      status: GiftStatus.values.firstWhere(
        (s) => s.name == json['payment_status'],
        orElse: () => GiftStatus.pending,
      ),
      isAnonymous: (json['is_anonymous'] as bool?) ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toInsertJson() => {
    'giver_id': giverId,
    'gift_type_id': giftTypeId,
    'amount': amount,
    'payment_method': paymentMethod,
    'payment_status': status.name,
    'is_anonymous': isAnonymous,
  };
}
