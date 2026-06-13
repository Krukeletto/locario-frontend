import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class NotificationsApiException implements Exception {
  const NotificationsApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'NotificationsApiException($statusCode): $message';
}

class NotificationsApi {
  NotificationsApi({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = baseUrl ?? ApiConfig.baseUrl;

  final http.Client _client;
  final String _baseUrl;

  static const _jsonHeaders = {'Content-Type': 'application/json'};

  Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  Map<String, String> _authHeaders(String token) => {
    'Authorization': 'Bearer $token',
  };

  Future<void> registerDevice({
    required String accessToken,
    required String fcmToken,
    required String platform,
  }) async {
    final response = await _client.post(
      _uri('/api/notifications/device'),
      headers: {..._jsonHeaders, ..._authHeaders(accessToken)},
      body: jsonEncode({'fcm_token': fcmToken, 'platform': platform}),
    );

    if (response.statusCode != 204) {
      throw NotificationsApiException(
        'Device registration failed',
        statusCode: response.statusCode,
      );
    }
  }

  Future<Map<String, dynamic>> fetchHistory({
    required String accessToken,
    int page = 0,
    int size = 20,
  }) async {
    final response = await _client.get(
      _uri('/api/notifications/history?page=$page&size=$size'),
      headers: {'Accept': 'application/json', ..._authHeaders(accessToken)},
    );

    if (response.statusCode != 200) {
      throw NotificationsApiException(
        'Fetch history failed',
        statusCode: response.statusCode,
      );
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<void> markAsRead({
    required String accessToken,
    required String notificationId,
  }) async {
    final response = await _client.patch(
      _uri('/api/notifications/history/$notificationId/read'),
      headers: _authHeaders(accessToken),
    );

    if (response.statusCode != 204) {
      throw NotificationsApiException(
        'Mark as read failed',
        statusCode: response.statusCode,
      );
    }
  }

  Future<void> markAllAsRead({required String accessToken}) async {
    final response = await _client.patch(
      _uri('/api/notifications/history/read-all'),
      headers: _authHeaders(accessToken),
    );

    if (response.statusCode != 204) {
      throw NotificationsApiException(
        'Mark all as read failed',
        statusCode: response.statusCode,
      );
    }
  }

  Future<void> deleteNotification({
    required String accessToken,
    required String notificationId,
  }) async {
    final response = await _client.delete(
      _uri('/api/notifications/history/$notificationId'),
      headers: _authHeaders(accessToken),
    );

    if (response.statusCode != 204) {
      throw NotificationsApiException(
        'Delete notification failed',
        statusCode: response.statusCode,
      );
    }
  }
}
