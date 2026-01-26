import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/favorite_movie_model.dart';

abstract class FavoritesLocalDataSource {
  Future<List<FavoriteMovieModel>> readFavorites();

  Future<void> writeFavorites(List<FavoriteMovieModel> favorites);
}

class FavoritesLocalDataSourceImpl implements FavoritesLocalDataSource {
  static const _fileName = 'shartflix_favorites.json';

  @override
  Future<List<FavoriteMovieModel>> readFavorites() async {
    final file = await _favoritesFile();
    if (!await file.exists()) {
      return [];
    }
    final contents = await file.readAsString();
    if (contents.trim().isEmpty) {
      return [];
    }
    final decoded = jsonDecode(contents);
    if (decoded is! List) {
      return [];
    }
    return decoded
        .whereType<Map>()
        .map((item) => FavoriteMovieModel.fromJson(
              Map<String, dynamic>.from(item),
            ))
        .toList();
  }

  @override
  Future<void> writeFavorites(List<FavoriteMovieModel> favorites) async {
    final file = await _favoritesFile();
    final payload = favorites.map((movie) => movie.toJson()).toList();
    await file.writeAsString(jsonEncode(payload));
  }

  Future<File> _favoritesFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_fileName');
  }
}
