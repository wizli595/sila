import 'dart:async';

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

  /// Sign-up done, waiting for the confirmation email link.
  final bool needsEmailConfirm;

  /// Arrived via a password-recovery deep link — force the reset screen.
  final bool recovering;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.error,
    this.loading = false,
    this.needsEmailConfirm = false,
    this.recovering = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    SilaUser? user,
    String? error,
    bool? loading,
    bool? needsEmailConfirm,
    bool? recovering,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
      loading: loading ?? this.loading,
      needsEmailConfirm: needsEmailConfirm ?? this.needsEmailConfirm,
      recovering: recovering ?? this.recovering,
    );
  }
}

// Auth notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;
  StreamSubscription<AuthChangeEvent>? _events;

  AuthNotifier(this._repo) : super(const AuthState()) {
    _init();
    _events = _repo.events.listen((event) {
      if (event == AuthChangeEvent.passwordRecovery) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          recovering: true,
        );
      }
    });
  }

  @override
  void dispose() {
    _events?.cancel();
    super.dispose();
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

    state = result.fold((failure) {
      if (failure.code == AuthRepositoryImpl.confirmEmailCode) {
        return const AuthState(
          status: AuthStatus.unauthenticated,
          needsEmailConfirm: true,
        );
      }
      return state.copyWith(loading: false, error: failure.message);
    }, (user) => AuthState(status: AuthStatus.authenticated, user: user));
  }

  Future<void> signIn({required String email, required String password}) async {
    state = state.copyWith(loading: true, error: null);

    final result = await _repo.signIn(email: email, password: password);

    state = result.fold(
      (failure) => state.copyWith(loading: false, error: failure.message),
      (user) => AuthState(status: AuthStatus.authenticated, user: user),
    );
  }

  Future<void> signOut() async {
    await _repo.signOut();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<bool> sendPasswordReset(String email) async {
    state = state.copyWith(loading: true, error: null);
    final result = await _repo.sendPasswordReset(email);
    return result.fold(
      (failure) {
        state = state.copyWith(loading: false, error: failure.message);
        return false;
      },
      (_) {
        state = state.copyWith(loading: false);
        return true;
      },
    );
  }

  Future<bool> updatePassword(String newPassword) async {
    state = state.copyWith(loading: true, error: null);
    final result = await _repo.updatePassword(newPassword);
    return result.fold(
      (failure) {
        state = state.copyWith(loading: false, error: failure.message);
        return false;
      },
      (_) {
        // Recovery complete — resume normal navigation
        state = state.copyWith(loading: false, recovering: false);
        return true;
      },
    );
  }

  Future<bool> updateName(String fullName) async {
    final result = await _repo.updateName(fullName);
    return result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
        return false;
      },
      (user) {
        state = state.copyWith(user: user);
        return true;
      },
    );
  }

  Future<bool> deleteAccount(String password) async {
    state = state.copyWith(loading: true, error: null);
    final result = await _repo.deleteAccount(password);
    return result.fold(
      (failure) {
        state = state.copyWith(loading: false, error: failure.message);
        return false;
      },
      (_) {
        state = const AuthState(status: AuthStatus.unauthenticated);
        return true;
      },
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearEmailConfirm() {
    state = state.copyWith(needsEmailConfirm: false);
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
