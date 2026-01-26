import '../../domain/entities/movie.dart';

enum HomeStatus {
  initial,
  loading,
  success,
  empty,
  error,
}

class HomeState {
  const HomeState({
    this.status = HomeStatus.initial,
    this.movies = const [],
    this.hasMore = true,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  final HomeStatus status;
  final List<Movie> movies;
  final bool hasMore;
  final bool isLoadingMore;
  final String? errorMessage;

  HomeState copyWith({
    HomeStatus? status,
    List<Movie>? movies,
    bool? hasMore,
    bool? isLoadingMore,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      movies: movies ?? this.movies,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage,
    );
  }
}
