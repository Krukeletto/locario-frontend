import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:locario/app/locale/locale_controller.dart';
import 'package:locario/app/theme/theme_controller.dart';

import '../test_helpers/fake_app_settings_store.dart';

void main() {
  group('LocaleController', () {
    test('loads persisted locale from store', () async {
      final controller = LocaleController(
        settingsStore: FakeAppSettingsStore(initialLocale: const Locale('en')),
      );

      await controller.load();

      expect(controller.locale, const Locale('en'));
    });

    test('persists selected locale', () async {
      final store = FakeAppSettingsStore();
      final controller = LocaleController(settingsStore: store);

      await controller.setLocale(const Locale('en'));

      expect(await store.loadLocale(), const Locale('en'));
    });
  });

  group('ThemeController', () {
    test('loads persisted theme mode from store', () async {
      final controller = ThemeController(
        settingsStore: FakeAppSettingsStore(initialThemeMode: ThemeMode.dark),
      );

      await controller.load();

      expect(controller.themeMode, ThemeMode.dark);
    });

    test('persists selected theme mode', () async {
      final store = FakeAppSettingsStore();
      final controller = ThemeController(settingsStore: store);

      await controller.setThemeMode(ThemeMode.light);

      expect(await store.loadThemeMode(), ThemeMode.light);
    });
  });
}
