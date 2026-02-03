import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_radius.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_typography.dart';
import '../../../../ui/components/app_button.dart';
import '../../../../ui/components/app_text_field.dart';
import '../../../../ui/auth/auth_animated_backdrop.dart';
import '../../../../ui/primitives/app_icon.dart';
import '../../../../ui/primitives/app_text.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../../profile/domain/usecases/fetch_profile_usecase.dart';
import '../../../profile/domain/usecases/get_profile_usecase.dart';
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
  bool _didNavigate = false;
  String? _authError;

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

  void _handleState(AuthState state) async {
    if (!mounted) return;
    if (state.status == AuthStatus.authenticated) {
      if (_didNavigate) return;
      _didNavigate = true;
      final sl = ServiceLocator.instance;
      final fetchProfile = sl.get<FetchProfileUseCase>();
      final getProfile = sl.get<GetProfileUseCase>();
      try {
        await fetchProfile();
      } catch (_) {}
      final user = await getProfile();
      final hasPhoto = (user.photoUrl != null && user.photoUrl!.isNotEmpty) ||
          (user.avatarPath != null && user.avatarPath!.isNotEmpty);
      if (!mounted) return;
      if (hasPhoto) {
        context.goNamed(AppRouteNames.shell);
      } else {
        context.goNamed(AppRouteNames.profilePhoto);
      }
    } else if (state.status == AuthStatus.error && state.message != null) {
      setState(() {
        _authError = state.message;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message!)),
      );
      _didNavigate = false;
    }
  }

  Future<void> _submit() async {
    setState(() {
      _authError = null;
    });
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    await _cubit.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  Widget _socialButton(String asset) {
    return Expanded(
      child: GestureDetector(
        onTap: () {},
        child: Container(
          height: AppSpacing.buttonHeight,
          decoration: BoxDecoration(
            color: AppColors.surface.withAlpha(160),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: AppColors.textPrimary.withAlpha(30),
            ),
          ),
          child: Center(
            child: AppIcon(
              asset,
              size: AppSpacing.iconLg,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialRow() {
    return Row(
      children: [
        _socialButton('assets/social/google.svg'),
        const SizedBox(width: AppSpacing.md),
        _socialButton('assets/social/apple.svg'),
        const SizedBox(width: AppSpacing.md),
        _socialButton('assets/social/facebook.svg'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: const AuthAnimatedBackdrop(
              glowCenter: Alignment(0.0, -0.85),
            ),
          ),
          StreamBuilder<AuthState>(
            initialData: _cubit.state,
            stream: _cubit.stream,
            builder: (context, snapshot) {
              final state = snapshot.data ?? const AuthState();
              final isLoading = state.status == AuthStatus.loading;

              return SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      AppSpacing.xl,
                      AppSpacing.xl,
                      AppSpacing.xl + bottomInset,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: Image.asset(
                                'assets/branding/icon.png',
                                width: (AppSpacing.xxl + AppSpacing.xl) * 1.5,
                                height: (AppSpacing.xxl + AppSpacing.xl) * 1.5,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            AppText(
                              l10n.loginTitle,
                              style: AppTextStyle.h4,
                              align: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            AppText(
                              l10n.loginSubtitle,
                              style: AppTextStyle.body,
                              color: AppColors.textSecondary,
                              align: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            AppTextField(
                              hint: l10n.loginEmailLabel,
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              prefixIconAsset: 'assets/icons/mail.svg',
                              fillColor: AppColors.surface.withAlpha(120),
                              borderColor: AppColors.textPrimary.withAlpha(30),
                              height: AppSpacing.buttonHeight,
                              radius: AppRadius.lg,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              onChanged: (_) {
                                if (_authError != null) {
                                  setState(() {
                                    _authError = null;
                                  });
                                }
                              },
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
                              hint: l10n.loginPasswordLabel,
                              controller: _passwordController,
                              obscureText: true,
                              prefixIconAsset: 'assets/icons/eye_off.svg',
                              fillColor: AppColors.surface.withAlpha(120),
                              borderColor: AppColors.textPrimary.withAlpha(30),
                              height: AppSpacing.buttonHeight,
                              radius: AppRadius.lg,
                              errorText: _authError,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              onChanged: (_) {
                                if (_authError != null) {
                                  setState(() {
                                    _authError = null;
                                  });
                                }
                              },
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
                            const SizedBox(height: AppSpacing.xs),
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () {},
                                child: AppText(
                                  l10n.authForgotPassword,
                                  style: AppTextStyle.caption,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            AppButton(
                              label: l10n.loginCta,
                              onPressed: isLoading ? null : _submit,
                              isLoading: isLoading,
                              variant: AppButtonVariant.primary,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            _buildSocialRow(),
                            const SizedBox(height: AppSpacing.lg),
                            GestureDetector(
                              onTap: () =>
                                  context.goNamed(AppRouteNames.register),
                              child: Text.rich(
                                TextSpan(
                                  style: AppTypography.body.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: '${l10n.authDontHaveAccount} ',
                                    ),
                                    TextSpan(
                                      text: l10n.authActionRegister,
                                      style: AppTypography.body.copyWith(
                                        color: AppColors.brandRed,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
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
        ],
      ),
    );
  }
}
