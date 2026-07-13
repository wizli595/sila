import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_colors.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import 'screens/admin_login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/gift_types_screen.dart';
import 'screens/deliveries_screen.dart';

final adminRouterProvider = Provider<GoRouter>((ref) {
  // Single router instance — see appRouterProvider for rationale
  final refresh = ValueNotifier(0);
  ref.onDispose(refresh.dispose);
  ref.listen(authProvider, (_, _) => refresh.value++);

  return GoRouter(
    initialLocation: '/dashboard',
    refreshListenable: refresh,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      if (authState.status == AuthStatus.unknown) return null;

      final isAdmin =
          authState.status == AuthStatus.authenticated &&
          (authState.user?.isAdmin ?? false);
      final onLogin = state.matchedLocation == '/login';

      if (!isAdmin) return onLogin ? null : '/login';
      if (onLogin) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const AdminLoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) =>
            _AdminShell(location: state.matchedLocation, child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/gift-types',
            builder: (context, state) => const GiftTypesScreen(),
          ),
          GoRoute(
            path: '/deliveries',
            builder: (context, state) => const DeliveriesScreen(),
          ),
        ],
      ),
    ],
  );
});

const _destinations = [
  (path: '/dashboard', icon: Icons.dashboard_rounded, label: 'Tableau de bord'),
  (
    path: '/gift-types',
    icon: Icons.card_giftcard_rounded,
    label: 'Types de dons',
  ),
  (
    path: '/deliveries',
    icon: Icons.local_shipping_rounded,
    label: 'Livraisons',
  ),
];

class _AdminShell extends ConsumerWidget {
  final String location;
  final Widget child;

  const _AdminShell({required this.location, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = _destinations.indexWhere((d) => d.path == location);

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: index < 0 ? 0 : index,
            onDestinationSelected: (i) => context.go(_destinations[i].path),
            labelType: NavigationRailLabelType.all,
            backgroundColor: Colors.white,
            indicatorColor: AppColors.mango.withValues(alpha: 0.2),
            leading: const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'صِلة',
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 24,
                  color: AppColors.watermelonDeep,
                ),
              ),
            ),
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: IconButton(
                    tooltip: 'Se déconnecter',
                    icon: const Icon(
                      Icons.logout_rounded,
                      color: AppColors.softGray,
                    ),
                    onPressed: () => ref.read(authProvider.notifier).signOut(),
                  ),
                ),
              ),
            ),
            destinations: [
              for (final d in _destinations)
                NavigationRailDestination(
                  icon: Icon(d.icon),
                  label: Text(d.label),
                ),
            ],
          ),
          const VerticalDivider(width: 1, color: AppColors.lightGray),
          Expanded(child: child),
        ],
      ),
    );
  }
}
