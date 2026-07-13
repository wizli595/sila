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
  /// Failure code when sign-up succeeded but email confirmation is pending.
  static const confirmEmailCode = 'confirm_email';

  final SupabaseClient _client;

  AuthRepositoryImpl(this._client);

  GoTrueClient get _auth => _client.auth;

  @override
  Stream<AuthChangeEvent> get events =>
      _auth.onAuthStateChange.map((d) => d.event);

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

      // Email confirmation enabled — no session until the link is clicked
      if (res.session == null) {
        return const Left(
          AuthFailure('Email confirmation required', code: confirmEmailCode),
        );
      }

      final profile = await _ensureProfile(res.user!.id, cleanName);
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

      final profile = await _ensureProfile(
        res.user!.id,
        (res.user!.userMetadata?['full_name'] as String?) ?? '',
      );
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

      final profile = await _ensureProfile(
        user.id,
        (user.userMetadata?['full_name'] as String?) ?? '',
      );
      return Right(profile);
    } on AuthException {
      // Session invalid — treat as logged out, not as error
      return const Right(null);
    } catch (e) {
      logError('Current user error: $e', tag: 'Auth');
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordReset(String email) async {
    try {
      final cleanEmail = Validators.sanitize(email).toLowerCase();
      await _auth.resetPasswordForEmail(
        cleanEmail,
        redirectTo: 'sila://auth-callback',
      );
      logInfo('Password reset email sent', tag: 'Auth');
      return const Right(null);
    } on AuthException catch (e) {
      logError('Password reset error: ${e.message}', tag: 'Auth');
      return Left(AuthFailure(e.message, code: e.statusCode));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updatePassword(String newPassword) async {
    try {
      await _auth.updateUser(UserAttributes(password: newPassword));
      logInfo('Password updated', tag: 'Auth');
      return const Right(null);
    } on AuthException catch (e) {
      logError('Update password error: ${e.message}', tag: 'Auth');
      return Left(AuthFailure(e.message, code: e.statusCode));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SilaUser>> updateName(String fullName) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return const Left(AuthFailure('Not authenticated'));

      final cleanName = Validators.sanitize(fullName);
      final data = await _client
          .from(SupabaseConstants.profilesTable)
          .update({'full_name': cleanName})
          .eq('id', user.id)
          .select()
          .single();

      logInfo('Name updated', tag: 'Auth');
      return Right(UserModel.fromJson(data));
    } on PostgrestException catch (e) {
      logError('Update name error: ${e.message}', tag: 'Auth');
      return Left(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount(String password) async {
    try {
      final email = _auth.currentUser?.email;
      if (email == null) return const Left(AuthFailure('Not authenticated'));

      // Re-authenticate before the irreversible action
      await _auth.signInWithPassword(email: email, password: password);

      // Server-side deletion (security definer RPC, see supabase/setup.sql)
      await _client.rpc('delete_user');
      await _auth.signOut();

      logInfo('Account deleted', tag: 'Auth');
      return const Right(null);
    } on AuthException catch (e) {
      logError('Delete account auth error: ${e.message}', tag: 'Auth');
      return Left(AuthFailure(e.message, code: e.statusCode));
    } on PostgrestException catch (e) {
      logError('Delete account error: ${e.message}', tag: 'Auth');
      return Left(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  /// Fetches the profile; creates it if the sign-up trigger hasn't
  /// (or the project predates it).
  Future<UserModel> _ensureProfile(String userId, String fallbackName) async {
    final data = await _client
        .from(SupabaseConstants.profilesTable)
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (data != null) return UserModel.fromJson(data);

    final profile = UserModel(
      id: userId,
      fullName: fallbackName,
      locale: 'ar',
      createdAt: DateTime.now(),
    );
    await _client
        .from(SupabaseConstants.profilesTable)
        .insert(profile.toJson());
    return profile;
  }
}
