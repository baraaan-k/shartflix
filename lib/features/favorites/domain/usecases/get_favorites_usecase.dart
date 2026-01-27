import '../entities/favorite_movie.dart';
import '../repositories/favorites_repository.dart';

class GetFavoritesUseCase {
  GetFavoritesUseCase(this._repository);

  final FavoritesRepository _repository;

  Future<List<FavoriteMovie>> call() {
    return _repository.getFavorites();
  }
}
