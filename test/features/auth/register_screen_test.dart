import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:locario/app/router.dart';
import 'package:locario/features/auth/login_screen.dart';
import 'package:locario/features/auth/register_screen.dart';
import 'package:locario/features/profile/profile_screen.dart';
import 'package:locario/l10n/app_localizations.dart';
import 'package:locario/shared/auth/auth_api.dart';
import 'package:locario/shared/auth/auth_models.dart';
import 'package:locario/shared/auth/auth_repository.dart';
import 'package:locario/shared/auth/auth_scope.dart';
import 'package:locario/shared/auth/session_controller.dart';
import 'package:locario/shared/services/feedback_service.dart';
import 'package:locario/shared/services/l10n_service.dart';

import '../../test_helpers/test_app.dart';

class MemoryAuthStorage implements AuthTokenStorage {
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

class FakeAuthApi extends AuthApi {
  FakeAuthApi({required this.onRegister, required this.onFetchProfile})
    : super();

  final Future<AuthResponse> Function(RegisterRequest request) onRegister;
  final Future<UserProfile> Function(String accessToken, String tokenType)
  onFetchProfile;

  @override
  Future<AuthResponse> login(LoginRequest request) {
    throw StateError('login not configured');
  }

  @override
  Future<UserProfile> fetchProfile({
    required String accessToken,
    String tokenType = 'Bearer',
  }) {
    return onFetchProfile(accessToken, tokenType);
  }

  @override
  Future<AuthResponse> register(RegisterRequest request) {
    return onRegister(request);
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

AuthResponse _authResponse({
  String accessToken = 'access',
  String refreshToken = 'refresh',
  String tokenType = 'Bearer',
  int expiresIn = 3600,
}) {
  return AuthResponse(
    accessToken: accessToken,
    refreshToken: refreshToken,
    tokenType: tokenType,
    expiresIn: expiresIn,
    userId: 'user-id',
    username: 'user',
    role: 'user',
  );
}

UserProfile _profile() {
  return UserProfile(
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
  );
}

Future<SessionController> _createSessionController() async {
  final storage = MemoryAuthStorage();
  final controller = SessionController(
    authRepository: AuthRepository(
      api: FakeAuthApi(
        onRegister: (request) async {
          expect(request.email, 'user@example.com');
          expect(request.username, 'uzytkownik_01');
          expect(request.password, 'password123');
          return _authResponse();
        },
        onFetchProfile: (_, _) async => _profile(),
      ),
      storage: storage,
      now: () => DateTime.utc(2026, 5, 1, 12),
    ),
  );

  await controller.load();
  return controller;
}

Future<GoRouter> _pumpRouterApp(
  WidgetTester tester, {
  required SessionController sessionController,
}) async {
  final router = createAppRouter(sessionController);

  await tester.pumpWidget(
    AuthScope(
      controller: sessionController,
      child: MaterialApp.router(
        scaffoldMessengerKey: rootScaffoldMessengerKey,
        locale: const Locale('pl'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        routerConfig: router,
        builder: (context, child) {
          final l10n = AppLocalizations.of(context);
          L10nService.init(l10n);
          return child!;
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
  return router;
}

Future<void> _pumpRegisterScreen(
  WidgetTester tester, {
  Locale locale = const Locale('pl'),
}) async {
  await tester.pumpWidget(
    buildLocalizedTestApp(locale: locale, home: const RegisterScreen()),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('RegisterScreen', () {
    testWidgets('shows validation errors for empty submit', (tester) async {
      await _pumpRegisterScreen(tester);

      final submitButton = find.text('Zarejestruj się');
      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(find.text('Podaj nazwę użytkownika'), findsOneWidget);
      expect(find.text('Podaj adres e-mail'), findsOneWidget);
      expect(find.text('Podaj hasło'), findsOneWidget);
    });

    testWidgets('shows validation errors for invalid values', (tester) async {
      await _pumpRegisterScreen(tester);

      await tester.enterText(find.byType(TextField).at(0), 'zly login');
      await tester.enterText(find.byType(TextField).at(1), 'zly-email');
      await tester.enterText(find.byType(TextField).at(2), '123');
      final submitButton = find.text('Zarejestruj się');
      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(find.text('Dozwolone: litery, cyfry, . _ -'), findsOneWidget);
      expect(find.text('Podaj poprawny adres e-mail'), findsOneWidget);
      expect(find.text('Hasło musi mieć min. 8 znaków'), findsOneWidget);
    });

    testWidgets('accepts valid values without validation errors', (
      tester,
    ) async {
      await _pumpRegisterScreen(tester);

      await tester.enterText(find.byType(TextField).at(0), 'uzytkownik_01');
      await tester.enterText(find.byType(TextField).at(1), 'user@example.com');
      await tester.enterText(find.byType(TextField).at(2), 'stringst');
      final submitButton = find.text('Zarejestruj się');
      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(find.text('Podaj nazwę użytkownika'), findsNothing);
      expect(find.text('Podaj poprawny adres e-mail'), findsNothing);
      expect(find.text('Hasło musi mieć min. 8 znaków'), findsNothing);
    });

    testWidgets('returns to login screen from footer action', (tester) async {
      final sessionController = await _createSessionController();
      final router = await _pumpRouterApp(
        tester,
        sessionController: sessionController,
      );

      router.go('/auth/login?from=/profile&target=/profile');
      await tester.pumpAndSettle();

      final registerAction = find.text('Utwórz darmowe konto');
      await tester.ensureVisible(registerAction);
      await tester.tap(registerAction);
      await tester.pumpAndSettle();

      expect(find.byType(RegisterScreen), findsOneWidget);

      final loginAction = find.text('Zaloguj się na konto');
      await tester.ensureVisible(loginAction);
      await tester.tap(loginAction);
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('returns to target after successful registration', (
      tester,
    ) async {
      final sessionController = await _createSessionController();
      final router = await _pumpRouterApp(
        tester,
        sessionController: sessionController,
      );

      router.go('/auth/register?from=/profile&target=/profile');
      await tester.pumpAndSettle();

      final submitButton = find.text('Zarejestruj się');
      await tester.ensureVisible(submitButton);
      await tester.enterText(find.byType(TextField).at(0), 'uzytkownik_01');
      await tester.enterText(find.byType(TextField).at(1), 'user@example.com');
      await tester.enterText(find.byType(TextField).at(2), 'password123');
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(find.byType(ProfileScreen), findsOneWidget);
    });
  });
}
