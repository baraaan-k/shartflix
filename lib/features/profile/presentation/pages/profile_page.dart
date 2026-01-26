import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/localization/app_locale_controller.dart';
import '../../../../features/auth/domain/usecases/logout_usecase.dart';
import '../../../../features/favorites/domain/entities/favorite_movie.dart';
import '../../../../features/favorites/presentation/bloc/favorites_cubit.dart';
import '../../../../features/favorites/presentation/bloc/favorites_state.dart';
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
    _subscription = _favoritesCubit.stream.listen(_handleState);
    _profileSubscription = _profileCubit.stream.listen(_handleProfileState);
    _profileCubit.load();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _profileSubscription?.cancel();
    super.dispose();
  }

  void _handleState(FavoritesState state) {
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
        final selectedLocale =
            _localeController.locale.value ?? Localizations.localeOf(context);
        final dropdownLocale = selectedLocale.languageCode == 'tr'
            ? const Locale('tr')
            : const Locale('en');

        return StreamBuilder<FavoritesState>(
          initialData: _favoritesCubit.state,
          stream: _favoritesCubit.stream,
          builder: (context, snapshot) {
            final state = snapshot.data ?? const FavoritesState();
            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      key: ValueKey(profileState.avatarRevision),
                      radius: 36,
                      backgroundImage: avatarPath != null
                          ? FileImage(File(avatarPath))
                          : null,
                      child: avatarPath == null
                          ? const Icon(Icons.person_outline, size: 36)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          if (hasEmail)
                            Text(
                              email,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: profileState.isUpdatingAvatar
                                ? null
                                : _pickAvatar,
                            child: profileState.isUpdatingAvatar
                                ? const SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(l10n.profileChangePhoto),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      l10n.profileLanguage,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(width: 12),
                    DropdownButton<Locale>(
                      value: dropdownLocale,
                      onChanged: (locale) {
                        _localeController.setLocale(locale);
                      },
                      items: [
                        DropdownMenuItem(
                          value: const Locale('en'),
                          child: Text(l10n.profileLanguageEnglish),
                        ),
                        DropdownMenuItem(
                          value: const Locale('tr'),
                          child: Text(l10n.profileLanguageTurkish),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.profileFavoritesTitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                if (state.favorites.isEmpty)
                  _EmptyFavorites(message: l10n.profileNoFavorites)
                else
                  ...state.favorites.map(
                    (movie) => _FavoriteTile(
                      movie: movie,
                      onToggle: () => _favoritesCubit.toggleFavorite(movie),
                    ),
                  ),
                const SizedBox(height: 24),
                OutlinedButton(
                  onPressed: () async {
                    final logout = ServiceLocator.instance.get<LogoutUseCase>();
                    await logout();
                    if (!context.mounted) return;
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      AppRoutes.login,
                      (route) => false,
                    );
                  },
                  child: Text(l10n.profileLogout),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(message),
      ),
    );
  }
}

class _FavoriteTile extends StatelessWidget {
  const _FavoriteTile({
    required this.movie,
    required this.onToggle,
  });

  final FavoriteMovie movie;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(movie.title),
        subtitle: Text(movie.overview),
        trailing: IconButton(
          onPressed: onToggle,
          icon: const Icon(
            Icons.favorite,
            color: Colors.redAccent,
          ),
        ),
      ),
    );
  }
}
