import 'package:supabase_flutter/supabase_flutter.dart';
import 'failures.dart';

Failure mapException(Object error) {
  return switch (error) {
    Failure f => f,
    PostgrestException e => ServerFailure(e.message, code: e.code),
    AuthException e => AuthFailure(e.message, code: e.statusCode),
    StorageException e => ServerFailure(e.message),
    _ => UnexpectedFailure(error.toString()),
  };
}
