import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class FavoritesApiException implements Exception {
  const FavoritesApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'FavoritesApiException($statusCode): $message';
}

class FavoritesApi {
  FavoritesApi({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = baseUrl ?? ApiConfig.baseUrl;

  final http.Client _client;
  final String _baseUrl;

  Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  Future<void> addFavorite(
    String eventId,
    String accessToken, {
    String tokenType = 'Bearer',
  }) async {
    final response = await _client.post(
      _uri('/api/profile/favorites/$eventId'),
      headers: {'Authorization': '$tokenType $accessToken'},
    );

    if (response.statusCode != 200) {
      throw FavoritesApiException(
        'Failed to add favorite',
        statusCode: response.statusCode,
      );
    }
  }

  Future<void> removeFavorite(
    String eventId,
    String accessToken, {
    String tokenType = 'Bearer',
  }) async {
    final response = await _client.delete(
      _uri('/api/profile/favorites/$eventId'),
      headers: {'Authorization': '$tokenType $accessToken'},
    );

    if (response.statusCode != 200) {
      throw FavoritesApiException(
        'Failed to remove favorite',
        statusCode: response.statusCode,
      );
    }
  }
}
