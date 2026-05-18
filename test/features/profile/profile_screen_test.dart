import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:locario/features/profile/profile_screen.dart';
import 'package:locario/shared/auth/auth_api.dart';
import 'package:locario/shared/auth/auth_models.dart';
import 'package:locario/shared/auth/auth_repository.dart';
import 'package:locario/shared/auth/auth_scope.dart';
import 'package:locario/shared/auth/session_controller.dart';

import '../../test_helpers/test_app.dart';

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

Future<SessionController> _createSessionController({
  bool authenticated = false,
  String role = 'user',
  bool load = true,
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

  if (load) {
    await controller.load();
  }
  return controller;
}

void main() {
  testWidgets('renders guest login card', (tester) async {
    final sessionController = await _createSessionController();

    await tester.pumpWidget(
      AuthScope(
        controller: sessionController,
        child: buildLocalizedTestApp(
          locale: const Locale('en'),
          home: const ProfileScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Go to the login screen'), findsOneWidget);
    expect(find.text('Inbox'), findsNothing);
  });

  testWidgets('renders logout chip for authenticated users', (tester) async {
    final sessionController = await _createSessionController(
      authenticated: true,
      role: 'organizer',
    );

    await tester.pumpWidget(
      AuthScope(
        controller: sessionController,
        child: buildLocalizedTestApp(
          locale: const Locale('en'),
          home: const ProfileScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView), const Offset(0, -900));
    await tester.pumpAndSettle();

    expect(find.text('Profile'), findsNothing);
    expect(find.text('Account, preferences and saved places.'), findsNothing);
    expect(find.text('Sign out'), findsOneWidget);
    expect(find.byIcon(Icons.logout_rounded), findsOneWidget);
    expect(find.text('Sign in'), findsNothing);
  });

  testWidgets('shows loading state while session is still loading', (
    tester,
  ) async {
    final sessionController = await _createSessionController(load: false);

    await tester.pumpWidget(
      AuthScope(
        controller: sessionController,
        child: buildLocalizedTestApp(
          locale: const Locale('en'),
          home: const ProfileScreen(),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(ListView), findsNothing);
    expect(find.text('Profile'), findsNothing);
    expect(find.text('Sign in'), findsNothing);
  });
}
