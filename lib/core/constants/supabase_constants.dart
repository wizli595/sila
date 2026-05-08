abstract final class SupabaseConstants {
  static const url = 'https://ijsdjrgqiljovygtnbbu.supabase.co';
  static const anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imlqc2RqcmdxaWxqb3Z5Z3RuYmJ1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzgwOTQ2NTcsImV4cCI6MjA5MzY3MDY1N30.QCOstSYCwYyfn_-IYwD7cuetekEAIKMS4gndCfeAf9s',
  );

  // Table names
  static const profilesTable = 'profiles';
  static const giftTypesTable = 'gift_types';
  static const giftsTable = 'gifts';
  static const connectionsTable = 'connections';

  // Storage buckets
  static const thankYouPhotosBucket = 'thank-you-photos';
}
