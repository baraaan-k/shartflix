import '../../../../core/network/api_client.dart';
import '../models/movie_model.dart';

class MoviesResponse {
  MoviesResponse({
    required this.items,
    required this.totalPages,
    required this.currentPage,
  });

  final List<MovieModel> items;
  final int? totalPages;
  final int? currentPage;
}

abstract class MoviesRemoteDataSource {
  Future<MoviesResponse> fetchMovies({
    required int page,
  });

  Future<List<MovieModel>> fetchFavorites();

  Future<String> toggleFavorite(String favoriteId);
}

class MoviesRemoteDataSourceImpl implements MoviesRemoteDataSource {
  MoviesRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<MoviesResponse> fetchMovies({
    required int page,
  }) async {
    final response = await _apiClient.getJson('/movie/list?page=$page');
    final data = _extractData(response);
    final movies = _extractMovies(data);
    final totalPages = _readInt(data['totalPages']) ??
        _readInt(_readPaginationValue(data, 'maxPage'));
    final currentPage = _readInt(data['currentPage']) ??
        _readInt(_readPaginationValue(data, 'currentPage'));
    return MoviesResponse(
      items: movies,
      totalPages: totalPages,
      currentPage: currentPage,
    );
  }

  @override
  Future<List<MovieModel>> fetchFavorites() async {
    final response = await _apiClient.getJson('/movie/favorites');
    if (_isEnvelope(response)) {
      final data = response['data'];
      if (data is List) {
        return _extractMoviesFromList(data);
      }
    }
    final data = _extractData(response);
    return _extractMovies(data);
  }

  @override
  Future<String> toggleFavorite(String favoriteId) async {
    final response =
        await _apiClient.postJson('/movie/favorite/$favoriteId', {});
    final data = _extractData(response);
    final message = data['message'] ??
        response['message'] ??
        (response['response'] is Map ? response['response']['message'] : null);
    return message is String ? message : '';
  }

  Map<String, dynamic> _extractData(Map<String, dynamic> response) {
    if (_isEnvelope(response)) {
      final data = response['data'];
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
      return <String, dynamic>{};
    }
    return response;
  }

  List<MovieModel> _extractMovies(Map<String, dynamic> data) {
    final raw = data['movies'];
    if (raw is List) {
      return _extractMoviesFromList(raw);
    }
    return [];
  }

  List<MovieModel> _extractMoviesFromList(List raw) {
    return raw
        .whereType<Map>()
        .map((item) => MovieModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  int? _readInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  dynamic _readPaginationValue(Map<String, dynamic> data, String key) {
    final pagination = data['pagination'];
    if (pagination is Map) {
      return pagination[key];
    }
    return null;
  }

  bool _isEnvelope(Map<String, dynamic> json) {
    return json.containsKey('response') && json.containsKey('data');
  }
}
