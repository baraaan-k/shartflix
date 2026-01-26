import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/di/service_locator.dart';
import '../../domain/usecases/get_movies_page_usecase.dart';
import '../bloc/home_cubit.dart';
import '../bloc/home_state.dart';
import '../widgets/movie_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeCubit _cubit;
  final ScrollController _scrollController = ScrollController();
  StreamSubscription<HomeState>? _subscription;

  @override
  void initState() {
    super.initState();
    _cubit = HomeCubit(
      ServiceLocator.instance.get<GetMoviesPageUseCase>(),
    );
    _subscription = _cubit.stream.listen(_handleState);
    _scrollController.addListener(_onScroll);
    _cubit.loadInitial();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _scrollController.dispose();
    _cubit.close();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      _cubit.loadMore();
    }
  }

  void _handleState(HomeState state) {
    if (!mounted) return;
    if (state.errorMessage != null && state.movies.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.errorMessage!)),
      );
    }
  }

  Future<void> _onRefresh() async {
    await _cubit.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<HomeState>(
      initialData: _cubit.state,
      stream: _cubit.stream,
      builder: (context, snapshot) {
        final state = snapshot.data ?? const HomeState();
        if (state.status == HomeStatus.loading && state.movies.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.status == HomeStatus.error && state.movies.isEmpty) {
          return _ErrorState(
            message: state.errorMessage ?? 'Something went wrong',
            onRetry: _cubit.loadInitial,
          );
        }
        if (state.status == HomeStatus.empty) {
          return const _EmptyState();
        }

        final itemCount = state.movies.length + (state.isLoadingMore ? 1 : 0);

        return RefreshIndicator(
          onRefresh: _onRefresh,
          child: ListView.builder(
            controller: _scrollController,
            itemCount: itemCount,
            itemBuilder: (context, index) {
              if (index >= state.movies.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              }
              return MovieCard(movie: state.movies[index]);
            },
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('No movies found.'),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
