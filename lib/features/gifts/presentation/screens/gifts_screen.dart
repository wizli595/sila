import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sila/core/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/router/route_names.dart';

// Placeholder gift types until Supabase is wired
const _placeholderGifts = [
  ('food_basket', 'سلة غذائية', 'Panier alimentaire', Icons.shopping_basket_rounded),
  ('school', 'أدوات مدرسية', 'Fournitures scolaires', Icons.menu_book_rounded),
  ('clothing', 'ملابس دافئة', 'Vêtements chauds', Icons.checkroom_rounded),
  ('medicine', 'أدوية', 'Médicaments', Icons.medical_services_rounded),
  ('water', 'ماء نظيف', 'Eau potable', Icons.water_drop_rounded),
];

class GiftsScreen extends StatelessWidget {
  const GiftsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.paddingLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xl),

              Text(
                l10n.chooseGift,
                style: AppTypography.headlineLarge,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.xl),

              Expanded(
                child: ListView.separated(
                  itemCount: _placeholderGifts.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final gift = _placeholderGifts[index];
                    return _GiftCard(
                      name: isArabic ? gift.$2 : gift.$3,
                      icon: gift.$4,
                      onTap: () => context.goNamed(RouteNames.confirm),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GiftCard extends StatelessWidget {
  final String name;
  final IconData icon;
  final VoidCallback onTap;

  const _GiftCard({
    required this.name,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.mango.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.mango),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(name, style: AppTypography.titleLarge),
              const Spacer(),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: AppColors.softGray,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
