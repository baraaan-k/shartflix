import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_theme_controller.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_radius.dart';
import '../../../../theme/app_typography.dart';
import '../../../../ui/components/app_button.dart';
import '../../../../ui/primitives/app_text.dart';
import '../../../../ui/like_burst_overlay.dart';
import '../../../favorites/domain/entities/favorite_movie.dart';
import '../../../favorites/presentation/bloc/favorites_cubit.dart';
import '../../../favorites/presentation/bloc/favorites_state.dart';
import '../../domain/usecases/get_movies_page_usecase.dart';
import '../bloc/home_cubit.dart';
import '../bloc/home_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  late final HomeCubit _cubit;
  late final FavoritesCubit _favoritesCubit;
  final PageController _pageController = PageController();
  final Set<String> _expandedMovieIds = {};
  static const int _previewCharLimit = 60;
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
    _subscription = _cubit.stream.listen(_handleState);
    _favoritesSubscription = _favoritesCubit.stream.listen(_handleFavoritesState);
    _cubit.loadInitial();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _favoritesSubscription?.cancel();
    _pageController.dispose();
    _cubit.close();
    super.dispose();
  }

  void _handleState(HomeState state) {
    if (!mounted) return;
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

  bool _shouldShowReadMore(String text) {
    return text.trim().length > _previewCharLimit;
  }

  String _buildPreview(String text, String readMore) {
    final trimmed = text.trim();
    if (trimmed.length <= _previewCharLimit) return trimmed;
    return '${trimmed.substring(0, _previewCharLimit).trim()} $readMore';
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
        final bottomInset = MediaQuery.of(context).padding.bottom;
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

            return StreamBuilder<FavoritesState>(
              initialData: _favoritesCubit.state,
              stream: _favoritesCubit.stream,
              builder: (context, favoritesSnapshot) {
                final favoritesState =
                    favoritesSnapshot.data ?? const FavoritesState();
                const tabBarHeight = 84.0;
                final blurHeight = tabBarHeight + bottomInset + 240.0;
                final likeBottom = tabBarHeight + bottomInset + 120.0;
                return PageView.builder(
                  controller: _pageController,
                  scrollDirection: Axis.vertical,
                  itemCount: state.movies.length,
                  onPageChanged: (index) {
                    if (index >= state.movies.length - 2) {
                      _cubit.loadMore();
                    }
                  },
                  itemBuilder: (context, index) {
                    final movie = state.movies[index];
                    final isFavorite =
                        favoritesState.favoriteIds.contains(movie.id);
                    final canExpand = _shouldShowReadMore(movie.overview);
                    final isExpanded = _expandedMovieIds.contains(movie.id);
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        Positioned.fill(
                          child: Image.network(
                            movie.posterUrl ?? '',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stack) {
                              return Container(color: AppColors.bg);
                            },
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          height: blurHeight,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRect(
                                child: ShaderMask(
                                  blendMode: BlendMode.dstIn,
                                  shaderCallback: (rect) {
                                    return const LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.white,
                                      ],
                                      stops: [0.0, 0.6],
                                    ).createShader(rect);
                                  },
                                  child: ImageFiltered(
                                    imageFilter:
                                        ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                    child: Image.network(
                                      movie.posterUrl ?? '',
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stack) {
                                        return Container(color: AppColors.bg);
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.black.withValues(alpha: 0.0),
                                      Colors.black.withValues(alpha: 0.75),
                                      Colors.black.withValues(alpha: 0.85),
                                      Colors.black.withValues(alpha: 0.95),
                                    ],
                                    stops: const [0.0, 0.35, 0.7, 1.0],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          left: AppSpacing.lg,
                          right: AppSpacing.lg,
                          bottom: tabBarHeight + bottomInset + 18.0,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: ClipOval(
                                  child: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.black.withValues(alpha: 0.2),
                                      border: Border.all(
                                        color: Colors.white.withAlpha(60),
                                      ),
                                    ),
                                    child: Image.asset(
                                      'assets/images/iconImage.png',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppText(
                                      movie.title,
                                      style: AppTextStyle.h2,
                                      color: Colors.white,
                                      align: TextAlign.left,
                                    ),
                                    const SizedBox(height: 6),
                                    if (!canExpand || isExpanded)
                                      Text(
                                        movie.overview,
                                        style: AppTypography.body
                                            .copyWith(fontSize: 15)
                                            .copyWith(
                                              color: AppColors.textSecondary,
                                            ),
                                        maxLines: isExpanded ? 8 : 2,
                                        overflow: TextOverflow.clip,
                                        textAlign: TextAlign.left,
                                      )
                                    else
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _expandedMovieIds.add(movie.id);
                                          });
                                        },
                                        child: RichText(
                                          maxLines: 2,
                                          overflow: TextOverflow.clip,
                                          text: TextSpan(
                                            style: AppTypography.body.copyWith(
                                              color: AppColors.textSecondary,
                                              fontSize: 15,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: _buildPreview(
                                                  movie.overview,
                                                  '',
                                                ),
                                              ),
                                              const TextSpan(text: ' '),
                                              TextSpan(
                                                text: l10n.commonReadMore,
                                                style: AppTypography.body
                                                    .copyWith(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    if (isExpanded && canExpand) ...[
                                      const SizedBox(height: AppSpacing.xs),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _expandedMovieIds
                                                .remove(movie.id);
                                          });
                                        },
                                        child: Text(
                                          l10n.commonReadLess,
                                          style: AppTypography.body
                                              .copyWith(fontSize: 15)
                                              .copyWith(
                                                color: Colors.white,
                                              ),
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          right: AppSpacing.lg,
                          bottom: likeBottom,
                          child: GestureDetector(
                            onTap: () {
                              LikeBurstOverlay.maybeOf(context)?.play();
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
                            child: Container(
                              width: 53,
                              height: 73,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.35),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.pill),
                                border: Border.all(
                                  color: Colors.white.withAlpha(80),
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isFavorite
                                      ? AppColors.brandRed
                                      : Colors.white,
                                  size: 22,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
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
    final bottomInset = MediaQuery.of(context).padding.bottom;
    const tabBarHeight = 72.0;
    final scrollBottomPadding = tabBarHeight + bottomInset + AppSpacing.md;
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.only(bottom: scrollBottomPadding),
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
