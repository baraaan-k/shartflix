import '../../domain/entities/favorite_movie.dart';

class FavoriteMovieModel {
  FavoriteMovieModel({
    required this.id,
    required this.title,
    required this.overview,
  });

  final int id;
  final String title;
  final String overview;

  factory FavoriteMovieModel.fromJson(Map<String, dynamic> json) {
    return FavoriteMovieModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      overview: json['overview'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'overview': overview,
    };
  }

  FavoriteMovie toEntity() {
    return FavoriteMovie(
      id: id,
      title: title,
      overview: overview,
    );
  }

  factory FavoriteMovieModel.fromEntity(FavoriteMovie movie) {
    return FavoriteMovieModel(
      id: movie.id,
      title: movie.title,
      overview: movie.overview,
    );
  }
}
