import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:locario/app/locale/locale_controller.dart';
import 'package:locario/app/locale/locale_scope.dart';
import 'package:locario/app/theme/theme_controller.dart';
import 'package:locario/app/theme/theme_scope.dart';
import 'package:locario/features/profile/settings_screen.dart';
import 'package:locario/shared/auth/auth_api.dart';
import 'package:locario/shared/auth/auth_repository.dart';
import 'package:locario/shared/auth/session_controller.dart';
import 'package:locario/shared/auth/auth_scope.dart';
import 'package:locario/shared/auth/auth_models.dart';
import 'package:locario/shared/notifications/notification_controller.dart';
import 'package:locario/shared/notifications/notification_scope.dart';
import 'package:locario/shared/notifications/shared_prefs_notification_history_repository.dart';
import 'package:locario/shared/notifications/shared_prefs_notification_preferences_store.dart';
import 'package:locario/shared/permissions/app_permission_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../test_helpers/fake_app_settings_store.dart';
import '../../test_helpers/test_app.dart';

// Minimal in-memory token storage for tests
class _MemoryAuthStorage implements AuthTokenStorage {
  AuthTokens? stored;

  @override
  Future<void> saveTokens(AuthTokens tokens) async => stored = tokens;

  @override
  Future<AuthTokens?> readTokens() async => stored;

  @override
  Future<void> clear() async => stored = null;
}

void main() {
  group('SettingsScreen', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('updates locale selection', (tester) async {
      final localeController = LocaleController(
        settingsStore: FakeAppSettingsStore(),
      );
      final themeController = ThemeController(
        settingsStore: FakeAppSettingsStore(),
      );
      final notificationController = NotificationController(
        historyRepository: const SharedPrefsNotificationHistoryRepository(),
        preferencesStore: const SharedPrefsNotificationPreferencesStore(),
      );

      // Provide an unauthenticated SessionController via AuthScope
      final sessionController = SessionController(
        authRepository: AuthRepository(
          api: AuthApi(),
          storage: _MemoryAuthStorage(),
        ),
      );
      await sessionController.load();

      await tester.pumpWidget(
        NotificationScope(
          controller: notificationController,
          child: LocaleScope(
            controller: localeController,
            child: ThemeScope(
              controller: themeController,
              child: AuthScope(
                controller: sessionController,
                child: buildLocalizedTestApp(
                  locale: const Locale('pl'),
                  home: const SettingsScreen(),
                ),
              ),
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
      final notificationController = NotificationController(
        historyRepository: const SharedPrefsNotificationHistoryRepository(),
        preferencesStore: const SharedPrefsNotificationPreferencesStore(),
      );

      final sessionController = SessionController(
        authRepository: AuthRepository(
          api: AuthApi(),
          storage: _MemoryAuthStorage(),
        ),
      );
      await sessionController.load();

      await tester.pumpWidget(
        NotificationScope(
          controller: notificationController,
          child: LocaleScope(
            controller: localeController,
            child: ThemeScope(
              controller: themeController,
              child: AuthScope(
                controller: sessionController,
                child: buildLocalizedTestApp(
                  locale: const Locale('pl'),
                  home: const SettingsScreen(),
                ),
              ),
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

    testWidgets('renders permission section and requests missing permission', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final localeController = LocaleController(
        settingsStore: FakeAppSettingsStore(),
      );
      final themeController = ThemeController(
        settingsStore: FakeAppSettingsStore(),
      );
      final notificationController = NotificationController(
        historyRepository: const SharedPrefsNotificationHistoryRepository(),
        preferencesStore: const SharedPrefsNotificationPreferencesStore(),
      );
      final permissionService = _FakePermissionService();

      final sessionController = SessionController(
        authRepository: AuthRepository(
          api: AuthApi(),
          storage: _MemoryAuthStorage(),
        ),
      );
      await sessionController.load();

      await tester.pumpWidget(
        NotificationScope(
          controller: notificationController,
          child: LocaleScope(
            controller: localeController,
            child: ThemeScope(
              controller: themeController,
              child: AuthScope(
                controller: sessionController,
                child: buildLocalizedTestApp(
                  locale: const Locale('pl'),
                  home: SettingsScreen(permissionService: permissionService),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Brak uprawnienia'), findsWidgets);

      await tester.tap(find.text('Przyznaj').first);
      await tester.pumpAndSettle();

      expect(permissionService.locationRequestCount, 1);
    });
  });
}

class _FakePermissionService implements AppPermissionService {
  int locationRequestCount = 0;

  @override
  Future<AppPermissionSnapshot> loadStatus() async {
    return const AppPermissionSnapshot(
      location: AppPermissionStatus.denied,
      notifications: AppPermissionStatus.granted,
      photos: AppPermissionStatus.denied,
      calendar: AppPermissionStatus.granted,
    );
  }

  @override
  Future<bool> openAppSettings() async => true;

  @override
  Future<AppPermissionStatus> requestLocation() async {
    locationRequestCount++;
    return AppPermissionStatus.granted;
  }

  @override
  Future<AppPermissionStatus> requestNotifications() async {
    return AppPermissionStatus.granted;
  }
}
