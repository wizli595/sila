import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/validators.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

class AdminLoginScreen extends ConsumerStatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  ConsumerState<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends ConsumerState<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    ref
        .read(authProvider.notifier)
        .signIn(
          email: _emailController.text,
          password: _passwordController.text,
        );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    ref.listen<AuthState>(authProvider, (prev, next) {
      if (next.error != null && prev?.error != next.error) {
        _showError(next.error!);
        ref.read(authProvider.notifier).clearError();
      }
      // Signed in but not an admin — reject
      if (next.status == AuthStatus.authenticated &&
          next.user != null &&
          !next.user!.isAdmin) {
        ref.read(authProvider.notifier).signOut();
        _showError('Accès refusé — ce compte n\'est pas administrateur.');
      }
    });

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'صِلة',
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 40,
                    color: AppColors.watermelonDeep,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Panneau d\'administration',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.softGray,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(hintText: 'E-mail'),
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  validator: Validators.email,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(hintText: 'Mot de passe'),
                  obscureText: true,
                  onFieldSubmitted: (_) => _submit(),
                  validator: Validators.password,
                ),
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: auth.loading ? null : _submit,
                    child: auth.loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Se connecter'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
