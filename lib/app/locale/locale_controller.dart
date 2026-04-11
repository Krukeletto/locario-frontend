import 'package:flutter/widgets.dart';

import '../settings/app_settings_store.dart';

class LocaleController extends ChangeNotifier {
  LocaleController({
    required AppSettingsStore settingsStore,
    Locale initialLocale = const Locale('pl'),
  }) : _settingsStore = settingsStore,
       _locale = initialLocale;

  final AppSettingsStore _settingsStore;
  Locale _locale;

  Locale get locale => _locale;

  Future<void> load() async {
    final savedLocale = await _settingsStore.loadLocale();
    if (savedLocale == null || _locale == savedLocale) {
      return;
    }

    _locale = savedLocale;
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) {
      return;
    }

    _locale = locale;
    await _settingsStore.saveLocale(locale);
    notifyListeners();
  }
}
