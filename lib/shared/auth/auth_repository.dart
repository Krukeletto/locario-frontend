import 'auth_api.dart';
import 'auth_models.dart';

class AuthRepositoryException implements Exception {
  const AuthRepositoryException(this.message);

  final String message;

  @override
  String toString() => 'AuthRepositoryException: $message';
}

abstract class AuthTokenStorage {
  Future<void> saveTokens(AuthTokens tokens);
  Future<AuthTokens?> readTokens();
  Future<void> clear();
}

class AuthRepository {
  AuthRepository({
    required AuthApi api,
    required AuthTokenStorage storage,
    DateTime Function()? now,
  }) : _api = api,
       _storage = storage,
       _now = now ?? DateTime.now;

  final AuthApi _api;
  final AuthTokenStorage _storage;
  final DateTime Function() _now;

  Future<AuthTokens?> readTokens() => _storage.readTokens();

  Future<AuthResponse> register({
    required String email,
    required String username,
    required String password,
  }) async {
    final response = await _api.register(
      RegisterRequest(email: email, username: username, password: password),
    );
    await _storage.saveTokens(_tokensFromResponse(response));
    return response;
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _api.login(
      LoginRequest(email: email, password: password),
    );
    await _storage.saveTokens(_tokensFromResponse(response));
    return response;
  }

  Future<AuthResponse> loginWithGoogle({required String idToken}) async {
    final response = await _api.loginWithGoogle(idToken);
    await _storage.saveTokens(_tokensFromResponse(response));
    return response;
  }

  Future<AuthTokens?> refresh() async {
    final tokens = await _storage.readTokens();
    if (tokens == null) {
      return null;
    }

    final response = await _api.refresh(tokens.refreshToken);
    final refreshed = _tokensFromResponse(response);
    await _storage.saveTokens(refreshed);
    return refreshed;
  }

  Future<UserProfile> fetchProfile() async {
    final tokens = await _storage.readTokens();
    if (tokens == null) {
      throw const AuthRepositoryException('Missing tokens');
    }

    return _api.fetchProfile(
      accessToken: tokens.accessToken,
      tokenType: tokens.tokenType,
    );
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final tokens = await _storage.readTokens();
    if (tokens == null) {
      throw const AuthRepositoryException('Missing tokens');
    }

    await _api.changePassword(
      accessToken: tokens.accessToken,
      tokenType: tokens.tokenType,
      oldPassword: oldPassword,
      newPassword: newPassword,
    );
  }

  Future<void> logout() async {
    final tokens = await _storage.readTokens();
    if (tokens != null) {
      try {
        await _api.logout(
          accessToken: tokens.accessToken,
          tokenType: tokens.tokenType,
        );
      } on AuthApiException {
        // Ignore logout failures and clear local session anyway.
      }
    }

    await _storage.clear();
  }

  Future<void> clear() => _storage.clear();

  AuthTokens _tokensFromResponse(AuthResponse response) {
    final expiresAt = _now().add(Duration(seconds: response.expiresIn));
    return AuthTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
      tokenType: response.tokenType,
      expiresAt: expiresAt,
    );
  }
}
