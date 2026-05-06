import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/supabase_constants.dart';
import 'core/logger/app_logger.dart';

Future<void> bootstrap() async {
  logInfo('Starting Sila...', tag: 'Bootstrap');

  await Supabase.initialize(
    url: SupabaseConstants.url,
    anonKey: SupabaseConstants.anonKey,
  );

  logInfo('Supabase initialized', tag: 'Bootstrap');
}
