import '../entities/favorite_movie.dart';
import '../repositories/favorites_repository.dart';

class ToggleFavoriteUseCase {
  ToggleFavoriteUseCase(this._repository);

  final FavoritesRepository _repository;

  Future<List<FavoriteMovie>> call({
    required List<FavoriteMovie> current,
    required FavoriteMovie movie,
  }) async {
    final updated = List<FavoriteMovie>.from(current);
    final index = updated.indexWhere((item) => item.id == movie.id);
    if (index >= 0) {
      updated.removeAt(index);
    } else {
      updated.add(movie);
    }
    await _repository.saveFavorites(updated);
    return updated;
  }
}
