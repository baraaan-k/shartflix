import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../app/router/app_router.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../ui/components/app_button.dart';
import '../../../../ui/components/app_text_field.dart';
import '../../../../ui/primitives/app_card.dart';
import '../../../../ui/primitives/app_text.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late final AuthCubit _cubit;
  StreamSubscription<AuthState>? _subscription;

  @override
  void initState() {
    super.initState();
    final sl = ServiceLocator.instance;
    _cubit = AuthCubit(
      loginUseCase: sl.get<LoginUseCase>(),
      registerUseCase: sl.get<RegisterUseCase>(),
      logoutUseCase: sl.get<LogoutUseCase>(),
    );
    _subscription = _cubit.stream.listen(_handleState);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _cubit.close();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleState(AuthState state) {
    if (!mounted) return;
    if (state.status == AuthStatus.authenticated) {
      context.goNamed(AppRouteNames.shell);
    } else if (state.status == AuthStatus.error && state.message != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message!)),
      );
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    await _cubit.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: StreamBuilder<AuthState>(
        initialData: _cubit.state,
        stream: _cubit.stream,
        builder: (context, snapshot) {
          final state = snapshot.data ?? const AuthState();
          final isLoading = state.status == AuthStatus.loading;

          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppText(l10n.loginTitle, style: AppTextStyle.h1),
                        const SizedBox(height: AppSpacing.sm),
                        AppText(
                          l10n.loginSubtitle,
                          style: AppTextStyle.body,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        AppCard(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (state.status == AuthStatus.error &&
                                  state.message != null) ...[
                                AppText(
                                  state.message!,
                                  style: AppTextStyle.caption,
                                  color: AppColors.danger,
                                ),
                                const SizedBox(height: AppSpacing.md),
                              ],
                              AppTextField(
                                label: l10n.loginEmailLabel,
                                hint: l10n.loginEmailHint,
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                prefixIconAsset: 'assets/icons/mail.svg',
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return l10n.loginEmailRequired;
                                  }
                                  if (!value.contains('@')) {
                                    return l10n.loginEmailInvalid;
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              AppTextField(
                                label: l10n.loginPasswordLabel,
                                hint: l10n.loginPasswordHint,
                                controller: _passwordController,
                                obscureText: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return l10n.loginPasswordRequired;
                                  }
                                  if (value.length < 6) {
                                    return l10n.loginPasswordMin;
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: AppSpacing.xl),
                              AppButton(
                                label: l10n.loginCta,
                                onPressed: isLoading ? null : _submit,
                                isLoading: isLoading,
                                variant: AppButtonVariant.primary,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              AppButton(
                                label: l10n.loginCreateAccount,
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        context.pushNamed(
                                          AppRouteNames.register,
                                        );
                                      },
                                variant: AppButtonVariant.ghost,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
