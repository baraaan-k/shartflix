import '../../domain/entities/favorite_movie.dart';

class FavoritesState {
  const FavoritesState({
    this.favorites = const [],
    this.favoriteIds = const {},
    this.isLoading = false,
    this.errorMessage,
  });

  final List<FavoriteMovie> favorites;
  final Set<int> favoriteIds;
  final bool isLoading;
  final String? errorMessage;

  FavoritesState copyWith({
    List<FavoriteMovie>? favorites,
    Set<int>? favoriteIds,
    bool? isLoading,
    String? errorMessage,
  }) {
    return FavoritesState(
      favorites: favorites ?? this.favorites,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}
