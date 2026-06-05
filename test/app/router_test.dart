import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:locario/app/router.dart';
import 'package:locario/features/auth/login_screen.dart';
import 'package:locario/features/legals/legal_acceptance_store.dart';
import 'package:locario/features/legals/legal_controller.dart';
import 'package:locario/features/legals/legal_versions.dart';
import 'package:locario/features/profile/profile_screen.dart';
import 'package:locario/features/saved/saved_screen.dart';
import 'package:locario/features/saved/saved_events_controller.dart';
import 'package:locario/features/saved/saved_events_repository.dart';
import 'package:locario/features/saved/saved_events_scope.dart';
import 'package:locario/features/saved/saved_filters_controller.dart';
import 'package:locario/features/saved/saved_filters_repository.dart';
import 'package:locario/features/saved/saved_filters_scope.dart';
import 'package:locario/shared/auth/auth_api.dart';
import 'package:locario/shared/auth/auth_models.dart';
import 'package:locario/shared/auth/auth_repository.dart';
import 'package:locario/shared/auth/auth_scope.dart';
import 'package:locario/shared/auth/session_controller.dart';
import 'package:locario/l10n/app_localizations.dart';

void main() {
  group('normalizeIncomingLocation', () {
    test('normalizes locario host-based event deep links', () {
      expect(
        normalizeIncomingLocation(
          Uri.parse('locario://events/11111111-1111-1111-1111-111111111111'),
        ),
        '/events/11111111-1111-1111-1111-111111111111',
      );
    });

    test('normalizes path-only UUID event deep links', () {
      expect(
        normalizeIncomingLocation(
          Uri.parse('/11111111-1111-1111-1111-111111111111'),
        ),
        '/events/11111111-1111-1111-1111-111111111111',
      );
    });

    test('does not rewrite normal top-level app routes', () {
      expect(normalizeIncomingLocation(Uri.parse('/explore')), isNull);
      expect(normalizeIncomingLocation(Uri.parse('/profile')), isNull);
    });
  });

  group('createAppRouter', () {
    testWidgets('allows unauthenticated access to saved route', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final sessionController = await _createSessionController();
      final legalController = _createLegalController(sessionController);
      final router = createAppRouter(
        sessionController: sessionController,
        legalController: legalController,
      );

      await tester.pumpWidget(
        AuthScope(
          controller: sessionController,
          child: SavedEventsScope(
            controller: SavedEventsController(
              repository: _MemorySavedEventsRepository(),
            ),
            child: SavedFiltersScope(
              controller: SavedFiltersController(
                repository: const SharedPreferencesSavedFiltersRepository(),
              ),
              child: MaterialApp.router(
                locale: const Locale('en'),
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                routerConfig: router,
              ),
            ),
          ),
        ),
      );

      router.go('/hub/saved');
      await tester.pumpAndSettle();

      expect(router.routerDelegate.currentConfiguration.uri.path, '/hub/saved');
      expect(find.byType(SavedScreen), findsOneWidget);
    });

    testWidgets(
      'redirects protected create-event route to login with last safe location',
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        final sessionController = await _createSessionController();
        final legalController = _createLegalController(sessionController);
        final router = createAppRouter(
          sessionController: sessionController,
          legalController: legalController,
        );

        await tester.pumpWidget(
          AuthScope(
            controller: sessionController,
            child: SavedEventsScope(
              controller: SavedEventsController(
                repository: _MemorySavedEventsRepository(),
              ),
              child: SavedFiltersScope(
                controller: SavedFiltersController(
                  repository: const SharedPreferencesSavedFiltersRepository(),
                ),
                child: MaterialApp.router(
                  locale: const Locale('en'),
                  supportedLocales: AppLocalizations.supportedLocales,
                  localizationsDelegates:
                      AppLocalizations.localizationsDelegates,
                  routerConfig: router,
                ),
              ),
            ),
          ),
        );

        router.go('/hub/saved');
        await tester.pumpAndSettle();
        expect(
          router.routerDelegate.currentConfiguration.uri.path,
          '/hub/saved',
        );

        router.go('/hub/saved');
        await tester.pumpAndSettle();

        router.go('/hub/create-event');
        await tester.pumpAndSettle();

        expect(
          router.routerDelegate.currentConfiguration.uri.path,
          '/auth/login',
        );
        expect(
          router
              .routerDelegate
              .currentConfiguration
              .uri
              .queryParameters['target'],
          '/hub/create-event',
        );
        expect(
          router
              .routerDelegate
              .currentConfiguration
              .uri
              .queryParameters['from'],
          '/hub/saved',
        );
        expect(find.byType(LoginScreen), findsOneWidget);
      },
    );

    testWidgets('redirects non-organizers away from organizer reviews route', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final sessionController = await _createSessionController(
        authenticated: true,
        role: 'user',
      );
      final legalController = _createLegalController(sessionController);
      final router = createAppRouter(
        sessionController: sessionController,
        legalController: legalController,
      );

      await tester.pumpWidget(
        AuthScope(
          controller: sessionController,
          child: SavedEventsScope(
            controller: SavedEventsController(
              repository: _MemorySavedEventsRepository(),
            ),
            child: SavedFiltersScope(
              controller: SavedFiltersController(
                repository: const SharedPreferencesSavedFiltersRepository(),
              ),
              child: MaterialApp.router(
                locale: const Locale('en'),
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                routerConfig: router,
              ),
            ),
          ),
        ),
      );

      router.go('/profile/reviews');
      await tester.pumpAndSettle();

      expect(router.routerDelegate.currentConfiguration.uri.path, '/profile');
      expect(find.byType(ProfileScreen), findsOneWidget);
    });
  });
}

