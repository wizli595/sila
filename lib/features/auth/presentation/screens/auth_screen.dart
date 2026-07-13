import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sila/core/l10n/app_localizations.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/sila_thread.dart';
import '../providers/auth_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = true;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(authProvider.notifier);

    if (_isSignUp) {
      notifier.signUp(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );
    } else {
      notifier.signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = ref.watch(authProvider);

    // Show error snackbar / handle pending email confirmation
    ref.listen<AuthState>(authProvider, (prev, next) {
      if (next.error != null && prev?.error != next.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.error,
          ),
        );
        ref.read(authProvider.notifier).clearError();
      }
      if (next.needsEmailConfirm && !(prev?.needsEmailConfirm ?? false)) {
        context.goNamed(RouteNames.checkEmail);
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          // Warm glow at the top
          Positioned(
            top: -80,
            left: -60,
            right: -60,
            child: Container(
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.mango.withValues(alpha: 0.15),
                    AppColors.mango.withValues(alpha: 0.05),
                    AppColors.cream.withValues(alpha: 0.0),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // Thread at the top
          const Positioned(
            top: 50,
            left: 0,
            right: 0,
            height: 120,
            child: SilaThread.ambient(thickness: 2.5),
          ),

          // Form content
          SafeArea(
            child: SingleChildScrollView(
              padding: AppSpacing.paddingLg,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 140),

                    // "sila" branding
                    Text(
                      l10n.appNameLatin,
                      style: AppTypography.headlineLarge.copyWith(
                        fontSize: 32,
                        fontWeight: FontWeight.w400,
                        color: AppColors.charcoal,
                        letterSpacing: 3,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: AppSpacing.xs),

                    Text(
                      _isSignUp ? l10n.signUp : l10n.signIn,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.softGray,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: AppSpacing.xxl),

                    if (_isSignUp) ...[
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(hintText: l10n.fullName),
                        textInputAction: TextInputAction.next,
                        autocorrect: false,
                        validator: (v) => Validators.name(v),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],

                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(hintText: l10n.email),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
                      enableSuggestions: false,
                      // Latin content — keep it LTR inside RTL layouts
                      textDirection: TextDirection.ltr,
                      validator: (v) => Validators.email(v),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        hintText: l10n.password,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                            color: AppColors.softGray,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                      ),
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      textDirection: TextDirection.ltr,
                      onFieldSubmitted: (_) => _submit(),
                      validator: (v) => Validators.password(v),
                    ),

                    if (!_isSignUp)
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: TextButton(
                          onPressed: () =>
                              context.pushNamed(RouteNames.forgotPassword),
                          child: Text(
                            l10n.forgotPassword,
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.irisDeep,
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: AppSpacing.xl),

                    SizedBox(
                      height: 56,
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
                            : Text(
                                (_isSignUp ? l10n.signUp : l10n.signIn)
                                    .toLowerCase(),
                                style: AppTypography.labelLarge.copyWith(
                                  fontSize: 18,
                                  letterSpacing: 1,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    TextButton(
                      onPressed: () => setState(() {
                        _isSignUp = !_isSignUp;
                        _formKey.currentState?.reset();
                        _nameController.clear();
                        _passwordController.clear();
                      }),
                      child: Text(
                        _isSignUp ? l10n.iHaveAccount : l10n.dontHaveAccount,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.softGray,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
