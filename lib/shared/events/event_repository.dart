import 'dart:convert';
import 'package:http/http.dart' as http;
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
    this.groupIds = const [],
    this.tags = const [],
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
  final List<String> groupIds;
  final List<String> tags;
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
      if (groupIds.isNotEmpty) 'groupIds': groupIds,
      if (tags.isNotEmpty) 'tags': tags,
      'status': status.toJson(),
      if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
    };
  }
}

abstract class EventRepository {
  Future<List<ExploreEvent>> fetchMapEvents({
    required double latitude,
    required double longitude,
    double? radiusKm,
    int? limit,
    bool includeCommunityEvents = true,
    List<String>? groupIds,
    String? accessToken,
    String tokenType = 'Bearer',
  });
  Future<List<ExploreEvent>> fetchEvents({
    String? accessToken,
    String tokenType = 'Bearer',
  });
  Future<ExploreEvent> fetchEvent(String id);
  Future<List<ExploreEvent>> fetchOrganizerEvents({
    required String accessToken,
    String tokenType = 'Bearer',
  });
  Future<ExploreEvent> createEvent(
    EventRequest request, {
    required String accessToken,
    String tokenType = 'Bearer',
  });
  Future<ExploreEvent> updateEvent(
    String id,
    EventRequest request, {
    required String accessToken,
    String tokenType = 'Bearer',
  });
  Future<EventMedia> uploadEventMedia(
    String eventId,
    List<int> bytes,
    String fileName, {
    required String accessToken,
    String tokenType = 'Bearer',
  });
  Future<void> deleteEventMedia(
    String eventId,
    String mediaId, {
    required String accessToken,
    String tokenType = 'Bearer',
  });
  Future<void> setEventThumbnail(
    String eventId,
    String mediaId, {
    required String accessToken,
    String tokenType = 'Bearer',
  });
  Future<List<Category>> fetchCategories();
}

