import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/router/app_router.dart';
import '../../../../features/auth/domain/usecases/logout_usecase.dart';
import '../../../../features/favorites/domain/entities/favorite_movie.dart';
import '../../../../features/favorites/presentation/bloc/favorites_cubit.dart';
import '../../../../features/favorites/presentation/bloc/favorites_state.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final FavoritesCubit _favoritesCubit;
  StreamSubscription<FavoritesState>? _subscription;
  String? _lastError;

  @override
  void initState() {
    super.initState();
    _favoritesCubit = ServiceLocator.instance.get<FavoritesCubit>();
    _subscription = _favoritesCubit.stream.listen(_handleState);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _handleState(FavoritesState state) {
    if (!mounted) return;
    if (state.errorMessage != null && state.errorMessage != _lastError) {
      _lastError = state.errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.errorMessage!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FavoritesState>(
      initialData: _favoritesCubit.state,
      stream: _favoritesCubit.stream,
      builder: (context, snapshot) {
        final state = snapshot.data ?? const FavoritesState();
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          children: [
            Text(
              'Profile',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Your favorite movies',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            if (state.favorites.isEmpty)
              const _EmptyFavorites()
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
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Text('No favorites yet.'),
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
