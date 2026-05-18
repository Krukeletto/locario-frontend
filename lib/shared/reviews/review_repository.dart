import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../features/explore/models.dart';
import '../config/api_config.dart';
import '../services/l10n_service.dart';
import 'review_models.dart';

class ReviewRepositoryException implements Exception {
  const ReviewRepositoryException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'ReviewRepositoryException($statusCode): $message';
}

abstract class ReviewRepository {
  Future<AverageRating> fetchOrganizerAverageRating(
    String organizerId, {
    String? accessToken,
    String tokenType = 'Bearer',
  });

  Future<List<ReviewResponse>> fetchEventReviews(
    String eventId, {
    String? accessToken,
    String tokenType = 'Bearer',
  });

  Future<ReviewResponse?> fetchMyReviewForEvent(
    String eventId, {
    required String accessToken,
    String tokenType = 'Bearer',
  });

  Future<ReviewResponse> submitEventReview(
    String eventId,
    ReviewRequest request, {
    required String accessToken,
    String tokenType = 'Bearer',
  });

  Future<OrganizerReviewsOverview> fetchMyOrganizerReviews({
    required String organizerId,
    required String accessToken,
    String tokenType = 'Bearer',
  });
}

class HttpReviewRepository implements ReviewRepository {
  HttpReviewRepository({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = baseUrl ?? ApiConfig.baseUrl;

  final http.Client _client;
  final String _baseUrl;

  static const _jsonHeaders = {'Content-Type': 'application/json'};

  Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  Map<String, String> _headers({
    String? accessToken,
    String tokenType = 'Bearer',
  }) {
    if (accessToken == null || accessToken.isEmpty) {
      return _jsonHeaders;
    }
    return {..._jsonHeaders, 'Authorization': '$tokenType $accessToken'};
  }

  @override
  Future<AverageRating> fetchOrganizerAverageRating(
    String organizerId, {
    String? accessToken,
    String tokenType = 'Bearer',
  }) async {
    final response = await _client.get(
      _uri('/api/reviews/organizers/$organizerId/average-rating'),
      headers: _headers(accessToken: accessToken, tokenType: tokenType),
    );

    if (response.statusCode != 200) {
      throw ReviewRepositoryException(
        'Unable to fetch organizer average rating',
        statusCode: response.statusCode,
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const ReviewRepositoryException(
        'Unexpected average rating payload',
      );
    }

    return AverageRating.fromJson(decoded);
  }

  @override
  Future<List<ReviewResponse>> fetchEventReviews(
    String eventId, {
    String? accessToken,
    String tokenType = 'Bearer',
  }) async {
    final response = await _client.get(
      _uri('/api/events/$eventId/reviews'),
      headers: _headers(accessToken: accessToken, tokenType: tokenType),
    );

    if (response.statusCode != 200) {
      throw ReviewRepositoryException(
        'Unable to fetch event reviews',
        statusCode: response.statusCode,
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is List) {
      return decoded
          .whereType<Map>()
          .map(
            (item) => ReviewResponse.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(growable: false);
    }

    if (decoded is Map<String, dynamic>) {
      final content = decoded['content'];
      if (content is List) {
        return content
            .whereType<Map>()
            .map(
              (item) =>
                  ReviewResponse.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList(growable: false);
      }

      return [ReviewResponse.fromJson(decoded)];
    }

    return const [];
  }

  @override
  Future<ReviewResponse?> fetchMyReviewForEvent(
    String eventId, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) async {
    final response = await _client.get(
      _uri('/api/events/$eventId/reviews/my'),
      headers: _headers(accessToken: accessToken, tokenType: tokenType),
    );

    if (response.statusCode == 404) {
      return null;
    }

    if (response.statusCode != 200) {
      throw ReviewRepositoryException(
        'Unable to fetch my review',
        statusCode: response.statusCode,
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const ReviewRepositoryException('Unexpected review payload');
    }

    return ReviewResponse.fromJson(decoded);
  }

  @override
  Future<ReviewResponse> submitEventReview(
    String eventId,
    ReviewRequest request, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) async {
    final response = await _client.post(
      _uri('/api/events/$eventId/reviews'),
      headers: _headers(accessToken: accessToken, tokenType: tokenType),
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw ReviewRepositoryException(
        'Unable to submit review',
        statusCode: response.statusCode,
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const ReviewRepositoryException('Unexpected review payload');
    }

    return ReviewResponse.fromJson(decoded);
  }

  @override
  Future<OrganizerReviewsOverview> fetchMyOrganizerReviews({
    required String organizerId,
    required String accessToken,
    String tokenType = 'Bearer',
  }) async {
    final events = await _fetchMyOrganizerEvents(
      accessToken: accessToken,
      tokenType: tokenType,
    );

    final reviewResults = await Future.wait(
      events.map((event) async {
        try {
          final reviews = await fetchEventReviews(
            event.id,
            accessToken: accessToken,
            tokenType: tokenType,
          );
          return (event: event, reviews: reviews);
        } catch (_) {
          return (event: event, reviews: const <ReviewResponse>[]);
        }
      }),
    );

    final entries = <OrganizerReviewEntry>[];
    for (final result in reviewResults) {
      for (final review in result.reviews) {
        entries.add(
          OrganizerReviewEntry(
            eventId: result.event.id,
            eventTitle: result.event.title,
            review: review,
          ),
        );
      }
    }

    entries.sort((left, right) {
      final comparison = right.review.createdAt.compareTo(
        left.review.createdAt,
      );
      if (comparison != 0) {
        return comparison;
      }
      return left.eventTitle.compareTo(right.eventTitle);
    });

    final averageRating = await fetchOrganizerAverageRating(
      organizerId,
      accessToken: accessToken,
      tokenType: tokenType,
    );

    return OrganizerReviewsOverview(
      averageRating: averageRating,
      totalReviews: averageRating.totalReviews,
      reviews: entries,
    );
  }

  Future<List<ExploreEvent>> _fetchMyOrganizerEvents({
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
        headers: _headers(accessToken: accessToken, tokenType: tokenType),
      );

      if (response.statusCode != 200) {
        throw ReviewRepositoryException(
          'Unable to fetch organizer events',
          statusCode: response.statusCode,
        );
      }

      final decoded = jsonDecode(response.body);
      final pageEvents = _decodePagedEvents(decoded);
      events.addAll(pageEvents.events);
      if (pageEvents.isLast) {
        break;
      }
      page++;
    }

    return events;
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

class _PagedEvents {
  const _PagedEvents({required this.events, required this.isLast});

  final List<ExploreEvent> events;
  final bool isLast;
}
