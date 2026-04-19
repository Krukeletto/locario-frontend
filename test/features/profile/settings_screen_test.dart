import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:locario/app/locale/locale_controller.dart';
import 'package:locario/app/locale/locale_scope.dart';
import 'package:locario/app/theme/theme_controller.dart';
import 'package:locario/app/theme/theme_scope.dart';
import 'package:locario/features/profile/settings_screen.dart';

import '../../test_helpers/fake_app_settings_store.dart';
import '../../test_helpers/test_app.dart';

void main() {
  group('SettingsScreen', () {
    testWidgets('updates locale selection', (tester) async {
      final localeController = LocaleController(
        settingsStore: FakeAppSettingsStore(),
      );
      final themeController = ThemeController(
        settingsStore: FakeAppSettingsStore(),
      );

      await tester.pumpWidget(
        LocaleScope(
          controller: localeController,
          child: ThemeScope(
            controller: themeController,
            child: buildLocalizedTestApp(
              locale: const Locale('pl'),
              home: const SettingsScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byKey(const Key('settings-language-segmented')),
          matching: find.text('Angielski'),
        ),
      );
      await tester.pumpAndSettle();

      expect(localeController.locale, const Locale('en'));
    });

    testWidgets('updates theme mode selection', (tester) async {
      final localeController = LocaleController(
        settingsStore: FakeAppSettingsStore(),
      );
      final themeController = ThemeController(
        settingsStore: FakeAppSettingsStore(),
      );

      await tester.pumpWidget(
        LocaleScope(
          controller: localeController,
          child: ThemeScope(
            controller: themeController,
            child: buildLocalizedTestApp(
              locale: const Locale('pl'),
              home: const SettingsScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byKey(const Key('settings-theme-segmented')),
          matching: find.text('Ciemny'),
        ),
      );
      await tester.pumpAndSettle();

      expect(themeController.themeMode, ThemeMode.dark);
    });
  });
}
