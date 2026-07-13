import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthChangeEvent;
import '../../../../core/error/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, SilaUser>> signUp({
    required String name,
    required String email,
    required String password,
  });

  Future<Either<Failure, SilaUser>> signIn({
    required String email,
    required String password,
  });

  Future<Either<Failure, void>> signOut();

  Future<Either<Failure, SilaUser?>> currentUser();

  /// Auth events from Supabase (password recovery deep link, etc.)
  Stream<AuthChangeEvent> get events;

  Future<Either<Failure, void>> sendPasswordReset(String email);

  Future<Either<Failure, void>> updatePassword(String newPassword);

  Future<Either<Failure, SilaUser>> updateName(String fullName);

  /// Verifies [password], then deletes the account server-side
  /// (delete_user() RPC) and signs out locally.
  Future<Either<Failure, void>> deleteAccount(String password);
}
