import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/welcome/presentation/screens/welcome_screen.dart';
import '../../features/auth/presentation/screens/auth_screen.dart';
import '../../features/gifts/presentation/screens/gifts_screen.dart';
import '../../features/payment/presentation/screens/confirm_screen.dart';
import '../../features/waiting/presentation/screens/waiting_screen.dart';
import '../../features/inbox/presentation/screens/inbox_screen.dart';
import 'route_names.dart';

final appRouter = GoRouter(
  initialLocation: RoutePaths.welcome,
  routes: [
    GoRoute(
      path: RoutePaths.welcome,
      name: RouteNames.welcome,
      pageBuilder: (context, state) => _buildPage(
        state,
        const WelcomeScreen(),
      ),
    ),
    GoRoute(
      path: RoutePaths.auth,
      name: RouteNames.auth,
      pageBuilder: (context, state) => _buildPage(
        state,
        const AuthScreen(),
      ),
    ),
    GoRoute(
      path: RoutePaths.gifts,
      name: RouteNames.gifts,
      pageBuilder: (context, state) => _buildPage(
        state,
        const GiftsScreen(),
      ),
    ),
    GoRoute(
      path: RoutePaths.confirm,
      name: RouteNames.confirm,
      pageBuilder: (context, state) => _buildPage(
        state,
        const ConfirmScreen(),
      ),
    ),
    GoRoute(
      path: RoutePaths.waiting,
      name: RouteNames.waiting,
      pageBuilder: (context, state) => _buildPage(
        state,
        const WaitingScreen(),
      ),
    ),
    GoRoute(
      path: RoutePaths.inbox,
      name: RouteNames.inbox,
      pageBuilder: (context, state) => _buildPage(
        state,
        const InboxScreen(),
      ),
    ),
  ],
);

CustomTransitionPage _buildPage(GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 400),
  );
}
