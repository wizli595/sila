import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/gift_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../features/gifts/domain/entities/gift_type.dart';
import '../providers/admin_providers.dart';

class GiftTypesScreen extends ConsumerWidget {
  const GiftTypesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final types = ref.watch(adminGiftTypesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Types de dons')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEditDialog(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Ajouter'),
      ),
      body: types.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (items) => ListView.separated(
          padding: AppSpacing.paddingLg,
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, index) {
            final type = items[index];
            return Card(
              child: ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.mango.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(giftIcon(type.icon), color: AppColors.mango),
                ),
                title: Text('${type.nameFr} — ${type.nameAr}'),
                subtitle: Text(
                  '${(type.defaultPrice / 100).toStringAsFixed(2)} MAD',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.softGray,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch(
                      value: type.isActive,
                      onChanged: (v) async {
                        await ref
                            .read(adminRepositoryProvider)
                            .setGiftTypeActive(type.id, v);
                        ref.invalidate(adminGiftTypesProvider);
                      },
                    ),
                    IconButton(
                      tooltip: 'Modifier',
                      icon: const Icon(
                        Icons.edit_rounded,
                        color: AppColors.softGray,
                      ),
                      onPressed: () =>
                          _showEditDialog(context, ref, existing: type),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _showEditDialog(
    BuildContext context,
    WidgetRef ref, {
    GiftType? existing,
  }) async {
    final formKey = GlobalKey<FormState>();
    final nameFr = TextEditingController(text: existing?.nameFr);
    final nameAr = TextEditingController(text: existing?.nameAr);
    final price = TextEditingController(
      text: existing != null
          ? (existing.defaultPrice / 100).toStringAsFixed(2)
          : '',
    );
    final impactFr = TextEditingController(text: existing?.impactFr);
    final impactAr = TextEditingController(text: existing?.impactAr);
    var icon = existing?.icon ?? giftIcons.keys.first;

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existing == null ? 'Nouveau type de don' : 'Modifier'),
        content: StatefulBuilder(
          builder: (context, setState) => Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameFr,
                  decoration: const InputDecoration(hintText: 'Nom (français)'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Requis' : null,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: nameAr,
                  decoration: const InputDecoration(hintText: 'Nom (arabe)'),
                  textDirection: TextDirection.rtl,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Requis' : null,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: price,
                  decoration: const InputDecoration(hintText: 'Prix (MAD)'),
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                      double.tryParse(v ?? '') == null ? 'Prix invalide' : null,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: impactFr,
                  decoration: const InputDecoration(
                    hintText: 'Impact (français) — ex: nourrit une famille',
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: impactAr,
                  decoration: const InputDecoration(hintText: 'Impact (arabe)'),
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<String>(
                  initialValue: icon,
                  items: [
                    for (final name in giftIcons.keys)
                      DropdownMenuItem(
                        value: name,
                        child: Row(
                          children: [
                            Icon(giftIcons[name], color: AppColors.mango),
                            const SizedBox(width: AppSpacing.sm),
                            Text(name),
                          ],
                        ),
                      ),
                  ],
                  onChanged: (v) => setState(() => icon = v ?? icon),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );

    if (saved != true) return;

    final repo = ref.read(adminRepositoryProvider);
    final centimes = (double.parse(price.text) * 100).round();

    String? clean(TextEditingController c) =>
        c.text.trim().isEmpty ? null : c.text.trim();

    final result = existing == null
        ? await repo.addGiftType(
            nameAr: nameAr.text.trim(),
            nameFr: nameFr.text.trim(),
            icon: icon,
            priceCentimes: centimes,
            impactAr: clean(impactAr),
            impactFr: clean(impactFr),
          )
        : await repo.updateGiftType(
            id: existing.id,
            nameAr: nameAr.text.trim(),
            nameFr: nameFr.text.trim(),
            icon: icon,
            priceCentimes: centimes,
            impactAr: clean(impactAr),
            impactFr: clean(impactFr),
          );

    result.fold((failure) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }, (_) => ref.invalidate(adminGiftTypesProvider));
  }
}
