import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/supabase_constants.dart';
import 'core/logger/app_logger.dart';

Future<SharedPreferences> bootstrap() async {
  logInfo('Starting Sila...', tag: 'Bootstrap');

  await Supabase.initialize(
    url: SupabaseConstants.url,
    anonKey: SupabaseConstants.anonKey,
  );

  final prefs = await SharedPreferences.getInstance();
  logInfo('Supabase initialized', tag: 'Bootstrap');
  return prefs;
}
