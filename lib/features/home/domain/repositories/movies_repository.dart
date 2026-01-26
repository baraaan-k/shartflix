import '../entities/movie.dart';

class MoviesPage {
  const MoviesPage({
    required this.movies,
    required this.hasMore,
  });

  final List<Movie> movies;
  final bool hasMore;
}

abstract class MoviesRepository {
  Future<MoviesPage> fetchMovies({
    required int page,
    required int pageSize,
  });
}
