import 'package:flutter/material.dart';

import 'locale_prefs_store.dart';

class AppLocaleController {
  AppLocaleController(this._prefsStore);

  final LocalePrefsStore _prefsStore;
  final ValueNotifier<Locale?> locale = ValueNotifier<Locale?>(null);

  Future<void> load() async {
    final code = await _prefsStore.readLocaleCode();
    if (code == null) return;
    locale.value = Locale(code);
  }

  Future<void> setLocale(Locale? newLocale) async {
    locale.value = newLocale;
    if (newLocale == null) return;
    await _prefsStore.saveLocaleCode(newLocale.languageCode);
  }

  Future<void> clearLocale() async {
    locale.value = null;
    await _prefsStore.saveLocaleCode('');
  }
}
