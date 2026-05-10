import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:locario/features/profile/profile_screen.dart';
import 'package:locario/shared/auth/auth_api.dart';
import 'package:locario/shared/auth/auth_models.dart';
import 'package:locario/shared/auth/auth_repository.dart';
import 'package:locario/shared/auth/auth_scope.dart';
import 'package:locario/shared/auth/session_controller.dart';
import 'package:locario/shared/services/feedback_service.dart';

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
  _FakeAuthApi() : super();

  @override
  Future<AuthResponse> login(LoginRequest request) {
    throw StateError('login not configured');
  }

  @override
  Future<UserProfile> fetchProfile({
    required String accessToken,
    String tokenType = 'Bearer',
  }) {
    throw StateError('fetchProfile not configured');
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

Future<SessionController> _createSessionController() async {
  final controller = SessionController(
    authRepository: AuthRepository(
      api: _FakeAuthApi(),
      storage: _MemoryAuthStorage(),
    ),
  );

  await controller.load();
  return controller;
}

void main() {
  testWidgets('shows coming soon toast for disabled inbox card', (
    tester,
  ) async {
    FeedbackService.resetForTests();

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

    final inboxCard = find.ancestor(
      of: find.text('Inbox'),
      matching: find.byType(InkWell),
    );
    await tester.ensureVisible(inboxCard);
    await tester.tap(inboxCard);
    await tester.pumpAndSettle();

    expect(find.text('This section is still being built.'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Open your notifications'), findsOneWidget);
  });
}
