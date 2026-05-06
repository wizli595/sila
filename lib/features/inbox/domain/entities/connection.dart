class Connection {
  final String id;
  final String giftId;
  final String? recipientName;
  final String? photoUrl;
  final String? noteAr;
  final String? noteFr;
  final DateTime? deliveredAt;
  final DateTime createdAt;

  const Connection({
    required this.id,
    required this.giftId,
    this.recipientName,
    this.photoUrl,
    this.noteAr,
    this.noteFr,
    this.deliveredAt,
    required this.createdAt,
  });

  String? note(String locale) => locale == 'ar' ? noteAr : noteFr;
}
