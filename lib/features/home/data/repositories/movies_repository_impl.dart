import '../../domain/repositories/movies_repository.dart';
import '../datasources/movies_remote_data_source.dart';

class MoviesRepositoryImpl implements MoviesRepository {
  MoviesRepositoryImpl(this._remoteDataSource);

  final MoviesRemoteDataSource _remoteDataSource;

  @override
  Future<MoviesPage> fetchMovies({
    required int page,
    required int pageSize,
  }) async {
    final response = await _remoteDataSource.fetchMovies(
      page: page,
    );
    final movies = response.items.map((item) => item.toEntity()).toList();
    final hasMore = response.totalPages != null && response.currentPage != null
        ? response.currentPage! < response.totalPages!
        : movies.isNotEmpty;
    return MoviesPage(movies: movies, hasMore: hasMore);
  }
}
