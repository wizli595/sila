import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/welcome/presentation/screens/welcome_screen.dart';
import '../../features/auth/presentation/screens/auth_screen.dart';
import '../../features/gifts/presentation/screens/gifts_screen.dart';
import '../../features/payment/presentation/screens/confirm_screen.dart';
import '../../features/waiting/presentation/screens/waiting_screen.dart';
import '../../features/inbox/presentation/screens/inbox_screen.dart';
import 'route_names.dart';

// Public routes — no auth needed
const _publicRoutes = {RoutePaths.welcome, RoutePaths.auth};

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: RoutePaths.welcome,
    redirect: (context, state) {
      final path = state.matchedLocation;
      final isPublic = _publicRoutes.contains(path);
      final isLoggedIn = authState.status == AuthStatus.authenticated;
      final isLoading = authState.status == AuthStatus.unknown;

      // Still checking session — don't redirect yet
      if (isLoading) return null;

      // Not logged in + trying to access protected route → auth
      if (!isLoggedIn && !isPublic) return RoutePaths.auth;

      // Logged in + on welcome or auth → go to gifts
      if (isLoggedIn && (path == RoutePaths.welcome || path == RoutePaths.auth)) {
        return RoutePaths.gifts;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: RoutePaths.welcome,
        name: RouteNames.welcome,
        pageBuilder: (context, state) => _fade(state, const WelcomeScreen()),
      ),
      GoRoute(
        path: RoutePaths.auth,
        name: RouteNames.auth,
        pageBuilder: (context, state) => _fade(state, const AuthScreen()),
      ),
      GoRoute(
        path: RoutePaths.gifts,
        name: RouteNames.gifts,
        pageBuilder: (context, state) => _fade(state, const GiftsScreen()),
      ),
      GoRoute(
        path: RoutePaths.confirm,
        name: RouteNames.confirm,
        pageBuilder: (context, state) => _fade(state, const ConfirmScreen()),
      ),
      GoRoute(
        path: RoutePaths.waiting,
        name: RouteNames.waiting,
        pageBuilder: (context, state) => _fade(state, const WaitingScreen()),
      ),
      GoRoute(
        path: RoutePaths.inbox,
        name: RouteNames.inbox,
        pageBuilder: (context, state) => _fade(state, const InboxScreen()),
      ),
    ],
  );
});

CustomTransitionPage _fade(GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, _, child) {
      return FadeTransition(
        opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 400),
  );
}
