import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../providers/admin_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(adminStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord'),
        actions: [
          IconButton(
            tooltip: 'Actualiser',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(adminStatsProvider),
          ),
        ],
      ),
      body: stats.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (s) => Padding(
          padding: AppSpacing.paddingLg,
          child: Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              _StatCard(
                label: 'En préparation',
                value: s.pending,
                icon: Icons.hourglass_top_rounded,
                color: AppColors.mango,
              ),
              _StatCard(
                label: 'Payés',
                value: s.paid,
                icon: Icons.payments_rounded,
                color: AppColors.iris,
              ),
              _StatCard(
                label: 'Livrés',
                value: s.delivered,
                icon: Icons.local_shipping_rounded,
                color: AppColors.success,
              ),
              _StatCard(
                label: 'Liens créés',
                value: s.connections,
                icon: Icons.favorite_rounded,
                color: AppColors.watermelon,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: 220,
        padding: AppSpacing.paddingLg,
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: AppSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$value', style: AppTypography.headlineLarge),
                Text(
                  label,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.softGray,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
