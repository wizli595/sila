class GiftType {
  final int id;
  final String nameAr;
  final String nameFr;
  final String icon;
  final int defaultPrice; // centimes MAD

  /// Concrete outcome shown at confirm ("feeds a family for a week")
  final String? impactAr;
  final String? impactFr;
  final bool isActive;

  const GiftType({
    required this.id,
    required this.nameAr,
    required this.nameFr,
    required this.icon,
    required this.defaultPrice,
    this.impactAr,
    this.impactFr,
    this.isActive = true,
  });

  String name(String locale) => locale == 'ar' ? nameAr : nameFr;

  String? impact(String locale) => locale == 'ar' ? impactAr : impactFr;
}
