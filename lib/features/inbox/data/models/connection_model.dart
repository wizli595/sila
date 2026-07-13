import '../../domain/entities/connection.dart';

class ConnectionModel extends Connection {
  const ConnectionModel({
    required super.id,
    required super.giftId,
    super.recipientName,
    super.photoUrl,
    super.noteAr,
    super.noteFr,
    super.deliveredAt,
    required super.createdAt,
  });

  factory ConnectionModel.fromJson(Map<String, dynamic> json) {
    return ConnectionModel(
      id: json['id'] as String,
      giftId: json['gift_id'] as String,
      recipientName: json['recipient_name'] as String?,
      photoUrl: json['photo_url'] as String?,
      noteAr: json['note_ar'] as String?,
      noteFr: json['note_fr'] as String?,
      deliveredAt: json['delivered_at'] != null
          ? DateTime.parse(json['delivered_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
