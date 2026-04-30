import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../shared/auth/auth_models.dart';
import '../../shared/auth/auth_repository.dart';

class AuthStorage implements AuthTokenStorage {
  const AuthStorage({FlutterSecureStorage? secureStorage})
    : _storage = secureStorage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _accessTokenKey = 'auth.accessToken';
  static const _refreshTokenKey = 'auth.refreshToken';
  static const _tokenTypeKey = 'auth.tokenType';
  static const _expiresAtKey = 'auth.expiresAt';

  @override
  Future<void> saveTokens(AuthTokens tokens) async {
    await _storage.write(key: _accessTokenKey, value: tokens.accessToken);
    await _storage.write(key: _refreshTokenKey, value: tokens.refreshToken);
    await _storage.write(key: _tokenTypeKey, value: tokens.tokenType);
    await _storage.write(
      key: _expiresAtKey,
      value: tokens.expiresAt.toUtc().toIso8601String(),
    );
  }

  @override
  Future<AuthTokens?> readTokens() async {
    final accessToken = await _storage.read(key: _accessTokenKey);
    final refreshToken = await _storage.read(key: _refreshTokenKey);
    final tokenType = await _storage.read(key: _tokenTypeKey);
    final expiresAtRaw = await _storage.read(key: _expiresAtKey);

    if (accessToken == null ||
        refreshToken == null ||
        tokenType == null ||
        expiresAtRaw == null) {
      return null;
    }

    final expiresAt =
        DateTime.tryParse(expiresAtRaw) ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

    return AuthTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      tokenType: tokenType,
      expiresAt: expiresAt,
    );
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _tokenTypeKey);
    await _storage.delete(key: _expiresAtKey);
  }
}
