import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'bootstrap.dart';
import 'app.dart';
import 'core/providers/app_prefs.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await bootstrap();
  runApp(
    ProviderScope(
      overrides: [prefsProvider.overrideWithValue(prefs)],
      child: const SilaApp(),
    ),
  );
}
