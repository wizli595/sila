import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'bootstrap.dart';
import 'admin/admin_app.dart';

/// Admin panel entrypoint — run with:
/// flutter run -t lib/main_admin.dart -d chrome
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await bootstrap();
  runApp(const ProviderScope(child: AdminApp()));
}

// Note: admin doesn't need prefsProvider — it never reads locale/notification prefs.
