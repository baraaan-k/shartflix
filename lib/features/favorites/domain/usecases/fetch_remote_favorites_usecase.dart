import '../entities/favorite_movie.dart';
import '../repositories/favorites_repository.dart';

class FetchRemoteFavoritesUseCase {
  FetchRemoteFavoritesUseCase(this._repository);

  final FavoritesRepository _repository;

  Future<List<FavoriteMovie>> call() {
    return _repository.fetchRemoteFavorites();
  }
}
