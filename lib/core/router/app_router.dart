import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sila/core/providers/app_config.dart';
import 'package:sila/core/providers/app_prefs.dart';
import 'package:sila/core/widgets/error_screen.dart';
import 'package:sila/features/auth/presentation/providers/auth_provider.dart';
import 'package:sila/features/onboarding/presentation/screens/splash_screen.dart';
import 'package:sila/features/onboarding/presentation/screens/language_screen.dart';
import 'package:sila/features/onboarding/presentation/screens/how_it_works_screen.dart';
import 'package:sila/features/onboarding/presentation/screens/notify_prime_screen.dart';
import 'package:sila/features/onboarding/presentation/screens/update_required_screen.dart';
import 'package:sila/features/welcome/presentation/screens/welcome_screen.dart';
import 'package:sila/features/auth/presentation/screens/auth_screen.dart';
import 'package:sila/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:sila/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:sila/features/auth/presentation/screens/check_email_screen.dart';
import 'package:sila/features/gifts/presentation/screens/gifts_screen.dart';
import 'package:sila/features/gifts/presentation/screens/my_threads_screen.dart';
import 'package:sila/features/payment/presentation/screens/confirm_screen.dart';
import 'package:sila/features/payment/presentation/screens/pay_card_screen.dart';
import 'package:sila/features/payment/presentation/screens/pay_cash_screen.dart';
import 'package:sila/features/waiting/presentation/screens/waiting_screen.dart';
import 'package:sila/features/inbox/domain/entities/connection.dart';
import 'package:sila/features/inbox/presentation/screens/inbox_screen.dart';
import 'package:sila/features/inbox/presentation/screens/connection_detail_screen.dart';
import 'package:sila/features/settings/presentation/screens/settings_screen.dart';
import 'package:sila/features/settings/presentation/screens/about_screen.dart';
import 'package:sila/features/settings/presentation/screens/privacy_screen.dart';
import 'package:sila/features/settings/presentation/screens/terms_screen.dart';
import 'package:sila/features/settings/presentation/screens/change_password_screen.dart';
import 'package:sila/features/settings/presentation/screens/delete_account_screen.dart';
import 'package:sila/core/router/route_names.dart';

// Public routes — no auth needed. Gifts and confirm are browsable;
// the account is asked for at the moment of paying.
const _publicRoutes = {
  RoutePaths.splash,
  RoutePaths.language,
  RoutePaths.welcome,
  RoutePaths.howItWorks,
  RoutePaths.auth,
  RoutePaths.forgotPassword,
  RoutePaths.checkEmail,
  RoutePaths.gifts,
  RoutePaths.confirm,
  RoutePaths.updateRequired,
};

