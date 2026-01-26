import '../models/movie_model.dart';

class MoviesResponse {
  MoviesResponse({
    required this.items,
    required this.total,
  });

  final List<MovieModel> items;
  final int total;
}

abstract class MoviesRemoteDataSource {
  Future<MoviesResponse> fetchMovies({
    required int page,
    required int pageSize,
  });
}

class FakeMoviesRemoteDataSource implements MoviesRemoteDataSource {
  FakeMoviesRemoteDataSource() : _catalog = _buildCatalog();

  final List<MovieModel> _catalog;

  @override
  Future<MoviesResponse> fetchMovies({
    required int page,
    required int pageSize,
  }) async {
    if (page < 1 || pageSize < 1) {
      throw Exception('Invalid pagination request');
    }
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final start = (page - 1) * pageSize;
    if (start >= _catalog.length) {
      return MoviesResponse(items: const [], total: _catalog.length);
    }
    final end = (start + pageSize).clamp(0, _catalog.length);
    return MoviesResponse(
      items: _catalog.sublist(start, end),
      total: _catalog.length,
    );
  }

  static List<MovieModel> _buildCatalog() {
    return List.generate(
      30,
      (index) => MovieModel(
        id: index + 1,
        title: 'Movie ${index + 1}',
        overview: 'An unforgettable story number ${index + 1}.',
      ),
    );
  }
}
