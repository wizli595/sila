/// Input validation — all auth inputs go through here before hitting Supabase.
abstract final class Validators {
  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$',
  );

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'required';
    if (value.length > 254) return 'too_long';
    if (!_emailRegex.hasMatch(value.trim())) return 'invalid_email';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'required';
    if (value.length < 8) return 'too_short';
    if (value.length > 128) return 'too_long';
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return 'required';
    if (value.trim().length < 2) return 'too_short';
    if (value.trim().length > 100) return 'too_long';
    return null;
  }

  /// Sanitize text input — strip control characters, trim whitespace.
  static String sanitize(String input) {
    return input.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '').trim();
  }
}
