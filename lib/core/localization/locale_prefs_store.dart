import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class LocalePrefsStore {
  static const _fileName = 'shartflix_prefs.json';
  static const _localeKey = 'localeCode';

  Future<String?> readLocaleCode() async {
    final file = await _prefsFile();
    if (!await file.exists()) {
      return null;
    }
    final contents = await file.readAsString();
    if (contents.trim().isEmpty) {
      return null;
    }
    final decoded = jsonDecode(contents);
    if (decoded is! Map) {
      return null;
    }
    final map = Map<String, dynamic>.from(decoded);
    final code = map[_localeKey] as String?;
    return (code == 'en' || code == 'tr') ? code : null;
  }

  Future<void> saveLocaleCode(String code) async {
    final file = await _prefsFile();
    if (code != 'en' && code != 'tr') {
      if (await file.exists()) {
        await file.delete();
      }
      return;
    }
    final payload = jsonEncode({_localeKey: code});
    await file.writeAsString(payload);
  }

  Future<File> _prefsFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_fileName');
  }
}
