import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_theme_controller.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../ui/components/app_button.dart';
import '../../../../ui/primitives/app_card.dart';
import '../../../../ui/primitives/app_text.dart';
import '../../../favorites/domain/entities/favorite_movie.dart';
import '../../../favorites/presentation/bloc/favorites_cubit.dart';
import '../../../favorites/presentation/bloc/favorites_state.dart';
import '../../../offer/data/offer_flag_store.dart';
import '../../../../screens/limited_offer_modal.dart';
import '../../domain/usecases/get_movies_page_usecase.dart';
import '../bloc/home_cubit.dart';
import '../bloc/home_state.dart';
import '../widgets/vertical_movie_card.dart';
import '../../../../screens/movie_detail_sheet.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  late final HomeCubit _cubit;
  late final FavoritesCubit _favoritesCubit;
  late final OfferFlagStore _offerFlagStore;
  final ScrollController _scrollController = ScrollController();
  StreamSubscription<HomeState>? _subscription;
  StreamSubscription<FavoritesState>? _favoritesSubscription;
  String? _lastFavoritesError;

  @override
  void initState() {
    super.initState();
    _cubit = HomeCubit(
      ServiceLocator.instance.get<GetMoviesPageUseCase>(),
    );
    _favoritesCubit = ServiceLocator.instance.get<FavoritesCubit>();
    _offerFlagStore = ServiceLocator.instance.get<OfferFlagStore>();
    _subscription = _cubit.stream.listen(_handleState);
    _favoritesSubscription = _favoritesCubit.stream.listen(_handleFavoritesState);
    _scrollController.addListener(_onScroll);
    _cubit.loadInitial();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _favoritesSubscription?.cancel();
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

  if (state.status == HomeStatus.success && state.hasMore && !state.isLoadingMore) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      if (_scrollController.position.maxScrollExtent == 0) {
        _cubit.loadMore(); // ekran dolana kadar bir sayfa daha çeker
      }
    });
  }

  if (state.errorMessage != null && state.movies.isNotEmpty) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.homeErrorTitle)),
    );
  }
}

  void _handleFavoritesState(FavoritesState state) {
    if (!mounted) return;
    if (state.errorMessage != null && state.errorMessage != _lastFavoritesError) {
      _lastFavoritesError = state.errorMessage;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.commonError)),
      );
    }
  }


  Future<void> _onRefresh() async {
    await _cubit.refresh();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = AppLocalizations.of(context)!;
    final themeController =
        ServiceLocator.instance.get<AppThemeController>();
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeController.themeMode,
      builder: (context, _, __) {
        return StreamBuilder<HomeState>(
          initialData: _cubit.state,
          stream: _cubit.stream,
          builder: (context, snapshot) {
            final state = snapshot.data ?? const HomeState();
            if (state.status == HomeStatus.loading && state.movies.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == HomeStatus.error && state.movies.isEmpty) {
              return _RefreshableState(
                onRefresh: _onRefresh,
                child: _ErrorState(
                  message: l10n.homeErrorTitle,
                  retryLabel: l10n.commonRetry,
                  onRetry: _cubit.loadInitial,
                ),
              );
            }
            if (state.status == HomeStatus.empty) {
              return _RefreshableState(
                onRefresh: _onRefresh,
                child: _EmptyState(
                  title: l10n.homeEmptyTitle,
                  subtitle: l10n.homeEmptySubtitle,
                ),
              );
            }

            final itemCount =
                state.movies.length + (state.isLoadingMore ? 1 : 0) + 1;

            return Column(
              children: [
                AppBar(
                  centerTitle: true,
                  title: AppText(
                    'Shartflix',
                    style: AppTextStyle.h2,
                  ),
                ),
                Expanded(
                  child: StreamBuilder<FavoritesState>(
                    initialData: _favoritesCubit.state,
                    stream: _favoritesCubit.stream,
                    builder: (context, favoritesSnapshot) {
                      final favoritesState =
                          favoritesSnapshot.data ?? const FavoritesState();
                      return RefreshIndicator(
                        onRefresh: _onRefresh,
                        child: ListView.builder(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          itemCount: itemCount,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return _LimitedOfferBanner(
                                title: l10n.offerBannerTitle,
                                subtitle: l10n.offerBannerSubtitle,
                                onTap: () async {
                                  await showLimitedOfferModal(context);
                                  await _offerFlagStore.markOfferShown();
                                },
                              );
                            }
                            final movieIndex = index - 1;
                            if (movieIndex >= state.movies.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              );
                            }
                            final movie = state.movies[movieIndex];
                            final isFavorite =
                                favoritesState.favoriteIds.contains(movie.id);
                            return VerticalMovieCard(
                              movie: movie,
                              isFavorite: isFavorite,
                              onFavoriteTap: () {
                                _favoritesCubit.toggleFavorite(
                                  FavoriteMovie(
                                    id: movie.id,
                                    title: movie.title,
                                    overview: movie.overview,
                                    posterUrl: movie.posterUrl,
                                    images: movie.images,
                                  ),
                                );
                              },
                              onTap: () => showMovieDetailSheet(context, movie),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _LimitedOfferBanner extends StatelessWidget {
  const _LimitedOfferBanner({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: GestureDetector(
        onTap: onTap,
        child: AppCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          borderColor: AppColors.brandRed,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(title, style: AppTextStyle.h2),
                    const SizedBox(height: AppSpacing.xs),
                    AppText(
                      subtitle,
                      style: AppTextStyle.caption,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Icon(Icons.arrow_forward, color: AppColors.brandRed),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.movie_filter_outlined, size: 48),
            const SizedBox(height: AppSpacing.sm),
            AppText(
              title,
              style: AppTextStyle.h2,
              align: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            AppText(
              subtitle,
              style: AppTextStyle.body,
              color: AppColors.textSecondary,
              align: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning_amber_rounded, size: 48),
            const SizedBox(height: AppSpacing.sm),
            AppText(
              message,
              style: AppTextStyle.h2,
              align: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              onPressed: onRetry,
              label: retryLabel,
              variant: AppButtonVariant.secondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _RefreshableState extends StatelessWidget {
  const _RefreshableState({
    required this.onRefresh,
    required this.child,
  });

  final Future<void> Function() onRefresh;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: child,
          ),
        ],
      ),
    );
  }
}
