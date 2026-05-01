import 'package:flutter_test/flutter_test.dart';
import 'package:locario/shared/auth/auth_api.dart';
import 'package:locario/shared/auth/auth_models.dart';
import 'package:locario/shared/auth/auth_repository.dart';

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
  FakeAuthApi({
    this.onRegister,
    this.onLogin,
    this.onRefresh,
    this.onFetchProfile,
    this.onLogout,
  }) : super();

  final Future<AuthResponse> Function(RegisterRequest request)? onRegister;
  final Future<AuthResponse> Function(LoginRequest request)? onLogin;
  final Future<AuthResponse> Function(String refreshToken)? onRefresh;
  final Future<UserProfile> Function(String accessToken, String tokenType)?
  onFetchProfile;
  final Future<void> Function(String accessToken, String tokenType)? onLogout;

  @override
  Future<AuthResponse> register(RegisterRequest request) {
    if (onRegister != null) {
      return onRegister!(request);
    }
    throw StateError('register not configured');
  }

  @override
  Future<AuthResponse> login(LoginRequest request) {
    if (onLogin != null) {
      return onLogin!(request);
    }
    throw StateError('login not configured');
  }

  @override
  Future<AuthResponse> refresh(String refreshToken) {
    if (onRefresh != null) {
      return onRefresh!(refreshToken);
    }
    throw StateError('refresh not configured');
  }

  @override
  Future<UserProfile> fetchProfile({
    required String accessToken,
    String tokenType = 'Bearer',
  }) {
    if (onFetchProfile != null) {
      return onFetchProfile!(accessToken, tokenType);
    }
    throw StateError('fetchProfile not configured');
  }

  @override
  Future<void> logout({
    required String accessToken,
    String tokenType = 'Bearer',
  }) {
    if (onLogout != null) {
      return onLogout!(accessToken, tokenType);
    }
    throw StateError('logout not configured');
  }
}

AuthResponse _authResponse({
  String accessToken = 'access',
  String refreshToken = 'refresh',
  String tokenType = 'Bearer',
  int expiresIn = 3600,
  String userId = 'user-id',
  String username = 'user',
  String role = 'user',
}) {
  return AuthResponse(
    accessToken: accessToken,
    refreshToken: refreshToken,
    tokenType: tokenType,
    expiresIn: expiresIn,
    userId: userId,
    username: username,
    role: role,
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

void main() {
  test('login saves tokens', () async {
    final storage = MemoryAuthStorage();
    final now = DateTime.utc(2026, 5, 1, 12);
    final api = FakeAuthApi(
      onLogin: (request) async {
        expect(request.email, 'user@example.com');
        expect(request.password, 'password');
        return _authResponse();
      },
    );

    final repository = AuthRepository(
      api: api,
      storage: storage,
      now: () => now,
    );

    await repository.login(email: 'user@example.com', password: 'password');

    final stored = await storage.readTokens();
    expect(stored, isNotNull);
    expect(stored!.accessToken, 'access');
    expect(stored.refreshToken, 'refresh');
    expect(stored.expiresAt, now.add(const Duration(seconds: 3600)));
  });

  test('register saves tokens', () async {
    final storage = MemoryAuthStorage();
    final now = DateTime.utc(2026, 5, 1, 10);
    final api = FakeAuthApi(
      onRegister: (request) async {
        expect(request.email, 'new@example.com');
        expect(request.username, 'new_user');
        return _authResponse(accessToken: 'new-access');
      },
    );

    final repository = AuthRepository(
      api: api,
      storage: storage,
      now: () => now,
    );

    await repository.register(
      email: 'new@example.com',
      username: 'new_user',
      password: 'password',
    );

    final stored = await storage.readTokens();
    expect(stored, isNotNull);
    expect(stored!.accessToken, 'new-access');
  });

  test('refresh uses stored refresh token', () async {
    final storage = MemoryAuthStorage();
    storage.stored = AuthTokens(
      accessToken: 'old-access',
      refreshToken: 'old-refresh',
      tokenType: 'Bearer',
      expiresAt: DateTime.utc(2026, 5, 1, 9),
    );

    final api = FakeAuthApi(
      onRefresh: (refreshToken) async {
        expect(refreshToken, 'old-refresh');
        return _authResponse(accessToken: 'new-access');
      },
    );

    final repository = AuthRepository(api: api, storage: storage);

    final refreshed = await repository.refresh();

    expect(refreshed, isNotNull);
    expect(refreshed!.accessToken, 'new-access');
    final stored = await storage.readTokens();
    expect(stored!.accessToken, 'new-access');
  });

  test('fetchProfile throws when no tokens', () async {
    final storage = MemoryAuthStorage();
    final repository = AuthRepository(
      api: FakeAuthApi(onFetchProfile: (_, __) async => _profile()),
      storage: storage,
    );

    expect(repository.fetchProfile(), throwsA(isA<AuthRepositoryException>()));
  });

  test('logout clears storage and calls api', () async {
    final storage = MemoryAuthStorage();
    storage.stored = AuthTokens(
      accessToken: 'access',
      refreshToken: 'refresh',
      tokenType: 'Bearer',
      expiresAt: DateTime.utc(2026, 5, 1, 9),
    );

    var logoutCalled = false;
    final repository = AuthRepository(
      api: FakeAuthApi(
        onLogout: (accessToken, tokenType) async {
          expect(accessToken, 'access');
          expect(tokenType, 'Bearer');
          logoutCalled = true;
        },
      ),
      storage: storage,
    );

    await repository.logout();

    expect(logoutCalled, isTrue);
    expect(await storage.readTokens(), isNull);
  });
}
