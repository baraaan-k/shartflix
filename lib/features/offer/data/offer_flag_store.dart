import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class OfferFlagStore {
  static const _fileName = 'shartflix_flags.json';
  static const _offerKey = 'offerShown';

  Future<bool> isOfferShown() async {
    final file = await _flagsFile();
    if (!await file.exists()) {
      return false;
    }
    final contents = await file.readAsString();
    if (contents.trim().isEmpty) {
      return false;
    }
    final decoded = jsonDecode(contents);
    if (decoded is! Map) {
      return false;
    }
    final map = Map<String, dynamic>.from(decoded);
    return map[_offerKey] == true;
  }

  Future<void> markOfferShown() async {
    final file = await _flagsFile();
    final payload = jsonEncode({_offerKey: true});
    await file.writeAsString(payload);
  }

  Future<File> _flagsFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_fileName');
  }
}
