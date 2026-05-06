class SilaUser {
  final String id;
  final String fullName;
  final String? phone;
  final String locale;
  final bool isAdmin;
  final DateTime createdAt;

  const SilaUser({
    required this.id,
    required this.fullName,
    this.phone,
    this.locale = 'ar',
    this.isAdmin = false,
    required this.createdAt,
  });
}
