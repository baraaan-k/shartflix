class Movie {
  const Movie({
    required this.id,
    required this.title,
    required this.overview,
    this.posterUrl,
    this.images = const [],
  });

  final String id;
  final String title;
  final String overview;
  final String? posterUrl;
  final List<String> images;
}
