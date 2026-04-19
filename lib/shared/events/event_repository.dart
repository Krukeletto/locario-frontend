import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart' show LatLng;
import '../../features/explore/models.dart';
import '../config/api_config.dart';
import '../services/l10n_service.dart';

class EventRepositoryException implements Exception {
  const EventRepositoryException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'EventRepositoryException($statusCode): $message';
}

class EventRequest {
  const EventRequest({
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.startAt,
    this.endAt,
    this.recurring = false,
    this.recurrenceRule,
    this.slotLimit,
    this.ticketUrl,
    this.categoryIds = const [],
    this.status = EventStatus.published,
    this.thumbnailUrl,
  });

  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final String address;
  final DateTime startAt;
  final DateTime? endAt;
  final bool recurring;
  final String? recurrenceRule;
  final int? slotLimit;
  final String? ticketUrl;
  final List<String> categoryIds;
  final EventStatus status;
  final String? thumbnailUrl;

  Map<String, Object?> toJson() {
    return {
      'name': name,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'startAt': startAt.toUtc().toIso8601String(),
      if (endAt != null) 'endAt': endAt!.toUtc().toIso8601String(),
      'recurring': recurring,
      if (recurrenceRule != null) 'recurrenceRule': recurrenceRule,
      if (slotLimit != null) 'slotLimit': slotLimit,
      if (ticketUrl != null) 'ticketUrl': ticketUrl,
      'categoryIds': categoryIds,
      'status': status.toJson(),
      if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
    };
  }
}

abstract class EventRepository {
  Future<List<ExploreEvent>> fetchNearbyEvents({
    required double latitude,
    required double longitude,
    double? radiusKm,
    int? limit,
  });
  Future<List<ExploreEvent>> fetchEvents();
  Future<ExploreEvent> fetchEvent(String id);
  Future<ExploreEvent> createEvent(EventRequest request);
  Future<ExploreEvent> updateEvent(String id, EventRequest request);
  Future<void> uploadEventMedia(String eventId, List<int> bytes, String fileName);
  Future<void> deleteEventMedia(String eventId, String mediaId);
  Future<void> setEventThumbnail(String eventId, String mediaId);
  Future<List<Category>> fetchCategories();
}

