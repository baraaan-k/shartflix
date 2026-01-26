import '../../domain/entities/favorite_movie.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../datasources/favorites_local_data_source.dart';
import '../models/favorite_movie_model.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  FavoritesRepositoryImpl(this._localDataSource);

  final FavoritesLocalDataSource _localDataSource;

  @override
  Future<List<FavoriteMovie>> getFavorites() async {
    final models = await _localDataSource.readFavorites();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> saveFavorites(List<FavoriteMovie> favorites) async {
    final models =
        favorites.map(FavoriteMovieModel.fromEntity).toList(growable: false);
    await _localDataSource.writeFavorites(models);
  }
}
