import '../../domain/entities/movie.dart';

class MovieModel {
  MovieModel({
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

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    final poster = json['posterUrl'] as String? ??
        json['poster'] as String? ??
        json['Poster'] as String?;
    final imagesRaw = json['images'] as List? ?? json['Images'] as List?;
    final images = imagesRaw
            ?.map((item) => item.toString())
            .where((item) => item.trim().isNotEmpty)
            .toList() ??
        const <String>[];
    return MovieModel(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      title: json['title'] as String? ??
          json['Title'] as String? ??
          '',
      overview: json['description'] as String? ??
          json['Plot'] as String? ??
          '',
      posterUrl: normalizePoster(poster, images),
      images: images,
    );
  }

  static String? normalizePoster(String? poster, List<String>? images) {
    String u = (poster ?? '').trim();
    if (u.isEmpty && images != null && images.isNotEmpty) {
      u = images.first.toString().trim();
    }
    if (u.startsWith('http://')) {
      u = u.replaceFirst('http://', 'https://');
    }
    return u.isEmpty ? null : u;
  }

  Movie toEntity() {
    return Movie(
      id: id,
      title: title,
      overview: overview,
      posterUrl: posterUrl,
      images: images,
    );
  }
}
