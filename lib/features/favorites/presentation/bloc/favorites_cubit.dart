import 'dart:async';

import '../../domain/entities/favorite_movie.dart';
import '../../domain/usecases/get_favorites_usecase.dart';
import '../../domain/usecases/toggle_favorite_usecase.dart';
import 'favorites_state.dart';

class FavoritesCubit {
  FavoritesCubit({
    required GetFavoritesUseCase getFavoritesUseCase,
    required ToggleFavoriteUseCase toggleFavoriteUseCase,
  })  : _getFavoritesUseCase = getFavoritesUseCase,
        _toggleFavoriteUseCase = toggleFavoriteUseCase;

  final GetFavoritesUseCase _getFavoritesUseCase;
  final ToggleFavoriteUseCase _toggleFavoriteUseCase;

  final StreamController<FavoritesState> _controller =
      StreamController<FavoritesState>.broadcast();
  FavoritesState _state = const FavoritesState();
  bool _loaded = false;

  Stream<FavoritesState> get stream => _controller.stream;

  FavoritesState get state => _state;

  void _emit(FavoritesState state) {
    _state = state;
    _controller.add(state);
  }

  Future<void> load() async {
    if (_loaded || _state.isLoading) return;
    _emit(_state.copyWith(isLoading: true, errorMessage: null));
    try {
      final favorites = await _getFavoritesUseCase();
      final ids = favorites.map((movie) => movie.id).toSet();
      _loaded = true;
      _emit(
        _state.copyWith(
          favorites: favorites,
          favoriteIds: ids,
          isLoading: false,
        ),
      );
    } catch (error) {
      _emit(
        _state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load favorites.',
        ),
      );
    }
  }

  Future<void> toggleFavorite(FavoriteMovie movie) async {
    final current = List<FavoriteMovie>.from(_state.favorites);
    final updated = List<FavoriteMovie>.from(current);
    final exists = _state.favoriteIds.contains(movie.id);
    if (exists) {
      updated.removeWhere((item) => item.id == movie.id);
    } else {
      updated.add(movie);
    }
    final ids = updated.map((item) => item.id).toSet();
    _emit(
      _state.copyWith(
        favorites: updated,
        favoriteIds: ids,
        errorMessage: null,
      ),
    );
    try {
      await _toggleFavoriteUseCase(current: current, movie: movie);
    } catch (error) {
      _emit(
        _state.copyWith(
          errorMessage: 'Failed to update favorites.',
        ),
      );
    }
  }

  void close() {
    _controller.close();
  }
}
