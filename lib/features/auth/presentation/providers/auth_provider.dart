import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

// Repository
final authRepositoryProvider = Provider<AuthRepository>(
  (_) => AuthRepositoryImpl(Supabase.instance.client),
);

// Auth state
enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final SilaUser? user;
  final String? error;
  final bool loading;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.error,
    this.loading = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    SilaUser? user,
    String? error,
    bool? loading,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
      loading: loading ?? this.loading,
    );
  }
}

// Auth notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;

  AuthNotifier(this._repo) : super(const AuthState()) {
    _init();
  }

  Future<void> _init() async {
    final result = await _repo.currentUser();
    result.fold(
      (_) => state = const AuthState(status: AuthStatus.unauthenticated),
      (user) => state = AuthState(
        status: user != null
            ? AuthStatus.authenticated
            : AuthStatus.unauthenticated,
        user: user,
      ),
    );
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(loading: true, error: null);

    final result = await _repo.signUp(
      name: name,
      email: email,
      password: password,
    );

    state = result.fold(
      (failure) => state.copyWith(
        loading: false,
        error: failure.message,
      ),
      (user) => AuthState(
        status: AuthStatus.authenticated,
        user: user,
      ),
    );
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(loading: true, error: null);

    final result = await _repo.signIn(
      email: email,
      password: password,
    );

    state = result.fold(
      (failure) => state.copyWith(
        loading: false,
        error: failure.message,
      ),
      (user) => AuthState(
        status: AuthStatus.authenticated,
        user: user,
      ),
    );
  }

  Future<void> signOut() async {
    await _repo.signOut();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref.read(authRepositoryProvider)),
);

// Convenience selectors
final isAuthenticatedProvider = Provider<bool>(
  (ref) => ref.watch(authProvider).status == AuthStatus.authenticated,
);

final currentUserProvider = Provider<SilaUser?>(
  (ref) => ref.watch(authProvider).user,
);
