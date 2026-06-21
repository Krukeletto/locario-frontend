import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:locario/app/locale/locale_controller.dart';
import 'package:locario/app/locale/locale_scope.dart';
import 'package:locario/features/onboarding/onboarding_controller.dart';
import 'package:locario/features/onboarding/onboarding_scope.dart';
import 'package:locario/features/onboarding/onboarding_screen.dart';
import 'package:locario/l10n/app_localizations.dart';
import 'package:locario/shared/permissions/app_permission_service.dart';

import '../../test_helpers/fake_app_settings_store.dart';

void main() {
  testWidgets('saves completion only after final step', (tester) async {
    final settingsStore = FakeAppSettingsStore();
    final permissionService = _FakePermissionService();
    final onboardingController = OnboardingController(
      settingsStore: settingsStore,
    );
    await onboardingController.load();

    await tester.pumpWidget(
      _buildOnboardingTestApp(
        onboardingController: onboardingController,
        settingsStore: settingsStore,
        permissionService: permissionService,
      ),
    );
    await tester.pumpAndSettle();

    expect(await settingsStore.loadOnboardingCompleted(), isFalse);
    expect(permissionService.loadStatusCount, 0);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(permissionService.loadStatusCount, 0);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(permissionService.loadStatusCount, 1);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(await settingsStore.loadOnboardingCompleted(), isFalse);

    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();

    expect(await settingsStore.loadOnboardingCompleted(), isTrue);
    expect(onboardingController.isCompleted, isTrue);
  });

  testWidgets('updates language selection', (tester) async {
    final settingsStore = FakeAppSettingsStore();
    final onboardingController = OnboardingController(
      settingsStore: settingsStore,
    );
    await onboardingController.load();
    final localeController = LocaleController(
      settingsStore: settingsStore,
      initialLocale: const Locale('pl'),
    );

    await tester.pumpWidget(
      _buildOnboardingTestApp(
        onboardingController: onboardingController,
        settingsStore: settingsStore,
        localeController: localeController,
        locale: const Locale('pl'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('onboarding-language-segmented')),
        matching: find.text('Angielski'),
      ),
    );
    await tester.pumpAndSettle();

    expect(localeController.locale, const Locale('en'));
    expect(await settingsStore.loadLocale(), const Locale('en'));
  });
}

Widget _buildOnboardingTestApp({
  required OnboardingController onboardingController,
  required FakeAppSettingsStore settingsStore,
  LocaleController? localeController,
  AppPermissionService? permissionService,
  Locale locale = const Locale('en'),
}) {
  final effectiveLocaleController =
      localeController ??
      LocaleController(settingsStore: settingsStore, initialLocale: locale);
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => OnboardingScreen(
          permissionService: permissionService ?? _FakePermissionService(),
        ),
      ),
      GoRoute(
        path: '/explore',
        builder: (context, state) => const SizedBox(key: Key('explore')),
      ),
    ],
  );

  return OnboardingScope(
    controller: onboardingController,
    child: LocaleScope(
      controller: effectiveLocaleController,
      child: MaterialApp.router(
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        routerConfig: router,
      ),
    ),
  );
}

class _FakePermissionService implements AppPermissionService {
  int loadStatusCount = 0;

  @override
  Future<AppPermissionSnapshot> loadStatus() async {
    loadStatusCount++;
    return const AppPermissionSnapshot(
      location: AppPermissionStatus.denied,
      notifications: AppPermissionStatus.denied,
      photos: AppPermissionStatus.denied,
      calendar: AppPermissionStatus.granted,
    );
  }

  @override
  Future<bool> openAppSettings() async => true;

  @override
  Future<AppPermissionStatus> requestLocation() async {
    return AppPermissionStatus.granted;
  }

  @override
  Future<AppPermissionStatus> requestNotifications() async {
    return AppPermissionStatus.granted;
  }
}
