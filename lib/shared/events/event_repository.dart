import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:locario/l10n/app_localizations.dart';

import '../../features/explore/models.dart';
import '../config/api_config.dart';

class EventRepositoryException implements Exception {
  const EventRepositoryException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'EventRepositoryException($statusCode): $message';
}

class CreateEventInput {
  const CreateEventInput({
    required this.title,
    required this.description,
    required this.location,
    required this.startDate,
    required this.address,
    this.categoryId,
  });

  final String title;
  final String description;
  final LatLng location;
  final DateTime startDate;
  final String? address;
  final String? categoryId;

  Map<String, Object?> toJson() {
    return {
      'title': title,
      'description': description,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'address': address,
      'startDate': startDate.toUtc().toIso8601String(),
      if (categoryId != null) 'categoryId': categoryId,
    };
  }
}

abstract class EventRepository {
  Future<List<ExploreEvent>> fetchEvents(AppLocalizations l10n);
  Future<ExploreEvent> fetchEvent(String id, AppLocalizations l10n);
  Future<ExploreEvent> createEvent(
    CreateEventInput input,
    AppLocalizations l10n,
  );
}

class HttpEventRepository implements EventRepository {
  HttpEventRepository({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = baseUrl ?? ApiConfig.baseUrl;

  final http.Client _client;
  final String _baseUrl;

  Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  @override
  Future<ExploreEvent> createEvent(
    CreateEventInput input,
    AppLocalizations l10n,
  ) async {
    final response = await _client.post(
      _uri('/api/events'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(input.toJson()),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw EventRepositoryException(
        'Unable to create event',
        statusCode: response.statusCode,
      );
    }

    return _decodeEventResponse(response.body, l10n);
  }

  @override
  Future<ExploreEvent> fetchEvent(String id, AppLocalizations l10n) async {
    final response = await _client.get(_uri('/api/events/$id'));
    if (response.statusCode != 200) {
      throw EventRepositoryException(
        'Unable to fetch event',
        statusCode: response.statusCode,
      );
    }

    return _decodeEventResponse(response.body, l10n);
  }

  @override
  Future<List<ExploreEvent>> fetchEvents(AppLocalizations l10n) async {
    final response = await _client.get(_uri('/api/events'));
    if (response.statusCode != 200) {
      throw EventRepositoryException(
        'Unable to fetch events',
        statusCode: response.statusCode,
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw const EventRepositoryException('Unexpected events payload');
    }

    return decoded
        .whereType<Map>()
        .map((item) => _eventFromJson(Map<String, dynamic>.from(item), l10n))
        .toList(growable: false);
  }

  ExploreEvent _decodeEventResponse(
    String responseBody,
    AppLocalizations l10n,
  ) {
    final decoded = jsonDecode(responseBody);
    if (decoded is! Map) {
      throw const EventRepositoryException('Unexpected event payload');
    }

    return _eventFromJson(Map<String, dynamic>.from(decoded), l10n);
  }

  ExploreEvent _eventFromJson(
    Map<String, dynamic> json,
    AppLocalizations l10n,
  ) {
    final title = (json['title'] as String?)?.trim();
    final address = (json['address'] as String?)?.trim();
    final description = (json['description'] as String?)?.trim();
    final categoryName = (json['categoryName'] as String?)?.trim();
    final categoryId = (json['categoryId'] as String?)?.trim();
    final startsAtRaw = json['startDate'] as String?;
    final latitude = (json['latitude'] as num?)?.toDouble();
    final longitude = (json['longitude'] as num?)?.toDouble();
    final eventLocation = LatLng(latitude ?? 0, longitude ?? 0);
    final fallbackLocationLabel = l10n.areaPinnedCoordinates(
      eventLocation.latitude.toStringAsFixed(4),
      eventLocation.longitude.toStringAsFixed(4),
    );

    return ExploreEvent(
      id: (json['id'] as String?)?.trim() ?? '',
      title: title == null || title.isEmpty
          ? l10n.eventDetailsUnknownEventTitle
          : title,
      category: exploreCategoryFromBackend(
        categoryId: categoryId,
        categoryName: categoryName,
      ),
      startsAt: DateTime.tryParse(startsAtRaw ?? '') ?? DateTime.now().toUtc(),
      trendingScore: 0,
      venue: address == null || address.isEmpty
          ? fallbackLocationLabel
          : address,
      location: eventLocation,
      description: description,
      address: address,
      categoryId: categoryId,
      categoryName: categoryName,
    );
  }
}
