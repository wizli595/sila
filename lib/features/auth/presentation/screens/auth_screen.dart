import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sila/core/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/router/route_names.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.paddingLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xxxl),

              Text(
                _isSignUp ? l10n.signUp : l10n.signIn,
                style: AppTypography.headlineLarge,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.xxl),

              if (_isSignUp) ...[
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(hintText: l10n.fullName),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.md),
              ],

              TextField(
                controller: _emailController,
                decoration: InputDecoration(hintText: l10n.email),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppSpacing.md),

              TextField(
                controller: _passwordController,
                decoration: InputDecoration(hintText: l10n.password),
                obscureText: true,
                textInputAction: TextInputAction.done,
              ),

              const SizedBox(height: AppSpacing.xl),

              ElevatedButton(
                onPressed: () {
                  // TODO: Implement auth with Supabase
                  context.goNamed(RouteNames.gifts);
                },
                child: Text(_isSignUp ? l10n.signUp : l10n.signIn),
              ),

              const SizedBox(height: AppSpacing.md),

              TextButton(
                onPressed: () => setState(() => _isSignUp = !_isSignUp),
                child: Text(
                  _isSignUp ? l10n.signIn : l10n.signUp,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.iris,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
