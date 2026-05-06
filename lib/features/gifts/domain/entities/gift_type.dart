class GiftType {
  final int id;
  final String nameAr;
  final String nameFr;
  final String icon;
  final int defaultPrice; // centimes MAD
  final bool isActive;

  const GiftType({
    required this.id,
    required this.nameAr,
    required this.nameFr,
    required this.icon,
    required this.defaultPrice,
    this.isActive = true,
  });

  String name(String locale) => locale == 'ar' ? nameAr : nameFr;
}
