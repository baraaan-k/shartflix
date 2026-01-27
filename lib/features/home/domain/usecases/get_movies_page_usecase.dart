import '../repositories/movies_repository.dart';

class GetMoviesPageUseCase {
  GetMoviesPageUseCase(this._repository);

  final MoviesRepository _repository;

  Future<MoviesPage> call({
    required int page,
    required int pageSize,
  }) {
    return _repository.fetchMovies(page: page, pageSize: pageSize);
  }
}
