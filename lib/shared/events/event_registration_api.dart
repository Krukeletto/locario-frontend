import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'event_slots_response.dart';

class EventRegistrationApiException implements Exception {
  const EventRegistrationApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'EventRegistrationApiException($statusCode): $message';
}

class EventRegistrationApi {
  EventRegistrationApi({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = baseUrl ?? ApiConfig.baseUrl;

  final http.Client _client;
  final String _baseUrl;

  Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  Future<void> joinEvent(
    String eventId,
    String accessToken, {
    String tokenType = 'Bearer',
  }) async {
    final response = await _client.post(
      _uri('/api/events/$eventId/join'),
      headers: {'Authorization': '$tokenType $accessToken'},
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw EventRegistrationApiException(
        'Failed to join event',
        statusCode: response.statusCode,
      );
    }
  }

  Future<void> cancelRegistration(
    String eventId,
    String accessToken, {
    String tokenType = 'Bearer',
  }) async {
    final response = await _client.post(
      _uri('/api/events/$eventId/cancel'),
      headers: {'Authorization': '$tokenType $accessToken'},
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw EventRegistrationApiException(
        'Failed to cancel registration',
        statusCode: response.statusCode,
      );
    }
  }

  Future<EventSlotsResponse> fetchSlots(String eventId) async {
    final response = await _client.get(_uri('/api/events/$eventId/slots'));

    if (response.statusCode != 200) {
      throw EventRegistrationApiException(
        'Failed to fetch slots',
        statusCode: response.statusCode,
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map) {
      throw const EventRegistrationApiException('Unexpected slots payload');
    }

    return EventSlotsResponse.fromJson(Map<String, dynamic>.from(decoded));
  }
}