final appRouterProvider = Provider<GoRouter>((ref) {
  // Single router instance — auth/locale changes re-run redirect via
  // refreshListenable instead of recreating the router (which
  // would reset navigation to the initial location mid-flow).
  final refresh = ValueNotifier(0);
  ref.onDispose(refresh.dispose);
  ref.listen(authProvider, (_, _) => refresh.value++);
  ref.listen(localeProvider, (_, _) => refresh.value++);
  ref.listen(introSeenProvider, (_, _) => refresh.value++);
  ref.listen(updateRequiredProvider, (_, _) => refresh.value++);

  return GoRouter(
    initialLocation: RoutePaths.welcome,
    refreshListenable: refresh,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final localeChosen = ref.read(localeProvider) != null;
      final path = state.matchedLocation;
      final isPublic = _publicRoutes.contains(path);
      final isLoggedIn = authState.status == AuthStatus.authenticated;
      final isLoading = authState.status == AuthStatus.unknown;

      // Version below the required minimum — block everything
      if (ref.read(updateRequiredProvider).value ?? false) {
        return path == RoutePaths.updateRequired
            ? null
            : RoutePaths.updateRequired;
      }

      // First launch — choose a language before anything else
      if (!localeChosen) {
        return path == RoutePaths.language ? null : RoutePaths.language;
      }

      // Session still resolving — hold on the splash thread
      if (isLoading) {
        return path == RoutePaths.splash ? null : RoutePaths.splash;
      }

      // Arrived via password-recovery link → reset screen only
      if (authState.recovering) {
        return path == RoutePaths.resetPassword
            ? null
            : RoutePaths.resetPassword;
      }

      // First run — walk through the intro before anything else
      final introSeen = ref.read(introSeenProvider);
      if (!isLoggedIn && !introSeen && path != RoutePaths.howItWorks) {
        return RoutePaths.howItWorks;
      }

      // Not logged in on a protected route (e.g. right after signing out)
      // → home as a guest. Screens that need an account push /auth
      // explicitly at the moment it matters.
      if (!isLoggedIn && !isPublic) return RoutePaths.gifts;

      // Signed in — always land on home
      if (isLoggedIn &&
          (path == RoutePaths.splash ||
              path == RoutePaths.language ||
              path == RoutePaths.welcome ||
              path == RoutePaths.auth)) {
        return RoutePaths.gifts;
      }
      if (!isLoggedIn &&
          (path == RoutePaths.splash || path == RoutePaths.language)) {
        return RoutePaths.welcome;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: RoutePaths.splash,
        name: RouteNames.splash,
        pageBuilder: (context, state) => _fade(state, const SplashScreen()),
      ),
      GoRoute(
        path: RoutePaths.language,
        name: RouteNames.language,
        pageBuilder: (context, state) => _fade(state, const LanguageScreen()),
      ),
      GoRoute(
        path: RoutePaths.welcome,
        name: RouteNames.welcome,
        pageBuilder: (context, state) => _fade(state, const WelcomeScreen()),
      ),
      GoRoute(
        path: RoutePaths.howItWorks,
        name: RouteNames.howItWorks,
        pageBuilder: (context, state) => _fade(state, const HowItWorksScreen()),
      ),
      GoRoute(
        path: RoutePaths.auth,
        name: RouteNames.auth,
        pageBuilder: (context, state) => _fade(state, const AuthScreen()),
      ),
      GoRoute(
        path: RoutePaths.forgotPassword,
        name: RouteNames.forgotPassword,
        pageBuilder: (context, state) =>
            _fade(state, const ForgotPasswordScreen()),
      ),
      GoRoute(
        path: RoutePaths.resetPassword,
        name: RouteNames.resetPassword,
        pageBuilder: (context, state) =>
            _fade(state, const ResetPasswordScreen()),
      ),
      GoRoute(
        path: RoutePaths.checkEmail,
        name: RouteNames.checkEmail,
        pageBuilder: (context, state) => _fade(state, const CheckEmailScreen()),
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
        path: RoutePaths.payCard,
        name: RouteNames.payCard,
        pageBuilder: (context, state) => _fade(state, const PayCardScreen()),
      ),
      GoRoute(
        path: RoutePaths.payCash,
        name: RouteNames.payCash,
        pageBuilder: (context, state) => _fade(state, const PayCashScreen()),
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
      GoRoute(
        path: RoutePaths.connection,
        name: RouteNames.connection,
        pageBuilder: (context, state) => _fade(
          state,
          ConnectionDetailScreen(connection: state.extra as Connection?),
        ),
      ),
      GoRoute(
        path: RoutePaths.myThreads,
        name: RouteNames.myThreads,
        pageBuilder: (context, state) => _fade(state, const MyThreadsScreen()),
      ),
      GoRoute(
        path: RoutePaths.settings,
        name: RouteNames.settings,
        pageBuilder: (context, state) => _fade(state, const SettingsScreen()),
      ),
      GoRoute(
        path: RoutePaths.about,
        name: RouteNames.about,
        pageBuilder: (context, state) => _fade(state, const AboutScreen()),
      ),
      GoRoute(
        path: RoutePaths.privacy,
        name: RouteNames.privacy,
        pageBuilder: (context, state) => _fade(state, const PrivacyScreen()),
      ),
      GoRoute(
        path: RoutePaths.changePassword,
        name: RouteNames.changePassword,
        pageBuilder: (context, state) =>
            _fade(state, const ChangePasswordScreen()),
      ),
      GoRoute(
        path: RoutePaths.deleteAccount,
        name: RouteNames.deleteAccount,
        pageBuilder: (context, state) =>
            _fade(state, const DeleteAccountScreen()),
      ),
      GoRoute(
        path: RoutePaths.notifyPrime,
        name: RouteNames.notifyPrime,
        pageBuilder: (context, state) =>
            _fade(state, const NotifyPrimeScreen()),
      ),
      GoRoute(
        path: RoutePaths.terms,
        name: RouteNames.terms,
        pageBuilder: (context, state) => _fade(state, const TermsScreen()),
      ),
      GoRoute(
        path: RoutePaths.updateRequired,
        name: RouteNames.updateRequired,
        pageBuilder: (context, state) =>
            _fade(state, const UpdateRequiredScreen()),
      ),
    ],
    errorPageBuilder: (context, state) => _fade(state, const ErrorScreen()),
  );
});

/// Fade + gentle upward slide — visible but calm.
CustomTransitionPage _fade(GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, _, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.06),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 350),
    reverseTransitionDuration: const Duration(milliseconds: 250),
  );
}