class _MemoryAuthStorage implements AuthTokenStorage {
  AuthTokens? stored;

  @override
  Future<void> saveTokens(AuthTokens tokens) async {
    stored = tokens;
  }

  @override
  Future<AuthTokens?> readTokens() async => stored;

  @override
  Future<void> clear() async {
    stored = null;
  }
}

class _FakeAuthApi extends AuthApi {
  _FakeAuthApi({required this.profile}) : super();

  final UserProfile profile;

  @override
  Future<AuthResponse> login(LoginRequest request) {
    throw StateError('login not configured');
  }

  @override
  Future<UserProfile> fetchProfile({
    required String accessToken,
    String tokenType = 'Bearer',
  }) {
    return Future.value(profile);
  }

  @override
  Future<AuthResponse> register(RegisterRequest request) {
    throw StateError('register not configured');
  }

  @override
  Future<AuthResponse> refresh(String refreshToken) {
    throw StateError('refresh not configured');
  }

  @override
  Future<AuthResponse> loginWithGoogle(String idToken) {
    throw StateError('loginWithGoogle not configured');
  }

  @override
  Future<void> logout({
    required String accessToken,
    String tokenType = 'Bearer',
  }) {
    throw StateError('logout not configured');
  }
}

class _MemorySavedEventsRepository implements SavedEventsRepository {
  @override
  Future<List<SavedEventRecord>> loadSavedEvents() async => const [];

  @override
  Future<void> upsertSavedEvent(SavedEventRecord record) async {}

  @override
  Future<void> removeSavedEvent(String eventId) async {}

  @override
  Future<void> replaceSavedEvents(List<SavedEventRecord> records) async {}

  @override
  Future<void> clear() async {}
}

Future<SessionController> _createSessionController({
  bool authenticated = false,
  String role = 'user',
}) async {
  final storage = _MemoryAuthStorage();
  if (authenticated) {
    storage.stored = AuthTokens(
      accessToken: 'access-token',
      refreshToken: 'refresh-token',
      tokenType: 'Bearer',
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
    );
  }
  final controller = SessionController(
    authRepository: AuthRepository(
      api: _FakeAuthApi(
        profile: UserProfile(
          id: 'user-id',
          username: 'user',
          email: 'user@example.com',
          hasPassword: true,
          avatarUrl: null,
          bio: null,
          websiteUrl: null,
          instagramUrl: null,
          facebookUrl: null,
          createdAt: DateTime.utc(2026, 5, 1),
          eventRegistrations: const [],
          role: role,
        ),
      ),
      storage: storage,
    ),
  );

  await controller.load();
  return controller;
}

class _FakeLegalAcceptanceStore implements LegalAcceptanceStore {
  @override
  Future<int> getAcceptedTermsVersion(String userId) async =>
      LegalVersions.termsVersion;

  @override
  Future<int> getAcceptedPrivacyVersion(String userId) async =>
      LegalVersions.privacyVersion;

  @override
  Future<void> acceptTerms(String userId, int version) async {}

  @override
  Future<void> acceptPrivacy(String userId, int version) async {}
}

LegalController _createLegalController(SessionController sessionController) {
  final controller = LegalController(
    store: _FakeLegalAcceptanceStore(),
    sessionController: sessionController,
  );
  controller.load();
  return controller;
}
