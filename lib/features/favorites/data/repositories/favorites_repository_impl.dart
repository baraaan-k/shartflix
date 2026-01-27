import '../../domain/entities/favorite_movie.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../datasources/favorites_local_data_source.dart';
import '../../../home/data/datasources/movies_remote_data_source.dart';
import '../models/favorite_movie_model.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  FavoritesRepositoryImpl(
    this._localDataSource,
    this._remoteDataSource,
  );

  final FavoritesLocalDataSource _localDataSource;
  final MoviesRemoteDataSource _remoteDataSource;

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

  @override
  Future<List<FavoriteMovie>> fetchRemoteFavorites() async {
    final movies = await _remoteDataSource.fetchFavorites();
    return movies
        .map(
          (movie) => FavoriteMovie(
            id: movie.id,
            title: movie.title,
            overview: movie.overview,
            posterUrl: movie.posterUrl,
          ),
        )
        .toList();
  }

  @override
  Future<void> toggleFavorite(String favoriteId) async {
    await _remoteDataSource.toggleFavorite(favoriteId);
  }
}
