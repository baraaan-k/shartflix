import '../entities/favorite_movie.dart';
import '../repositories/favorites_repository.dart';

class SaveFavoritesUseCase {
  SaveFavoritesUseCase(this._repository);

  final FavoritesRepository _repository;

  Future<void> call(List<FavoriteMovie> favorites) {
    return _repository.saveFavorites(favorites);
  }
}
