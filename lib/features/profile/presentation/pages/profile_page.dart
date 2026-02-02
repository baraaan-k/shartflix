import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/localization/app_locale_controller.dart';
import '../../../../app/router/app_router.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme_controller.dart';
import '../../../../features/auth/domain/usecases/logout_usecase.dart';
import '../../../../features/favorites/domain/entities/favorite_movie.dart';
import '../../../../features/favorites/presentation/bloc/favorites_cubit.dart';
import '../../../../features/favorites/presentation/bloc/favorites_state.dart';
import '../../../../features/home/domain/entities/movie.dart';
import '../../../../features/home/presentation/widgets/vertical_movie_card.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_radius.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../ui/components/app_button.dart';
import '../../../../ui/primitives/app_card.dart';
import '../../../../ui/primitives/app_icon.dart';
import '../../../../ui/primitives/app_text.dart';
import '../../../../ui/like_burst_overlay.dart';
import '../../../../screens/movie_detail_sheet.dart';
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
          style: AppTextStyle.h2,
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
          body: Container(
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
            child: SafeArea(
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
    this.dashLength = 6,
    this.gapLength = 6,
  });

  final Color color;
  final double radius;
  final double dashLength;
  final double gapLength;

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
          distance + dashLength,
        );
        canvas.drawPath(segment, paint);
        distance += dashLength + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.radius != radius ||
        oldDelegate.dashLength != dashLength ||
        oldDelegate.gapLength != gapLength;
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

  void _removeAvatar() {
    _profileCubit.clearAvatar();
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

            final hasImage = (photoUrl != null && photoUrl.isNotEmpty) ||
                (avatarPath != null && avatarPath.isNotEmpty);

            return StreamBuilder<FavoritesState>(
              initialData: _favoritesCubit.state,
              stream: _favoritesCubit.stream,
              builder: (context, snapshot) {
                final favState = snapshot.data ?? const FavoritesState();

                return Scaffold(
                  backgroundColor: AppColors.bg,
                  appBar: AppBar(
                    leading: ValueListenableBuilder<ThemeMode>(
                      valueListenable: _themeController.themeMode,
                  builder: (context, mode, _) {
                    final isDark = mode == ThemeMode.dark;
                    return IconButton(
                      onPressed: _themeController.toggle,
                      icon: Icon(
                        isDark
                            ? Icons.light_mode_outlined
                            : Icons.dark_mode_outlined,
                      ),
                      color: AppColors.textSecondary,
                    );
                  },
                ),
                title: AppText(l10n.profileTitle, style: AppTextStyle.h2),
                actions: [
                  IconButton(
                    onPressed: () => _showLanguagePicker(context),
                    icon: const Icon(Icons.flag_outlined),
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              body: ListView(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final boxSize = (constraints.maxWidth * 0.42)
                                .clamp(160, 200)
                                .toDouble();

                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: profileState.isUpdatingAvatar
                                      ? null
                                      : _pickAvatar,
                                  child: _AvatarBox(
                                    size: boxSize,
                                    hasImage: hasImage,
                                    isBusy: profileState.isUpdatingAvatar,
                                    photoUrl: photoUrl,
                                    avatarPath: avatarPath,
                                    onRemove: _removeAvatar,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.lg),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                      AppText(displayName, style: AppTextStyle.h1),
                                      if (hasEmail) ...[
                                        const SizedBox(height: AppSpacing.xs),
                                        AppText(
                                          email,
                                          style: AppTextStyle.caption,
                                          color: AppColors.textSecondary,
                                        ),
                                      ],
                                      const SizedBox(height: AppSpacing.md),
                                      AppCard(
                                        borderColor: AppColors.brandRed,
                                        backgroundColor: Colors.transparent,
                                        shadows: const [],
                                        radius: AppRadius.pill,
                                        padding: EdgeInsets.zero,
                                        child: AppButton(
                                          label: l10n.profileLogout,
                                          onPressed: () async {
                                            final logout =
                                                ServiceLocator.instance
                                                    .get<LogoutUseCase>();
                                            await logout();
                                            if (!context.mounted) return;
                                            context.goNamed(AppRouteNames.login);
                                          },
                                          variant: AppButtonVariant.ghost,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: AppText(
                      l10n.profileFavoritesTitle,
                      style: AppTextStyle.h2,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  if (favState.favorites.isEmpty)
                    const _EmptyFavoritesPadded()
                  else
                    ...favState.favorites.map(
                      (movie) => VerticalMovieCard(
                        movie: Movie(
                          id: movie.id,
                          title: movie.title,
                          overview: movie.overview,
                          posterUrl: movie.posterUrl,
                          images: movie.images,
                        ),
                        isFavorite: true,
                        onFavoriteTap: () {
                          LikeBurstOverlay.maybeOf(context)?.play();
                          _favoritesCubit.toggleFavorite(
                            FavoriteMovie(
                              id: movie.id,
                              title: movie.title,
                              overview: movie.overview,
                              posterUrl: movie.posterUrl,
                              images: movie.images,
                            ),
                          );
                        },
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
                      ),
                    ),

                  const SizedBox(height: AppSpacing.lg),
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

class _AvatarBox extends StatelessWidget {
  const _AvatarBox({
    required this.size,
    required this.hasImage,
    required this.isBusy,
    required this.photoUrl,
    required this.avatarPath,
    required this.onRemove,
  });

  final double size;
  final bool hasImage;
  final bool isBusy;
  final String? photoUrl;
  final String? avatarPath;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      radius: AppRadius.lg,
      padding: EdgeInsets.zero,
       borderColor: Colors.transparent, 
  backgroundColor: Colors.transparent,  
  shadows: const [],             
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: SizedBox(
          width: size,
          height: size, 
          child: Stack(
            children: [
              Positioned.fill(
                child: hasImage
                    ? (photoUrl != null && photoUrl!.isNotEmpty)
                        ? Image.network(
                            photoUrl!,
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                          )
                        : Image.file(
                            File(avatarPath!),
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                          )
                    : SvgPicture.asset(
                        'assets/images/upload.svg',
                        fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        AppColors.textSecondary,
                        BlendMode.srcIn,
                      ),
                      ),
              ),

              if (hasImage)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 10,
                  child: Center(
                    child: GestureDetector(
                      onTap: isBusy ? null : onRemove,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.surface2,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.borderSoft),
                        ),
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
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

extension on _ProfilePageState {
  Future<void> _showLanguagePicker(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withAlpha(166),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(AppSpacing.lg),
          child: AppCard(
            radius: AppRadius.lg,
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    AppText(l10n.profileLanguage, style: AppTextStyle.h2),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      icon: const Icon(Icons.close),
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  label: l10n.profileLanguageEnglish,
                  onPressed: () {
                    _localeController.setLocale(const Locale('en'));
                    Navigator.of(dialogContext).pop();
                  },
                  variant: AppButtonVariant.secondary,
                ),
                const SizedBox(height: AppSpacing.sm),
                AppButton(
                  label: l10n.profileLanguageTurkish,
                  onPressed: () {
                    _localeController.setLocale(const Locale('tr'));
                    Navigator.of(dialogContext).pop();
                  },
                  variant: AppButtonVariant.secondary,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
