import '../../domain/entities/gift_type.dart';

class GiftTypeModel extends GiftType {
  const GiftTypeModel({
    required super.id,
    required super.nameAr,
    required super.nameFr,
    required super.icon,
    required super.defaultPrice,
    super.impactAr,
    super.impactFr,
    super.isActive,
  });

  factory GiftTypeModel.fromJson(Map<String, dynamic> json) {
    return GiftTypeModel(
      id: json['id'] as int,
      nameAr: json['name_ar'] as String,
      nameFr: json['name_fr'] as String,
      icon: json['icon'] as String,
      defaultPrice: json['default_price'] as int,
      impactAr: json['impact_ar'] as String?,
      impactFr: json['impact_fr'] as String?,
      isActive: (json['is_active'] as bool?) ?? true,
    );
  }
}
