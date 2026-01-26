import 'dart:async';

import '../../domain/usecases/get_movies_page_usecase.dart';
import 'home_state.dart';

class HomeCubit {
  HomeCubit(this._getMoviesPageUseCase);

  final GetMoviesPageUseCase _getMoviesPageUseCase;

  final StreamController<HomeState> _controller =
      StreamController<HomeState>.broadcast();
  HomeState _state = const HomeState();

  int _page = 1;
  static const int _pageSize = 5;
  bool _loading = false;

  Stream<HomeState> get stream => _controller.stream;

  HomeState get state => _state;

  void _emit(HomeState state) {
    _state = state;
    _controller.add(state);
  }

  Future<void> loadInitial() async {
    if (_loading) return;
    _loading = true;
    _page = 1;
    _emit(
      _state.copyWith(
        status: HomeStatus.loading,
        movies: const [],
        hasMore: true,
        isLoadingMore: false,
        errorMessage: null,
      ),
    );
    try {
      final pageData = await _getMoviesPageUseCase(
        page: _page,
        pageSize: _pageSize,
      );
      if (pageData.movies.isEmpty) {
        _emit(
          _state.copyWith(
            status: HomeStatus.empty,
            movies: const [],
            hasMore: false,
          ),
        );
      } else {
        _emit(
          _state.copyWith(
            status: HomeStatus.success,
            movies: pageData.movies,
            hasMore: pageData.hasMore,
          ),
        );
      }
    } catch (error) {
      _emit(
        _state.copyWith(
          status: HomeStatus.error,
          errorMessage: 'Failed to load movies. Please try again.',
        ),
      );
    } finally {
      _loading = false;
    }
  }

  Future<void> refresh() async {
    await loadInitial();
  }

  Future<void> loadMore() async {
    if (_loading || !_state.hasMore || _state.isLoadingMore) return;
    _loading = true;
    _emit(_state.copyWith(isLoadingMore: true, errorMessage: null));
    try {
      final nextPage = _page + 1;
      final pageData = await _getMoviesPageUseCase(
        page: nextPage,
        pageSize: _pageSize,
      );
      _page = nextPage;
      _emit(
        _state.copyWith(
          status: HomeStatus.success,
          movies: [..._state.movies, ...pageData.movies],
          hasMore: pageData.hasMore,
          isLoadingMore: false,
        ),
      );
    } catch (error) {
      _emit(
        _state.copyWith(
          isLoadingMore: false,
          errorMessage: 'Failed to load more movies.',
        ),
      );
    } finally {
      _loading = false;
    }
  }

  void close() {
    _controller.close();
  }
}
