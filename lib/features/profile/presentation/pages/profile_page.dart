import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/localization/app_locale_controller.dart';
import '../../../../app/router/app_router.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme_controller.dart';
import '../../../../features/auth/domain/usecases/logout_usecase.dart';
import '../../../../core/navigation/navigation_service.dart';
import '../../../../features/favorites/presentation/bloc/favorites_cubit.dart';
import '../../../../features/favorites/presentation/bloc/favorites_state.dart';
import '../../../../features/home/domain/entities/movie.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_radius.dart';
import '../../../../theme/app_shadows.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_typography.dart';
import '../../../../ui/components/app_button.dart';
import '../../../../ui/primitives/app_card.dart';
import '../../../../ui/primitives/app_icon.dart';
import '../../../../ui/primitives/app_text.dart';
import '../../../../screens/movie_detail_sheet.dart';
import '../../../../screens/limited_offer_modal.dart';
import '../../../../features/offer/data/offer_flag_store.dart';
import '../bloc/profile_cubit.dart';
import '../bloc/profile_state.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class ProfilePhotoUploadPage extends StatefulWidget {
  const ProfilePhotoUploadPage({super.key});

  @override
  State<ProfilePhotoUploadPage> createState() =>
      _ProfilePhotoUploadPageState();
}

class _ProfilePhotoUploadPageState extends State<ProfilePhotoUploadPage> {
  late final ProfileCubit _profileCubit;
  StreamSubscription<ProfileState>? _profileSubscription;
  File? _selectedFile;
  String? _lastProfileError;

  @override
  void initState() {
    super.initState();
    _profileCubit = ServiceLocator.instance.get<ProfileCubit>();
    _profileSubscription = _profileCubit.stream.listen(_handleProfileState);
    _profileCubit.load();
  }

  @override
  void dispose() {
    _profileSubscription?.cancel();
    super.dispose();
  }