class HttpEventRepository implements EventRepository {
  HttpEventRepository({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = baseUrl ?? ApiConfig.baseUrl;

  final http.Client _client;
  final String _baseUrl;

  Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  Map<String, String> _authorizedHeaders(String accessToken, String tokenType) {
    return {
      'Authorization': '$tokenType $accessToken',
      'Content-Type': 'application/json',
    };
  }

  @override
  Future<List<ExploreEvent>> fetchOrganizerEvents({
    required String accessToken,
    String tokenType = 'Bearer',
  }) async {
    var page = 0;
    final events = <ExploreEvent>[];

    while (true) {
      final uri = _uri('/api/organizer/events/me').replace(
        queryParameters: {
          'page': page.toString(),
          'size': '50',
          'sort': 'startAt',
          'direction': 'desc',
        },
      );
      final response = await _client.get(
        uri,
        headers: {'Authorization': '$tokenType $accessToken'},
      );

      if (response.statusCode != 200) {
        throw EventRepositoryException(
          'Unable to fetch organizer events',
          statusCode: response.statusCode,
        );
      }

      final pageEvents = _decodePagedEvents(jsonDecode(response.body));
      events.addAll(pageEvents.events);
      if (pageEvents.isLast) {
        break;
      }
      page++;
    }

    return events;
  }

  @override
  Future<ExploreEvent> createEvent(
    EventRequest request, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) async {
    final response = await _client.post(
      _uri('/api/events'),
      headers: _authorizedHeaders(accessToken, tokenType),
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
  Future<ExploreEvent> updateEvent(
    String id,
    EventRequest request, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) async {
    final response = await _client.put(
      _uri('/api/events/$id'),
      headers: _authorizedHeaders(accessToken, tokenType),
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
  Future<List<ExploreEvent>> fetchMapEvents({
    required double latitude,
    required double longitude,
    double? radiusKm,
    int? limit,
    bool includeCommunityEvents = true,
    List<String>? groupIds,
    String? accessToken,
    String tokenType = 'Bearer',
  }) async {
    final queryParams = {
      'lat': latitude.toString(),
      'lng': longitude.toString(),
      if (radiusKm != null) 'radiusKm': radiusKm.toString(),
      if (limit != null) 'limit': limit.toString(),
      'includeCommunityEvents': includeCommunityEvents.toString(),
      if (groupIds != null && groupIds.isNotEmpty)
        'groupIds': groupIds.join(','),
    };

    final uri = _uri('/api/events/map').replace(queryParameters: queryParams);
    final response = await _client.get(
      uri,
      headers: accessToken != null
          ? {'Authorization': '$tokenType $accessToken'}
          : null,
    );

    if (response.statusCode != 200) {
      throw EventRepositoryException(
        'Unable to fetch map events',
        statusCode: response.statusCode,
      );
    }

    return _decodeEventsList(response.body);
  }

  @override
  Future<List<ExploreEvent>> fetchEvents({
    String? accessToken,
    String tokenType = 'Bearer',
  }) async {
    final response = await _client.get(
      _uri('/api/events'),
      headers: accessToken != null
          ? {'Authorization': '$tokenType $accessToken'}
          : null,
    );
    if (response.statusCode != 200) {
      throw EventRepositoryException(
        'Unable to fetch events',
        statusCode: response.statusCode,
      );
    }

    return _decodeEventsList(response.body);
  }

  @override
  Future<EventMedia> uploadEventMedia(
    String eventId,
    List<int> bytes,
    String fileName, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) async {
    final contentType = _resolveImageMimeType(fileName);

    final presigned = await _getPresignedUploadUrl(
      entityType: 'EVENT_MEDIA',
      entityId: eventId,
      fileName: fileName,
      contentType: contentType,
      fileSize: bytes.length,
      accessToken: accessToken,
      tokenType: tokenType,
    );

    final uploadResponse = await http.put(
      Uri.parse(presigned.uploadUrl),
      headers: {'Content-Type': contentType},
      body: bytes,
    );
    if (uploadResponse.statusCode != 200) {
      throw EventRepositoryException(
        'Unable to upload media to storage',
        statusCode: uploadResponse.statusCode,
      );
    }

    final confirmResponse = await _client.post(
      _uri('/api/events/$eventId/media'),
      headers: _authorizedHeaders(accessToken, tokenType),
      body: jsonEncode({
        'objectKey': presigned.objectKey,
        'contentType': contentType,
      }),
    );
    if (confirmResponse.statusCode != 201 &&
        confirmResponse.statusCode != 200) {
      throw EventRepositoryException(
        'Unable to confirm media upload',
        statusCode: confirmResponse.statusCode,
      );
    }

    final decoded = jsonDecode(confirmResponse.body);
    if (decoded is! Map<String, dynamic>) {
      throw const EventRepositoryException('Unexpected event media payload');
    }

    return EventMedia.fromJson(decoded);
  }

  Future<PresignedUploadResponse> _getPresignedUploadUrl({
    required String entityType,
    required String entityId,
    required String fileName,
    required String contentType,
    required int fileSize,
    required String accessToken,
    String tokenType = 'Bearer',
  }) async {
    final response = await _client.post(
      _uri('/api/media/presigned-upload-url'),
      headers: _authorizedHeaders(accessToken, tokenType),
      body: jsonEncode({
        'entityType': entityType,
        'entityId': entityId,
        'fileName': fileName,
        'contentType': contentType,
        'fileSize': fileSize,
      }),
    );
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw EventRepositoryException(
        'Unable to request upload URL',
        statusCode: response.statusCode,
      );
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const EventRepositoryException('Unexpected presigned URL payload');
    }
    return PresignedUploadResponse(
      uploadUrl: decoded['uploadUrl'] as String,
      objectKey: decoded['objectKey'] as String,
      publicUrl: decoded['publicUrl'] as String? ?? '',
      expiresAt: decoded['expiresAt'] as String?,
    );
  }

  String _resolveImageMimeType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    return switch (extension) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      'gif' => 'image/gif',
      'jpg' || 'jpeg' => 'image/jpeg',
      _ => 'image/jpeg',
    };
  }

  @override
  Future<void> deleteEventMedia(
    String eventId,
    String mediaId, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) async {
    final response = await _client.delete(
      _uri('/api/events/$eventId/media/$mediaId'),
      headers: {'Authorization': '$tokenType $accessToken'},
    );
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw EventRepositoryException(
        'Unable to delete media',
        statusCode: response.statusCode,
      );
    }
  }

  @override
  Future<void> setEventThumbnail(
    String eventId,
    String mediaId, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) async {
    final response = await _client.put(
      _uri('/api/events/$eventId/media/$mediaId/thumbnail'),
      headers: {'Authorization': '$tokenType $accessToken'},
    );
    if (response.statusCode != 204 && response.statusCode != 200) {
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
    } else if (decoded is Map &&
        decoded.containsKey('content') &&
        decoded['content'] is List) {
      content = decoded['content'] as List;
    } else {
      throw const EventRepositoryException('Unexpected events payload format');
    }

    final results = <ExploreEvent>[];
    for (final item in content) {
      if (item is! Map) continue;
      try {
        results.add(_eventFromJson(Map<String, dynamic>.from(item)));
      } catch (_) {
        continue;
      }
    }
    return results;
  }

  _PagedEvents _decodePagedEvents(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      final content = decoded['content'];
      if (content is List) {
        return _PagedEvents(
          events: content
              .whereType<Map>()
              .map((item) => _eventFromJson(Map<String, dynamic>.from(item)))
              .toList(growable: false),
          isLast: decoded['last'] as bool? ?? true,
        );
      }
    }

    if (decoded is List) {
      return _PagedEvents(
        events: decoded
            .whereType<Map>()
            .map((item) => _eventFromJson(Map<String, dynamic>.from(item)))
            .toList(growable: false),
        isLast: true,
      );
    }

    return const _PagedEvents(events: [], isLast: true);
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
    final latitude = (json['latitude'] as num?)?.toDouble();
    final longitude = (json['longitude'] as num?)?.toDouble();
    final fallbackLocationLabel = l10n.areaPinnedCoordinates(
      latitude?.toStringAsFixed(4) ?? '0.0000',
      longitude?.toStringAsFixed(4) ?? '0.0000',
    );

    return ExploreEvent.fromJson(
      json,
      fallbackTitle: l10n.eventDetailsUnknownEventTitle,
      fallbackVenue: fallbackLocationLabel,
    );
  }
}

class PresignedUploadResponse {
  const PresignedUploadResponse({
    required this.uploadUrl,
    required this.objectKey,
    this.publicUrl = '',
    this.expiresAt,
  });

  final String uploadUrl;
  final String objectKey;
  final String publicUrl;
  final String? expiresAt;
}

class _PagedEvents {
  const _PagedEvents({required this.events, required this.isLast});

  final List<ExploreEvent> events;
  final bool isLast;
}
