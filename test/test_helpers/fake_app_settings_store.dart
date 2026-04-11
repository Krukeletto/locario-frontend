import 'package:flutter/material.dart';
import 'package:locario/app/settings/app_settings_store.dart';

class FakeAppSettingsStore implements AppSettingsStore {
  FakeAppSettingsStore({this.initialLocale, this.initialThemeMode})
    : _savedLocale = initialLocale,
      _savedThemeMode = initialThemeMode;

  final Locale? initialLocale;
  final ThemeMode? initialThemeMode;

  Locale? _savedLocale;
  ThemeMode? _savedThemeMode;

  @override
  Future<Locale?> loadLocale() async => _savedLocale;

  @override
  Future<void> saveLocale(Locale locale) async {
    _savedLocale = locale;
  }

  @override
  Future<ThemeMode?> loadThemeMode() async => _savedThemeMode;

  @override
  Future<void> saveThemeMode(ThemeMode themeMode) async {
    _savedThemeMode = themeMode;
  }
}
