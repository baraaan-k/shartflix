import '../../domain/entities/favorite_movie.dart';

class FavoriteMovieModel {
  FavoriteMovieModel({
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

  factory FavoriteMovieModel.fromJson(Map<String, dynamic> json) {
    final poster = json['posterUrl'] as String? ??
        json['poster'] as String? ??
        json['Poster'] as String?;
    final imagesRaw = json['images'] as List? ?? json['Images'] as List?;
    final images = imagesRaw
            ?.map((item) => item.toString())
            .where((item) => item.trim().isNotEmpty)
            .toList() ??
        const <String>[];
    return FavoriteMovieModel(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      title: json['title'] as String? ?? json['Title'] as String? ?? '',
      overview: json['overview'] as String? ??
          json['description'] as String? ??
          json['Plot'] as String? ??
          '',
      posterUrl: _normalizePoster(poster, images),
      images: images,
    );
  }

  static String? _normalizePoster(String? poster, List<dynamic>? images) {
    String u = (poster ?? '').trim();
    if (u.isEmpty && images != null && images.isNotEmpty) {
      u = (images.first ?? '').toString().trim();
    }
    if (u.startsWith('http://')) {
      u = u.replaceFirst('http://', 'https://');
    }
    return u.isEmpty ? null : u;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'overview': overview,
      'posterUrl': posterUrl,
      'images': images,
    };
  }

  FavoriteMovie toEntity() {
    return FavoriteMovie(
      id: id,
      title: title,
      overview: overview,
      posterUrl: posterUrl,
      images: images,
    );
  }

  factory FavoriteMovieModel.fromEntity(FavoriteMovie movie) {
    return FavoriteMovieModel(
      id: movie.id,
      title: movie.title,
      overview: movie.overview,
      posterUrl: movie.posterUrl,
      images: movie.images,
    );
  }
}
