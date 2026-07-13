class Gift {
  final String id;
  final String giverId;
  final int giftTypeId;
  final int amount; // centimes MAD
  final String paymentMethod; // 'card' | 'cashplus'
  final GiftStatus status;

  /// Giver chose not to have their name shown to anyone
  final bool isAnonymous;
  final DateTime createdAt;

  const Gift({
    required this.id,
    required this.giverId,
    required this.giftTypeId,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    this.isAnonymous = false,
    required this.createdAt,
  });
}

enum GiftStatus { pending, paid, delivered, thanked }
