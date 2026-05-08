import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/logger/app_logger.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _client;

  AuthRepositoryImpl(this._client);

  GoTrueClient get _auth => _client.auth;

  @override
  Future<Either<Failure, SilaUser>> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final cleanName = Validators.sanitize(name);
      final cleanEmail = Validators.sanitize(email).toLowerCase();

      final res = await _auth.signUp(
        email: cleanEmail,
        password: password,
        data: {'full_name': cleanName},
      );

      if (res.user == null) {
        return const Left(AuthFailure('Sign up failed'));
      }

      // Create profile row
      final profile = UserModel(
        id: res.user!.id,
        fullName: cleanName,
        locale: 'ar',
        createdAt: DateTime.now(),
      );

      await _client
          .from(SupabaseConstants.profilesTable)
          .insert(profile.toJson());

      logInfo('User signed up: ${res.user!.id}', tag: 'Auth');
      return Right(profile);
    } on AuthException catch (e) {
      logError('Sign up error: ${e.message}', tag: 'Auth');
      return Left(AuthFailure(e.message, code: e.statusCode));
    } catch (e) {
      logError('Sign up unexpected: $e', tag: 'Auth');
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SilaUser>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final cleanEmail = Validators.sanitize(email).toLowerCase();

      final res = await _auth.signInWithPassword(
        email: cleanEmail,
        password: password,
      );

      if (res.user == null) {
        return const Left(AuthFailure('Sign in failed'));
      }

      final profile = await _fetchProfile(res.user!.id);
      logInfo('User signed in: ${res.user!.id}', tag: 'Auth');
      return Right(profile);
    } on AuthException catch (e) {
      logError('Sign in error: ${e.message}', tag: 'Auth');
      return Left(AuthFailure(e.message, code: e.statusCode));
    } catch (e) {
      logError('Sign in unexpected: $e', tag: 'Auth');
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _auth.signOut();
      logInfo('User signed out', tag: 'Auth');
      return const Right(null);
    } catch (e) {
      logError('Sign out error: $e', tag: 'Auth');
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SilaUser?>> currentUser() async {
    try {
      final session = _auth.currentSession;
      if (session == null) return const Right(null);

      // Check token expiry — Supabase SDK handles refresh,
      // but we verify the session is still valid
      if (session.isExpired) {
        await _auth.refreshSession();
      }

      final user = _auth.currentUser;
      if (user == null) return const Right(null);

      final profile = await _fetchProfile(user.id);
      return Right(profile);
    } on AuthException {
      // Session invalid — treat as logged out, not as error
      return const Right(null);
    } catch (e) {
      logError('Current user error: $e', tag: 'Auth');
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  Future<UserModel> _fetchProfile(String userId) async {
    final data = await _client
        .from(SupabaseConstants.profilesTable)
        .select()
        .eq('id', userId)
        .single();
    return UserModel.fromJson(data);
  }
}
