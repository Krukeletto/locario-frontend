import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../settings/app_settings_store.dart';

class LocaleController extends ChangeNotifier {
  LocaleController({
    required AppSettingsStore settingsStore,
    Locale? initialLocale,
  }) : _settingsStore = settingsStore,
       _locale =
           initialLocale ??
           resolvePreferredLocale(ui.PlatformDispatcher.instance.locales);

  final AppSettingsStore _settingsStore;
  Locale _locale;

  Locale get locale => _locale;

  static Locale resolvePreferredLocale(List<Locale> platformLocales) {
    for (final locale in platformLocales) {
      if (locale.languageCode == 'pl' || locale.languageCode == 'en') {
        return Locale(locale.languageCode);
      }
    }

    return const Locale('pl');
  }

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
      await _settingsStore.saveLocale(locale);
      return;
    }

    _locale = locale;
    await _settingsStore.saveLocale(locale);
    notifyListeners();
  }
}
