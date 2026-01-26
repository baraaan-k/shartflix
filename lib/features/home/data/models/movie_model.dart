import '../../domain/entities/movie.dart';

class MovieModel {
  MovieModel({
    required this.id,
    required this.title,
    required this.overview,
  });

  final int id;
  final String title;
  final String overview;

  Movie toEntity() {
    return Movie(
      id: id,
      title: title,
      overview: overview,
    );
  }
}
