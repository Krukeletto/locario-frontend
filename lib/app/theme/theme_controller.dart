import 'package:flutter/material.dart';

import '../settings/app_settings_store.dart';

class ThemeController extends ChangeNotifier {
  ThemeController({
    required AppSettingsStore settingsStore,
    ThemeMode initialThemeMode = ThemeMode.system,
  }) : _settingsStore = settingsStore,
       _themeMode = initialThemeMode;

  final AppSettingsStore _settingsStore;
  ThemeMode _themeMode;

  ThemeMode get themeMode => _themeMode;

  Future<void> load() async {
    final savedThemeMode = await _settingsStore.loadThemeMode();
    if (savedThemeMode == null || _themeMode == savedThemeMode) {
      return;
    }

    _themeMode = savedThemeMode;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    if (_themeMode == themeMode) {
      return;
    }

    _themeMode = themeMode;
    await _settingsStore.saveThemeMode(themeMode);
    notifyListeners();
  }
}
