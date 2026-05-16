import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import '../config/api_config.dart';
import 'auth_models.dart';

class AuthApiException implements Exception {
  const AuthApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'AuthApiException($statusCode): $message';
}

class AuthApi {
  AuthApi({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = baseUrl ?? ApiConfig.baseUrl;

  final http.Client _client;
  final String _baseUrl;

  static const _jsonHeaders = {'Content-Type': 'application/json'};

  Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  Future<AuthResponse> register(RegisterRequest request) async {
    final response = await _client.post(
      _uri('/api/auth/register'),
      headers: _jsonHeaders,
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      debugPrint(
        'Auth: register failed (${response.statusCode}) ${response.body}',
      );
      throw AuthApiException(
        'Register failed',
        statusCode: response.statusCode,
      );
    }

    return _decodeAuthResponse(response.body);
  }

  Future<AuthResponse> login(LoginRequest request) async {
    final response = await _client.post(
      _uri('/api/auth/login'),
      headers: _jsonHeaders,
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 200) {
      debugPrint(
        'Auth: login failed (${response.statusCode}) ${response.body}',
      );
      throw AuthApiException('Login failed', statusCode: response.statusCode);
    }

    return _decodeAuthResponse(response.body);
  }

  Future<AuthResponse> refresh(String refreshToken) async {
    final response = await _client.post(
      _uri('/api/auth/refresh'),
      headers: _jsonHeaders,
      body: jsonEncode(
        RefreshTokenRequest(refreshToken: refreshToken).toJson(),
      ),
    );

    if (response.statusCode != 200) {
      debugPrint(
        'Auth: refresh failed (${response.statusCode}) ${response.body}',
      );
      throw AuthApiException('Refresh failed', statusCode: response.statusCode);
    }

    return _decodeAuthResponse(response.body);
  }

  Future<AuthResponse> loginWithGoogle(String idToken) async {
    final response = await _client.post(
      _uri('/api/auth/oauth2/google'),
      headers: _jsonHeaders,
      body: jsonEncode(GoogleOAuthRequest(idToken: idToken).toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      debugPrint(
        'Auth: google login failed (${response.statusCode}) ${response.body}',
      );
      throw AuthApiException(
        'Google login failed',
        statusCode: response.statusCode,
      );
    }

    return _decodeAuthResponse(response.body);
  }

  Future<void> logout({
    required String accessToken,
    String tokenType = 'Bearer',
  }) async {
    final response = await _client.post(
      _uri('/api/auth/logout'),
      headers: {'Authorization': '$tokenType $accessToken'},
    );

    if (response.statusCode != 200) {
      debugPrint(
        'Auth: logout failed (${response.statusCode}) ${response.body}',
      );
      throw AuthApiException('Logout failed', statusCode: response.statusCode);
    }
  }

  Future<UserProfile> fetchProfile({
    required String accessToken,
    String tokenType = 'Bearer',
  }) async {
    final response = await _client.get(
      _uri('/api/profile/details'),
      headers: {'Authorization': '$tokenType $accessToken'},
    );

    if (response.statusCode != 200) {
      debugPrint(
        'Auth: profile failed (${response.statusCode}) ${response.body}',
      );
      throw AuthApiException(
        'Fetch profile failed',
        statusCode: response.statusCode,
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const AuthApiException('Unexpected profile payload');
    }

    return UserProfile.fromJson(decoded);
  }

  Future<void> changePassword({
    required String accessToken,
    required String oldPassword,
    required String newPassword,
    String tokenType = 'Bearer',
  }) async {
    final response = await _client.put(
      _uri('/api/profile/change-password'),
      headers: {..._jsonHeaders, 'Authorization': '$tokenType $accessToken'},
      body: jsonEncode(
        ChangePasswordRequest(
          oldPassword: oldPassword,
          newPassword: newPassword,
        ).toJson(),
      ),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      debugPrint(
        'Auth: change password failed (${response.statusCode}) ${response.body}',
      );
      throw AuthApiException(
        'Change password failed',
        statusCode: response.statusCode,
      );
    }
  }

  AuthResponse _decodeAuthResponse(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw const AuthApiException('Unexpected auth response');
    }
    return AuthResponse.fromJson(decoded);
  }
}
