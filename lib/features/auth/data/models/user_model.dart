import '../../domain/entities/user.dart';

class UserModel extends SilaUser {
  const UserModel({
    required super.id,
    required super.fullName,
    super.phone,
    super.locale,
    super.isAdmin,
    required super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      phone: json['phone'] as String?,
      locale: (json['locale'] as String?) ?? 'ar',
      isAdmin: (json['role'] as String?) == 'admin',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'full_name': fullName,
    'phone': phone,
    'locale': locale,
    'role': isAdmin ? 'admin' : 'user',
  };
}
