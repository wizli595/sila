import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/app_constants.dart';

/// True when the installed version is below app_config.min_version.
/// Fails open — never block users because the config fetch failed.
final updateRequiredProvider = FutureProvider<bool>((ref) async {
  try {
    final row = await Supabase.instance.client
        .from('app_config')
        .select('value')
        .eq('key', 'min_version')
        .maybeSingle();
    final min = row?['value'] as String?;
    if (min == null) return false;
    return _isBelow(AppConstants.appVersion, min);
  } catch (_) {
    return false;
  }
});

bool _isBelow(String version, String min) {
  final v = version.split('.').map(int.tryParse).toList();
  final m = min.split('.').map(int.tryParse).toList();
  for (var i = 0; i < 3; i++) {
    final a = (i < v.length ? v[i] : 0) ?? 0;
    final b = (i < m.length ? m[i] : 0) ?? 0;
    if (a != b) return a < b;
  }
  return false;
}
