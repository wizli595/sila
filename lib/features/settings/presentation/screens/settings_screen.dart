import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sila/core/l10n/app_localizations.dart';

import '../../../../core/providers/app_prefs.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(currentUserProvider);
    final locale = ref.watch(localeProvider)?.languageCode ?? 'ar';
    final notifications = ref.watch(notificationsEnabledProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: AppSpacing.paddingLg,
        children: [
          // Profile
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.person_outline_rounded,
                color: AppColors.iris,
              ),
              title: Text(
                user?.fullName ?? '',
                style: AppTypography.titleLarge,
              ),
              trailing: IconButton(
                tooltip: l10n.editName,
                icon: const Icon(
                  Icons.edit_rounded,
                  color: AppColors.softGray,
                  size: 20,
                ),
                onPressed: () => _editName(context, ref, user?.fullName ?? ''),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Language
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.language_rounded,
                color: AppColors.mango,
              ),
              title: Text(l10n.language),
              trailing: Text(
                locale == 'ar' ? 'العربية' : 'Français',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.softGray,
                ),
              ),
              onTap: () => _pickLanguage(context, ref, locale),
            ),
          ),

          // Notifications — the only one: "your connection arrived"
          Card(
            child: SwitchListTile(
              secondary: const Icon(
                Icons.notifications_none_rounded,
                color: AppColors.watermelon,
              ),
              title: Text(l10n.notifications),
              subtitle: Text(
                l10n.notifyArrival,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.softGray,
                  fontSize: 12,
                ),
              ),
              value: notifications,
              onChanged: (v) =>
                  ref.read(notificationsEnabledProvider.notifier).set(v),
            ),
          ),

          // Change password
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.lock_outline_rounded,
                color: AppColors.iris,
              ),
              title: Text(l10n.changePassword),
              onTap: () => context.pushNamed(RouteNames.changePassword),
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // About + privacy
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.info_outline_rounded,
                color: AppColors.softGray,
              ),
              title: Text(l10n.about),
              onTap: () => context.pushNamed(RouteNames.about),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.privacy_tip_outlined,
                color: AppColors.softGray,
              ),
              title: Text(l10n.privacyPolicy),
              onTap: () => context.pushNamed(RouteNames.privacy),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.description_outlined,
                color: AppColors.softGray,
              ),
              title: Text(l10n.terms),
              onTap: () => context.pushNamed(RouteNames.terms),
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Sign out
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.logout_rounded,
                color: AppColors.softGray,
              ),
              title: Text(l10n.signOut),
              onTap: () => _confirmSignOut(context, ref),
            ),
          ),

          // Delete account — visually separated, danger color
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.delete_forever_rounded,
                color: AppColors.error,
              ),
              title: Text(
                l10n.deleteAccount,
                style: AppTypography.bodyLarge.copyWith(color: AppColors.error),
              ),
              onTap: () => context.pushNamed(RouteNames.deleteAccount),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editName(
    BuildContext context,
    WidgetRef ref,
    String current,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: current);
    final formKey = GlobalKey<FormState>();

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.editName),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(hintText: l10n.fullName),
            validator: Validators.name,
            autofocus: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, true);
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );

    if (saved == true) {
      await ref.read(authProvider.notifier).updateName(controller.text);
    }
  }

  Future<void> _pickLanguage(
    BuildContext context,
    WidgetRef ref,
    String current,
  ) async {
    final code = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(AppLocalizations.of(context)!.language),
        children: [
          for (final (code, label) in [('ar', 'العربية'), ('fr', 'Français')])
            ListTile(
              title: Text(label),
              trailing: current == code
                  ? const Icon(Icons.check_rounded, color: AppColors.irisDeep)
                  : null,
              onTap: () => Navigator.pop(context, code),
            ),
        ],
      ),
    );

    if (code != null) {
      await ref.read(localeProvider.notifier).set(code);
    }
  }

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.signOut),
        content: Text(l10n.signOutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.signOut),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(authProvider.notifier).signOut();
      // Settings is pushed on top of home — leave it explicitly
      if (context.mounted) context.goNamed(RouteNames.gifts);
    }
  }
}
