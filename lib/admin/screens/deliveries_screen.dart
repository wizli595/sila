import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../features/gifts/domain/entities/gift.dart';
import '../data/admin_repository.dart';
import '../providers/admin_providers.dart';

class DeliveriesScreen extends ConsumerWidget {
  const DeliveriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gifts = ref.watch(adminGiftsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Livraisons'),
        actions: [
          IconButton(
            tooltip: 'Actualiser',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(adminGiftsProvider),
          ),
        ],
      ),
      body: gifts.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (items) => items.isEmpty
            ? Center(
                child: Text(
                  'Aucun don pour l\'instant',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.softGray,
                  ),
                ),
              )
            : ListView.separated(
                padding: AppSpacing.paddingLg,
                itemCount: items.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) => _GiftRow(item: items[index]),
              ),
      ),
    );
  }
}

class _GiftRow extends ConsumerWidget {
  final AdminGift item;

  const _GiftRow({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gift = item.gift;

    return Card(
      child: ListTile(
        title: Text('${item.typeName} — ${item.giverName}'),
        subtitle: Text(
          '${DateFormat.yMMMd('fr').format(gift.createdAt)}'
          '  ·  ${(gift.amount / 100).toStringAsFixed(2)} MAD'
          '  ·  ${gift.paymentMethod}',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.softGray),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StatusChip(status: gift.status),
            const SizedBox(width: AppSpacing.md),
            switch (gift.status) {
              GiftStatus.pending => ElevatedButton(
                onPressed: () => _markPaid(context, ref, gift.id),
                child: const Text('Marquer payé'),
              ),
              GiftStatus.paid => ElevatedButton.icon(
                onPressed: () => _showDeliverDialog(context, ref, gift.id),
                icon: const Icon(Icons.local_shipping_rounded, size: 18),
                label: const Text('Livrer'),
              ),
              _ => const Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
              ),
            },
          ],
        ),
      ),
    );
  }

  Future<void> _markPaid(
    BuildContext context,
    WidgetRef ref,
    String giftId,
  ) async {
    final result = await ref.read(adminRepositoryProvider).markPaid(giftId);
    result.fold((failure) => _snack(context, failure.message, error: true), (
      _,
    ) {
      ref.invalidate(adminGiftsProvider);
      ref.invalidate(adminStatsProvider);
    });
  }

  Future<void> _showDeliverDialog(
    BuildContext context,
    WidgetRef ref,
    String giftId,
  ) async {
    final recipient = TextEditingController();
    final noteAr = TextEditingController();
    final noteFr = TextEditingController();
    XFile? photo;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Livraison + merci'),
        content: StatefulBuilder(
          builder: (context, setState) => SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: recipient,
                  decoration: const InputDecoration(
                    hintText: 'Nom du bénéficiaire (optionnel)',
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: noteAr,
                  decoration: const InputDecoration(
                    hintText: 'Note de merci (arabe)',
                  ),
                  textDirection: TextDirection.rtl,
                  maxLines: 2,
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: noteFr,
                  decoration: const InputDecoration(
                    hintText: 'Note de merci (français)',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: AppSpacing.md),
                OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                    );
                    if (picked != null) setState(() => photo = picked);
                  },
                  icon: const Icon(Icons.photo_camera_rounded),
                  label: Text(
                    photo == null
                        ? 'Choisir la photo de remerciement'
                        : 'Photo : ${photo!.name}',
                  ),
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
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmer la livraison'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final bytes = photo != null ? await photo!.readAsBytes() : null;
    final result = await ref
        .read(adminRepositoryProvider)
        .deliver(
          giftId: giftId,
          recipientName: recipient.text.trim().isEmpty
              ? null
              : recipient.text.trim(),
          noteAr: noteAr.text.trim().isEmpty ? null : noteAr.text.trim(),
          noteFr: noteFr.text.trim().isEmpty ? null : noteFr.text.trim(),
          photoBytes: bytes,
        );

    result.fold((failure) => _snack(context, failure.message, error: true), (
      _,
    ) {
      ref.invalidate(adminGiftsProvider);
      ref.invalidate(adminStatsProvider);
      _snack(context, 'Livraison enregistrée — le lien est créé.');
    });
  }

  void _snack(BuildContext context, String message, {bool error = false}) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? AppColors.error : AppColors.success,
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final GiftStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      GiftStatus.pending => ('En préparation', AppColors.mango),
      GiftStatus.paid => ('Payé', AppColors.iris),
      GiftStatus.delivered => ('Livré', AppColors.success),
      GiftStatus.thanked => ('Remercié', AppColors.watermelon),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppTypography.bodyMedium.copyWith(
          color: AppColors.charcoal,
          fontSize: 12,
        ),
      ),
    );
  }
}