  void _handleProfileState(ProfileState state) {
    if (!mounted) return;
    if (state.errorMessage != null && state.errorMessage != _lastProfileError) {
      _lastProfileError = state.errorMessage;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.commonError)),
      );
    }
  }

  Future<void> _pickPhoto() async {
    try {
      final picker = ImagePicker();
      final selected = await picker.pickImage(source: ImageSource.gallery);
      if (selected == null) return;
      setState(() => _selectedFile = File(selected.path));
    } catch (_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.profilePhotoPickError)),
      );
    }
  }

  void _clearPhoto() {
    setState(() => _selectedFile = null);
  }

  Future<void> _continue() async {
    final file = _selectedFile;
    if (file == null) return;
    await _profileCubit.setAvatar(file);
    if (!mounted) return;
    if (_profileCubit.state.errorMessage == null) {
      context.goNamed(AppRouteNames.shell);
    }
  }

  void _skip() {
    context.goNamed(AppRouteNames.shell);
  }

  Widget _buildTopBar(AppLocalizations l10n) {
    return SizedBox(
      height: AppSpacing.xxl + AppSpacing.lg,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                width: AppSpacing.xxl + AppSpacing.sm,
                height: AppSpacing.xxl + AppSpacing.sm,
                decoration: BoxDecoration(
                  color: AppColors.surface.withAlpha(140),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.textPrimary.withAlpha(30),
                  ),
                ),
                child: Center(
                  child: AppIcon(
                    'assets/icons/arrow.svg',
                    size: AppSpacing.iconLg,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
          AppText(
            l10n.profilePhotoDetailTitle,
            style: AppTextStyle.body,
            color: AppColors.textPrimary,
            align: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Column(
      children: [
        Container(
          width: AppSpacing.xxl + AppSpacing.lg,
          height: AppSpacing.xxl + AppSpacing.lg,
          decoration: BoxDecoration(
            color: AppColors.surface.withAlpha(120),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Center(
            child: AppIcon(
              'assets/icons/profile.svg',
              size: AppSpacing.iconLg + AppSpacing.sm,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppText(
          l10n.profilePhotoHeaderTitle,
          style: AppTextStyle.h4,
        ),
        
        const SizedBox(height: AppSpacing.xs),
        AppText(
          l10n.profilePhotoHeaderSubtitle,
          style: AppTextStyle.caption,
          color: AppColors.textSecondary,
          align: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmptyUploadBox() {
    return GestureDetector(
      onTap: _pickPhoto,
      child: SizedBox(
        width: 160,
        height: 160,
        child: CustomPaint(
          painter: _DashedRRectPainter(
            color: AppColors.textPrimary.withAlpha(40),
            radius: AppRadius.lg,
          ),
          child: Center(
            child: AppIcon(
              'assets/icons/plus.svg',
              size: AppSpacing.iconLg + AppSpacing.sm,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedPreview(File file) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Image.file(
            file,
            width: 160,
            height: 160,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        GestureDetector(
          onTap: _clearPhoto,
          child: Container(
            width: AppSpacing.xl + AppSpacing.sm,
            height: AppSpacing.xl + AppSpacing.sm,
            decoration: BoxDecoration(
              color: AppColors.surface.withAlpha(160),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.textPrimary.withAlpha(30),
              ),
            ),
            child: Center(
              child: AppIcon(
                'assets/icons/x.svg',
                size: AppSpacing.iconMd,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return StreamBuilder<ProfileState>(
      initialData: _profileCubit.state,
      stream: _profileCubit.stream,
      builder: (context, snapshot) {
        final state = snapshot.data ?? const ProfileState();
        final isBusy = state.isUpdatingAvatar;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              Positioned.fill(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(color: AppColors.bg),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: const Alignment(0.0, -0.90),
                            radius: 1.35,
                            colors: [
                              AppColors.brandRed2.withValues(alpha: 0.55),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.lg,
                  ),
                  child: Column(
                    children: [
                      _buildTopBar(l10n),
                      const SizedBox(height: AppSpacing.xl),
                      _buildHeader(l10n),
                      const SizedBox(height: AppSpacing.xl),
                      _selectedFile == null
                          ? _buildEmptyUploadBox()
                          : _buildSelectedPreview(_selectedFile!),
                      const Spacer(),
                      AppButton(
                        label: l10n.profilePhotoPrimaryCta,
                        onPressed: (_selectedFile == null || isBusy)
                            ? null
                            : _continue,
                        isLoading: isBusy,
                        isDisabled: _selectedFile == null,
                        variant: AppButtonVariant.primary,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      GestureDetector(
                        onTap: _skip,
                        child: AppText(
                          l10n.profilePhotoSkip,
                          style: AppTextStyle.body,
                          color: AppColors.textSecondary,
                          align: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  _DashedRRectPainter({
    required this.color,
    required this.radius,
  });

  final Color color;
  final double radius;
  final double _dashLength = 6;
  final double _gapLength = 6;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final segment = metric.extractPath(
          distance,
          distance + _dashLength,
        );
        canvas.drawPath(segment, paint);
        distance += _dashLength + _gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.radius != radius;
  }
}

class _SettingsOption extends StatelessWidget {
  const _SettingsOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.brandRed : AppColors.surface2,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: selected
                ? Colors.transparent
                : AppColors.textPrimary.withAlpha(30),
          ),
        ),
        child: Center(
          child: AppText(
            label,
            style: AppTextStyle.caption,
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _FavoriteGridCard extends StatelessWidget {
  const _FavoriteGridCard({
    required this.movie,
    required this.onTap,
  });

  final Movie movie;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: (movie.posterUrl?.isNotEmpty ?? false)
                  ? Image.network(
                      movie.posterUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    )
                  : Container(
                      color: AppColors.surface.withAlpha(120),
                      child: Center(
                        child: AppIcon(
                          'assets/images/upload.svg',
                          size: AppSpacing.iconLg,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppText(
            movie.title,
            style: AppTextStyle.body,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xs),
          AppText(
            movie.overview,
            style: AppTextStyle.caption,
            color: AppColors.textSecondary,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ProfilePageState extends State<ProfilePage> {
  late final FavoritesCubit _favoritesCubit;
  late final ProfileCubit _profileCubit;
  late final AppLocaleController _localeController;
  late final AppThemeController _themeController;

  StreamSubscription<FavoritesState>? _subscription;
  StreamSubscription<ProfileState>? _profileSubscription;

  String? _lastError;
  String? _lastProfileError;

  @override
  void initState() {
    super.initState();
    _favoritesCubit = ServiceLocator.instance.get<FavoritesCubit>();
    _profileCubit = ServiceLocator.instance.get<ProfileCubit>();
    _localeController = ServiceLocator.instance.get<AppLocaleController>();
    _themeController = ServiceLocator.instance.get<AppThemeController>();

    _subscription = _favoritesCubit.stream.listen(_handleFavoritesState);
    _profileSubscription = _profileCubit.stream.listen(_handleProfileState);

    _profileCubit.load();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _profileSubscription?.cancel();
    super.dispose();
  }

  void _handleFavoritesState(FavoritesState state) {
    if (!mounted) return;
    if (state.errorMessage != null && state.errorMessage != _lastError) {
      _lastError = state.errorMessage;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.commonError)),
      );
    }
  }

  void _handleProfileState(ProfileState state) {
    if (!mounted) return;
    if (state.errorMessage != null && state.errorMessage != _lastProfileError) {
      _lastProfileError = state.errorMessage;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.commonError)),
      );
    }
  }

  Future<void> _pickAvatar() async {
    try {
      final picker = ImagePicker();
      final selected = await picker.pickImage(source: ImageSource.gallery);
      if (selected == null) return;
      await _profileCubit.setAvatar(File(selected.path));
    } catch (_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.profilePhotoPickError)),
      );
    }
  }

  String _buildUserId(String seed) {
    if (seed.isEmpty) return '000000';
    final value = seed.hashCode.abs() % 1000000;
    return value.toString().padLeft(6, '0');
  }

  Future<void> _logout(BuildContext sheetContext) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await ServiceLocator.instance.get<LogoutUseCase>()();
      if (!mounted) return;
      Navigator.of(sheetContext).pop();
      ServiceLocator.instance.get<NavigationService>().goToLogin();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.commonError)),
      );
    }
  }

  Future<void> _showSettingsSheet() async {
    final themeController = ServiceLocator.instance.get<AppThemeController>();
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        final localeCode = _localeController.locale.value?.languageCode;
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: themeController.themeMode,
          builder: (context, mode, _) {
            return ValueListenableBuilder<Locale?>(
              valueListenable: _localeController.locale,
              builder: (context, locale, __) {
                final l10n = AppLocalizations.of(sheetContext)!;
                final currentCode = locale?.languageCode ?? localeCode;
                return Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.xl,
                  ),
                  child: AppCard(
                    radius: AppRadius.lg,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    backgroundColor: AppColors.surface.withAlpha(230),
                    borderColor: AppColors.textPrimary.withAlpha(20),
                    shadows: AppShadows.softCard,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            AppText(l10n.settingsTitle, style: AppTextStyle.h4),
                            const Spacer(),
                            GestureDetector(
                              onTap: () => Navigator.of(sheetContext).pop(),
                              child: Container(
                                width: AppSpacing.xl + AppSpacing.sm,
                                height: AppSpacing.xl + AppSpacing.sm,
                                decoration: BoxDecoration(
                                  color: AppColors.surface2.withAlpha(160),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.textPrimary.withAlpha(30),
                                  ),
                                ),
                                child: Center(
                                  child: AppIcon(
                                    'assets/icons/x.svg',
                                    size: AppSpacing.iconMd,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppText(l10n.settingsTheme, style: AppTextStyle.caption),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            Expanded(
                              child: _SettingsOption(
                                label: l10n.settingsDark,
                                selected: mode == ThemeMode.dark,
                                onTap: () =>
                                    themeController.setThemeMode(ThemeMode.dark),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: _SettingsOption(
                                label: l10n.settingsLight,
                                selected: mode == ThemeMode.light,
                                onTap: () =>
                                    themeController.setThemeMode(ThemeMode.light),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppText(
                          l10n.settingsLanguage,
                          style: AppTextStyle.caption,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            Expanded(
                              child: _SettingsOption(
                                label: l10n.profileLanguageTurkish,
                                selected: currentCode == 'tr',
                                onTap: () =>
                                    _localeController.setLocale(const Locale('tr')),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: _SettingsOption(
                                label: l10n.profileLanguageEnglish,
                                selected: currentCode == 'en',
                                onTap: () =>
                                    _localeController.setLocale(const Locale('en')),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppButton(
                          label: l10n.settingsLogout,
                          variant: AppButtonVariant.secondary,
                          onPressed: () => _logout(sheetContext),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeController.themeMode,
      builder: (context, _, __) {
        return StreamBuilder<ProfileState>(
          initialData: _profileCubit.state,
          stream: _profileCubit.stream,
          builder: (context, profileSnapshot) {
            final profileState = profileSnapshot.data ?? const ProfileState();
            final user = profileState.user;

            final hasName = user?.name?.trim().isNotEmpty ?? false;
            final hasEmail = user?.email.trim().isNotEmpty ?? false;

            final displayName = hasName
                ? user!.name!
                : hasEmail
                    ? user!.email.split('@').first
                    : l10n.profileGuest;

            final email = user?.email ?? '';
            final avatarPath = user?.avatarPath;
            final photoUrl = user?.photoUrl;
            const tabBarHeight = 72.0;
            final scrollBottomPadding = tabBarHeight + AppSpacing.tabHeight;

            return StreamBuilder<FavoritesState>(
              initialData: _favoritesCubit.state,
              stream: _favoritesCubit.stream,
              builder: (context, snapshot) {
                final favState = snapshot.data ?? const FavoritesState();

                return Scaffold(
                  backgroundColor: Colors.transparent,
                  extendBodyBehindAppBar: true,
                  body: Stack(
                    fit: StackFit.expand,
                    children: [
                      Stack(
                        fit: StackFit.expand,
                        children: [
                          Container(color: AppColors.bg),
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: RadialGradient(
                                  center: const Alignment(0.0, -0.90),
                                  radius: 1.35,
                                  colors: [
                                    AppColors.brandRed2.withValues(alpha: 0.55),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SafeArea(
                        bottom: false,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.lg,
                                AppSpacing.lg,
                                AppSpacing.lg,
                                0,
                              ),
                              child: Row(
                                children: [
                                  AppText(
                                    l10n.profileTitle,
                                    style: AppTextStyle.h4,
                                  ),
                                  const Spacer(),
                                  GestureDetector(
                                    onTap: () async {
                                      await openLimitedOffer(context);
                                      await ServiceLocator.instance
                                          .get<OfferFlagStore>()
                                          .markOfferShown();
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.lg,
                                        vertical: AppSpacing.sm,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.brandRed,
                                        borderRadius:
                                            BorderRadius.circular(AppRadius.pill),
                                        boxShadow: AppShadows.redGlow,
                                      ),
                                      child: Row(
                                        children: [
                                          AppIcon(
                                            'assets/icons/gem.svg',
                                            size: AppSpacing.iconMd,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: AppSpacing.sm),
                                          Text(
                                            l10n.limitedOfferTitle,
                                            style: AppTypography.bodyN(
                                              FontWeight.w600,
                                            ).copyWith(color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  GestureDetector(
                                    onTap: _showSettingsSheet,
                                    child: Container(
                                      width: AppSpacing.xl + AppSpacing.md,
                                      height: AppSpacing.xl + AppSpacing.md,
                                      decoration: BoxDecoration(
                                        color: AppColors.surface.withAlpha(160),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.textPrimary.withAlpha(30),
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.settings,
                                        size: 18,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.lg,
                                AppSpacing.lg,
                                AppSpacing.lg,
                                AppSpacing.md,
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.pill),
                                    child: SizedBox(
                                      width: 64,
                                      height: 64,
                                      child: (photoUrl?.isNotEmpty ?? false)
                                          ? Image.network(
                                              photoUrl!,
                                              fit: BoxFit.cover,
                                            )
                                          : (avatarPath?.isNotEmpty ?? false)
                                              ? Image.file(
                                                  File(avatarPath!),
                                                  fit: BoxFit.cover,
                                                )
                                              : Container(
                                                  color:
                                                      AppColors.surface.withAlpha(120),
                                                  child: Center(
                                                    child: AppIcon(
                                                      'assets/icons/profile.svg',
                                                      size: AppSpacing.iconLg,
                                                      color: AppColors.textPrimary,
                                                    ),
                                                  ),
                                                ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.lg),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        AppText(
                                          displayName,
                                          style: AppTextStyle.h4,
                                        ),
                                        const SizedBox(height: AppSpacing.xs),
                                        AppText(
                                          '${l10n.profileIdLabel}: ${_buildUserId(email)}',
                                          style: AppTextStyle.body,
                                          color: AppColors.textSecondary,
                                        ),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: profileState.isUpdatingAvatar
                                        ? null
                                        : _pickAvatar,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.lg,
                                        vertical: AppSpacing.sm,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.brandRed2.withAlpha(20),
                                        borderRadius:
                                            BorderRadius.circular(AppRadius.md),
                                        border: Border.all(
                                          color: AppColors.textPrimary.withAlpha(10),
                                        ),
                                      ),
                                      child: Text(
                                        l10n.profileChangePhoto,
                                        style: AppTypography.bodyN(
                                          FontWeight.w600,
                                        ).copyWith(
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.lg,
                                vertical: AppSpacing.md,
                              ),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: AppText(
                                  l10n.profileFavoritesTitle,
                                  style: AppTextStyle.button,
                                ),
                              ),
                            ),
                            Expanded(
                              child: favState.favorites.isEmpty
                                  ? const _EmptyFavoritesPadded()
                                  : GridView.builder(
                                      padding: EdgeInsets.fromLTRB(
                                        AppSpacing.lg,
                                        0,
                                        AppSpacing.lg,
                                        scrollBottomPadding,
                                      ),
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: AppSpacing.lg,
                                        mainAxisSpacing: AppSpacing.lg,
                                        childAspectRatio: 0.62,
                                      ),
                                      itemCount: favState.favorites.length,
                                      itemBuilder: (context, index) {
                                        final movie = favState.favorites[index];
                                        return _FavoriteGridCard(
                                          movie: Movie(
                                            id: movie.id,
                                            title: movie.title,
                                            overview: movie.overview,
                                            posterUrl: movie.posterUrl,
                                            images: movie.images,
                                          ),
                                          onTap: () => showMovieDetailSheet(
                                            context,
                                            Movie(
                                              id: movie.id,
                                              title: movie.title,
                                              overview: movie.overview,
                                              posterUrl: movie.posterUrl,
                                              images: movie.images,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _EmptyFavoritesPadded extends StatelessWidget {
  const _EmptyFavoritesPadded();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      child: AppText(
        l10n.profileNoFavorites,
        style: AppTextStyle.body,
        color: AppColors.textSecondary,
        align: TextAlign.center,
      ),
    );
  }
}