class HttpEventRepository implements EventRepository {
  HttpEventRepository({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = baseUrl ?? ApiConfig.baseUrl;

  final http.Client _client;
  final String _baseUrl;

  Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  @override
  Future<ExploreEvent> createEvent(EventRequest request) async {
    final response = await _client.post(
      _uri('/api/events'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw EventRepositoryException(
        'Unable to create event',
        statusCode: response.statusCode,
      );
    }

    return _decodeEventResponse(response.body);
  }

  @override
  Future<ExploreEvent> updateEvent(String id, EventRequest request) async {
    final response = await _client.put(
      _uri('/api/events/$id'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 200) {
      throw EventRepositoryException(
        'Unable to update event',
        statusCode: response.statusCode,
      );
    }

    return _decodeEventResponse(response.body);
  }

  @override
  Future<ExploreEvent> fetchEvent(String id) async {
    final response = await _client.get(_uri('/api/events/$id'));
    if (response.statusCode != 200) {
      throw EventRepositoryException(
        'Unable to fetch event',
        statusCode: response.statusCode,
      );
    }

    return _decodeEventResponse(response.body);
  }

  @override
  Future<List<ExploreEvent>> fetchNearbyEvents({
    required double latitude,
    required double longitude,
    double? radiusKm,
    int? limit,
  }) async {
    final queryParams = {
      'lat': latitude.toString(),
      'lng': longitude.toString(),
      if (radiusKm != null) 'radiusKm': radiusKm.toString(),
      if (limit != null) 'limit': limit.toString(),
    };
    
    final uri = _uri('/api/events/nearby').replace(queryParameters: queryParams);
    final response = await _client.get(uri);
    
    if (response.statusCode != 200) {
      throw EventRepositoryException(
        'Unable to fetch nearby events',
        statusCode: response.statusCode,
      );
    }

    return _decodeEventsList(response.body);
  }

  @override
  Future<List<ExploreEvent>> fetchEvents() async {
    final response = await _client.get(_uri('/api/events'));
    if (response.statusCode != 200) {
      throw EventRepositoryException(
        'Unable to fetch events',
        statusCode: response.statusCode,
      );
    }

    return _decodeEventsList(response.body);
  }

  @override
  Future<void> uploadEventMedia(String eventId, List<int> bytes, String fileName) async {
    final request = http.MultipartRequest('POST', _uri('/api/events/$eventId/media'));
    request.files.add(http.MultipartFile.fromBytes(
      'file',
      bytes,
      filename: fileName,
    ));

    final streamedResponse = await _client.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw EventRepositoryException(
        'Unable to upload media',
        statusCode: response.statusCode,
      );
    }
  }

  @override
  Future<void> deleteEventMedia(String eventId, String mediaId) async {
    final response = await _client.delete(_uri('/api/events/$eventId/media/$mediaId'));
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw EventRepositoryException(
        'Unable to delete media',
        statusCode: response.statusCode,
      );
    }
  }

  @override
  Future<void> setEventThumbnail(String eventId, String mediaId) async {
    final response = await _client.patch(
      _uri('/api/events/$eventId/thumbnail'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'mediaId': mediaId}),
    );
    if (response.statusCode != 200) {
      throw EventRepositoryException(
        'Unable to set thumbnail',
        statusCode: response.statusCode,
      );
    }
  }

  @override
  Future<List<Category>> fetchCategories() async {
    final response = await _client.get(_uri('/api/categories'));
    if (response.statusCode != 200) {
      throw EventRepositoryException(
        'Unable to fetch categories',
        statusCode: response.statusCode,
      );
    }

    final decoded = jsonDecode(response.body);
    final List list;
    if (decoded is List) {
      list = decoded;
    } else if (decoded is Map && decoded['content'] is List) {
      list = decoded['content'] as List;
    } else {
      return const [];
    }

    return list
        .whereType<Map>()
        .map((item) => Category.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  List<ExploreEvent> _decodeEventsList(String responseBody) {
    final decoded = jsonDecode(responseBody);
    final List content;
    
    if (decoded is List) {
      content = decoded;
    } else if (decoded is Map && decoded.containsKey('content') && decoded['content'] is List) {
      content = decoded['content'] as List;
    } else {
      throw const EventRepositoryException('Unexpected events payload format');
    }

    return content
        .whereType<Map>()
        .map((item) => _eventFromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  ExploreEvent _decodeEventResponse(String responseBody) {
    final decoded = jsonDecode(responseBody);
    if (decoded is! Map) {
      throw const EventRepositoryException('Unexpected event payload');
    }

    return _eventFromJson(Map<String, dynamic>.from(decoded));
  }

  ExploreEvent _eventFromJson(Map<String, dynamic> json) {
    final l10n = L10nService.l10n;
    final title = (json['name'] as String?)?.trim() ?? (json['title'] as String?)?.trim();
    final address = (json['address'] as String?)?.trim();
    final description = (json['description'] as String?)?.trim();
    
    final categoryList = json['categories'] as List?;
    final categories = categoryList
            ?.whereType<Map<String, dynamic>>()
            .map((c) => Category.fromJson(c))
            .toList() ??
        [];

    final mediaList = json['media'] as List?;
    final media = mediaList
            ?.whereType<Map<String, dynamic>>()
            .map((m) => EventMedia.fromJson(m))
            .toList() ??
        [];

    final startsAtRaw = (json['startAt'] as String?) ?? (json['startDate'] as String?);
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
      categories: categories,
      media: media,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      startsAt: DateTime.tryParse(startsAtRaw ?? '') ?? DateTime.now().toUtc(),
      endsAt: (json['endAt'] != null) 
          ? DateTime.tryParse(json['endAt'] as String) 
          : (json['endDate'] != null ? DateTime.tryParse(json['endDate'] as String) : null),
      trendingScore: json['trendingScore'] as int? ?? 0,
      venue: address == null || address.isEmpty
          ? fallbackLocationLabel
          : address,
      location: eventLocation,
      minAge: json['minAge'] as int?,
      maxAge: json['maxAge'] as int?,
      eventType: json['eventType'] as String?,
      eventSource: json['eventSource'] as String?,
      description: description,
      address: address,
      status: EventStatus.fromString(json['status'] as String?),
      slotLimit: json['slotLimit'] as int?,
      ticketUrl: json['ticketUrl'] as String?,
      organizers: (json['organizers'] as List?)?.cast<String>() ?? const [],
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'] as String) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'] as String) : null,
    );
  }
}
