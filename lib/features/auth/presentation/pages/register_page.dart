import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_radius.dart';
import '../../../../theme/app_shadows.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_typography.dart';
import '../../../../ui/components/app_button.dart';
import '../../../../ui/components/app_text_field.dart';
import '../../../../ui/primitives/app_icon.dart';
import '../../../../ui/primitives/app_text.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../../profile/domain/usecases/fetch_profile_usecase.dart';
import '../../../profile/domain/usecases/get_profile_usecase.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _acceptedTerms = false;
  bool _showTermsError = false;

  late final AuthCubit _cubit;
  StreamSubscription<AuthState>? _subscription;
  bool _didNavigate = false;

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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message!)),
      );
      _didNavigate = false;
    }
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!_acceptedTerms) {
      setState(() {
        _showTermsError = true;
      });
    }
    if (!isValid || !_acceptedTerms) {
      return;
    }
    await _cubit.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  Widget _posterCard({
    required double width,
    required double height,
    required List<Color> colors,
    required double angle,
    required Offset offset,
  }) {
    return Transform.translate(
      offset: offset,
      child: Transform.rotate(
        angle: angle,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: colors,
              ),
              border: Border.all(color: AppColors.borderSoft),
              boxShadow: AppShadows.softCard,
            ),
            child: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromRGBO(0, 0, 0, 0.0),
                    Color.fromRGBO(0, 0, 0, 0.35),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPosterRow() {
    return SizedBox(
      height: AppSpacing.xxl * 3,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _posterCard(
            width: AppSpacing.xxl * 2,
            height: AppSpacing.xxl * 3,
            colors: [
              AppColors.surface2,
              AppColors.surface,
              AppColors.brandRed2.withAlpha(180),
            ],
            angle: -math.pi / 16,
            offset: Offset(-AppSpacing.xxl * 2, AppSpacing.sm),
          ),
          _posterCard(
            width: AppSpacing.xxl * 2 + AppSpacing.lg,
            height: AppSpacing.xxl * 3 + AppSpacing.md,
            colors: [
              AppColors.surface,
              AppColors.surface2,
              AppColors.brandRed.withAlpha(200),
            ],
            angle: -math.pi / 32,
            offset: Offset(-AppSpacing.xl, 0),
          ),
          _posterCard(
            width: AppSpacing.xxl * 2 + AppSpacing.xl,
            height: AppSpacing.xxl * 3 + AppSpacing.lg,
            colors: [
              AppColors.surface,
              AppColors.surface2,
              AppColors.brandRed.withAlpha(210),
            ],
            angle: math.pi / 40,
            offset: Offset(AppSpacing.xs, -AppSpacing.xs),
          ),
          _posterCard(
            width: AppSpacing.xxl * 2,
            height: AppSpacing.xxl * 3,
            colors: [
              AppColors.surface2,
              AppColors.surface,
              AppColors.brandRed2.withAlpha(170),
            ],
            angle: math.pi / 18,
            offset: Offset(AppSpacing.xxl * 2, AppSpacing.sm),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsRow(AppLocalizations l10n) {
    final borderColor = _showTermsError
        ? AppColors.brandRed
        : AppColors.textPrimary.withAlpha(30);
    final fillColor = Colors.transparent;
    final iconColor = AppColors.textSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _acceptedTerms = !_acceptedTerms;
              if (_acceptedTerms) {
                _showTermsError = false;
              }
            });
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: AppSpacing.lg + AppSpacing.xs,
                height: AppSpacing.lg + AppSpacing.xs,
                decoration: BoxDecoration(
                  color: fillColor,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(color: borderColor),
                ),
                child: _acceptedTerms
                    ? const Center(
                        child: AppIcon(
                          'assets/icons/check_on.svg',
                          size: AppSpacing.iconMd,
                        ),
                      )
                    : Center(
                        child: AppIcon(
                          'assets/icons/check_off.svg',
                          size: AppSpacing.iconMd,
                          color: iconColor,
                        ),
                      ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppText(
                  l10n.registerTermsCaption,
                  style: AppTextStyle.caption,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ),
        if (_showTermsError) ...[
          const SizedBox(height: AppSpacing.xs),
          AppText(
            l10n.registerTermsError,
            style: AppTextStyle.caption,
            color: AppColors.danger,
          ),
        ],
      ],
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
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.brandRed2.withAlpha(200),
                    AppColors.bg,
                    AppColors.bg,
                  ],
                ),
              ),
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
                            _buildPosterRow(),
                            const SizedBox(height: AppSpacing.lg),
                            Align(
                              alignment: Alignment.center,
                              child: Image.asset(
                                'assets/branding/icon.png',
                                width: AppSpacing.xxl + AppSpacing.lg,
                                height: AppSpacing.xxl + AppSpacing.lg,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            AppText(
                              l10n.registerTitle,
                              style: AppTextStyle.h1,
                              align: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            AppText(
                              l10n.registerSubtitle,
                              style: AppTextStyle.body,
                              color: AppColors.textSecondary,
                              align: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            AppTextField(
                              hint: l10n.registerNameLabel,
                              controller: _nameController,
                              textCapitalization:
                                  TextCapitalization.words,
                              prefixIconAsset: 'assets/icons/profile.svg',
                              fillColor: AppColors.surface.withAlpha(120),
                              borderColor: AppColors.textPrimary.withAlpha(30),
                              focusedBorderColor: AppColors.brandRed,
                              height: AppSpacing.buttonHeight,
                              radius: AppRadius.lg,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return l10n.registerNameRequired;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            AppTextField(
                              hint: l10n.registerEmailLabel,
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              prefixIconAsset: 'assets/icons/mail.svg',
                              fillColor: AppColors.surface.withAlpha(120),
                              borderColor: AppColors.textPrimary.withAlpha(30),
                              focusedBorderColor: AppColors.brandRed,
                              height: AppSpacing.buttonHeight,
                              radius: AppRadius.lg,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return l10n.registerEmailRequired;
                                }
                                if (!value.contains('@')) {
                                  return l10n.registerEmailInvalid;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            AppTextField(
                              hint: l10n.registerPasswordLabel,
                              controller: _passwordController,
                              obscureText: true,
                              prefixIconAsset: 'assets/icons/eye_off.svg',
                              fillColor: AppColors.surface.withAlpha(120),
                              borderColor: AppColors.textPrimary.withAlpha(30),
                              focusedBorderColor: AppColors.brandRed,
                              height: AppSpacing.buttonHeight,
                              radius: AppRadius.lg,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return l10n.registerPasswordRequired;
                                }
                                if (value.length < 6) {
                                  return l10n.registerPasswordMin;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            AppTextField(
                              hint: l10n.registerConfirmPasswordLabel,
                              controller: _confirmPasswordController,
                              obscureText: true,
                              prefixIconAsset: 'assets/icons/eye_off.svg',
                              fillColor: AppColors.surface.withAlpha(120),
                              borderColor: AppColors.textPrimary.withAlpha(30),
                              focusedBorderColor: AppColors.brandRed,
                              height: AppSpacing.buttonHeight,
                              radius: AppRadius.lg,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return l10n.registerConfirmPasswordRequired;
                                }
                                if (value != _passwordController.text) {
                                  return l10n.registerPasswordMismatch;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            _buildTermsRow(l10n),
                            const SizedBox(height: AppSpacing.xl),
                            AppButton(
                              label: l10n.registerCta,
                              onPressed: isLoading ? null : _submit,
                              isLoading: isLoading,
                              variant: AppButtonVariant.primary,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            _buildSocialRow(),
                            const SizedBox(height: AppSpacing.lg),
                            GestureDetector(
                              onTap: () => context.goNamed(AppRouteNames.login),
                              child: Text.rich(
                                TextSpan(
                                  style: AppTypography.body.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: '${l10n.authAlreadyHaveAccount} ',
                                    ),
                                    TextSpan(
                                      text: l10n.authActionLogin,
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
