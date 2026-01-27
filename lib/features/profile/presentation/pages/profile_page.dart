import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/localization/app_locale_controller.dart';
import '../../../../core/router/app_router.dart';
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
import '../../../../ui/primitives/app_text.dart';
import '../../../../screens/movie_detail_sheet.dart';
import '../bloc/profile_cubit.dart';
import '../bloc/profile_state.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final FavoritesCubit _favoritesCubit;
  late final ProfileCubit _profileCubit;
  late final AppLocaleController _localeController;

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
                                            Navigator.of(context)
                                                .pushNamedAndRemoveUntil(
                                              AppRoutes.login,
                                              (route) => false,
                                            );
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
                        onFavoriteTap: () => _favoritesCubit.toggleFavorite(
                          FavoriteMovie(
                            id: movie.id,
                            title: movie.title,
                            overview: movie.overview,
                            posterUrl: movie.posterUrl,
                            images: movie.images,
                          ),
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
                      ),
                    ),

                  const SizedBox(height: AppSpacing.xl),

                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: AppText(
                      l10n.profileBonusTitle,
                      style: AppTextStyle.h2,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppButton(
                          label: l10n.profileBonusAnalytics,
                          onPressed: () async {
                            await FirebaseAnalytics.instance.logEvent(
                              name: 'bonus_test',
                            );
                          },
                          variant: AppButtonVariant.secondary,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        AppButton(
                          label: l10n.profileBonusCrashLog,
                          onPressed: () {
                            FirebaseCrashlytics.instance
                                .log('bonus_test_log');
                          },
                          variant: AppButtonVariant.secondary,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        AppButton(
                          label: l10n.profileBonusCrash,
                          onPressed: () {
                            FirebaseCrashlytics.instance.crash();
                          },
                          variant: AppButtonVariant.secondary,
                        ),
                      ],
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
                        colorFilter: const ColorFilter.mode(
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
                        child: const Icon(
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
