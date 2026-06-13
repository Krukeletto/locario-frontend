import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:locario/features/profile/profile_screen.dart';
import 'package:locario/shared/auth/auth_api.dart';
import 'package:locario/shared/auth/auth_models.dart';
import 'package:locario/shared/auth/auth_repository.dart';
import 'package:locario/shared/auth/auth_scope.dart';
import 'package:locario/shared/auth/session_controller.dart';
import 'package:locario/shared/cache/cache_service.dart';
import 'package:locario/shared/reviews/review_controller.dart';
import 'package:locario/shared/reviews/review_repository.dart';
import 'package:locario/shared/reviews/review_scope.dart';

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

class _StubSessionController extends SessionController {
  _StubSessionController()
    : super(
        authRepository: AuthRepository(
          api: AuthApi(client: http.Client(), baseUrl: 'http://localhost'),
          storage: _MemoryAuthStorage(),
        ),
      );

  @override
  bool get isAuthenticated => false;

  @override
  AuthTokens? get tokens => null;
}

class _InMemoryCacheService extends CacheService {
  final Map<String, String> _store = {};

  @override
  Future<void> init() async {}

  @override
  Future<String?> getRaw(String key) async => _store[key];

  @override
  Future<void> setRaw(String key, String data, {int? hash}) async {
    _store[key] = data;
  }

  @override
  Future<int?> getHash(String key) async {
    final data = _store[key];
    if (data == null) return null;
    return data.hashCode;
  }

  @override
  Future<void> invalidate(String key) async {
    _store.remove(key);
  }

  @override
  Future<void> invalidateByPrefix(String prefix) async {
    _store.removeWhere((key, _) => key.startsWith(prefix));
  }

  @override
  Future<void> clear() async {
    _store.clear();
  }

  @override
  Future<void> dispose() async {}
}

Widget _buildTestApp(Widget child) {
  return ReviewScope(controller: _reviewController, child: child);
}

final _reviewController = ReviewController(
  reviewRepository: HttpReviewRepository(),
  cacheService: _InMemoryCacheService(),
  sessionController: _StubSessionController(),
);

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
          home: _buildTestApp(const ProfileScreen()),
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
          home: _buildTestApp(const ProfileScreen()),
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
          home: _buildTestApp(const ProfileScreen()),
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
