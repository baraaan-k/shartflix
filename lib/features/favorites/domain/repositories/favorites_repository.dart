import '../entities/favorite_movie.dart';

abstract class FavoritesRepository {
  Future<List<FavoriteMovie>> getFavorites();

  Future<void> saveFavorites(List<FavoriteMovie> favorites);
}
