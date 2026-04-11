import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AppSettingsStore {
  Future<Locale?> loadLocale();
  Future<void> saveLocale(Locale locale);
  Future<ThemeMode?> loadThemeMode();
  Future<void> saveThemeMode(ThemeMode themeMode);
}

class SharedPreferencesAppSettingsStore implements AppSettingsStore {
  static const _localeKey = 'app.locale';
  static const _themeModeKey = 'app.theme_mode';

  const SharedPreferencesAppSettingsStore();

  Future<SharedPreferences> get _preferences async =>
      SharedPreferences.getInstance();

  @override
  Future<Locale?> loadLocale() async {
    final languageCode = (await _preferences).getString(_localeKey);
    if (languageCode == null || languageCode.isEmpty) {
      return null;
    }

    return Locale(languageCode);
  }

  @override
  Future<void> saveLocale(Locale locale) async {
    await (await _preferences).setString(_localeKey, locale.languageCode);
  }

  @override
  Future<ThemeMode?> loadThemeMode() async {
    final storedThemeMode = (await _preferences).getString(_themeModeKey);
    return switch (storedThemeMode) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      _ => null,
    };
  }

  @override
  Future<void> saveThemeMode(ThemeMode themeMode) async {
    final value = switch (themeMode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await (await _preferences).setString(_themeModeKey, value);
  }
}
