import 'package:flutter/material.dart';

import '../features/home/domain/entities/movie.dart';
import 'movie_detail_sheet.dart';

class MovieDetailRoutePage extends StatefulWidget {
  const MovieDetailRoutePage({
    super.key,
    required this.movieId,
    this.movie,
  });

  final String movieId;
  final Movie? movie;

  @override
  State<MovieDetailRoutePage> createState() => _MovieDetailRoutePageState();
}

class _MovieDetailRoutePageState extends State<MovieDetailRoutePage> {
  bool _opened = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_opened) return;
    _opened = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      if (widget.movie != null) {
        await showMovieDetailSheet(context, widget.movie!);
      }
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
