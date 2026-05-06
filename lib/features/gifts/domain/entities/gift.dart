class Gift {
  final String id;
  final String giverId;
  final int giftTypeId;
  final int amount; // centimes MAD
  final String paymentMethod; // 'card' | 'cashplus'
  final GiftStatus status;
  final DateTime createdAt;

  const Gift({
    required this.id,
    required this.giverId,
    required this.giftTypeId,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
  });
}

enum GiftStatus { pending, paid, delivered, thanked }
