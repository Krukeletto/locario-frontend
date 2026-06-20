import 'package:flutter/material.dart';
import 'package:locario/app/settings/app_settings_store.dart';

class FakeAppSettingsStore implements AppSettingsStore {
  FakeAppSettingsStore({
    this.initialLocale,
    this.initialThemeMode,
    bool initialOnboardingCompleted = false,
  }) : _savedLocale = initialLocale,
       _savedThemeMode = initialThemeMode,
       _onboardingCompleted = initialOnboardingCompleted;

  final Locale? initialLocale;
  final ThemeMode? initialThemeMode;

  Locale? _savedLocale;
  ThemeMode? _savedThemeMode;
  bool _onboardingCompleted;

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

  @override
  Future<bool> loadOnboardingCompleted() async => _onboardingCompleted;

  @override
  Future<void> saveOnboardingCompleted(bool completed) async {
    _onboardingCompleted = completed;
  }
}
