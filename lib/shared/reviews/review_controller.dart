import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../auth/session_controller.dart';
import '../cache/cache_service.dart';
import 'review_models.dart';
import 'review_repository.dart';

class ReviewController extends ChangeNotifier {
  ReviewController({
    required ReviewRepository reviewRepository,
    required CacheService cacheService,
    required SessionController sessionController,
  }) : _reviewRepository = reviewRepository,
       _cache = cacheService,
       _sessionController = sessionController;

  final ReviewRepository _reviewRepository;
  final CacheService _cache;
  final SessionController _sessionController;

  String? get _accessToken => _sessionController.tokens?.accessToken;
  String get _tokenType => _sessionController.tokens?.tokenType ?? 'Bearer';

  // Per-organizer rating cache
  AverageRating? _organizerRating;
  bool _isRatingLoading = false;
  String? _ratingError;

  // Event reviews
  List<ReviewResponse> _eventReviews = [];
  bool _isReviewsLoading = false;

  // User's own review for an event
  ReviewResponse? _userReview;
  bool _isUserReviewLoading = false;

  // Organizer reviews overview
  OrganizerReviewsOverview? _organizerReviewsOverview;
  bool _isOrganizerReviewsLoading = false;

  AverageRating? get organizerRating => _organizerRating;
  bool get isRatingLoading => _isRatingLoading;
  String? get ratingError => _ratingError;
  List<ReviewResponse> get eventReviews => List.unmodifiable(_eventReviews);
  bool get isReviewsLoading => _isReviewsLoading;
  ReviewResponse? get userReview => _userReview;
  bool get isUserReviewLoading => _isUserReviewLoading;
  OrganizerReviewsOverview? get organizerReviewsOverview =>
      _organizerReviewsOverview;
  bool get isOrganizerReviewsLoading => _isOrganizerReviewsLoading;

  // ── Organizer rating ──────────────────────────────────────────────────

  Future<void> loadOrganizerRating(String organizerId) async {
    final cacheKey = 'organizer_rating_$organizerId';

    final cached = await _cache.get<AverageRating>(
      cacheKey,
      AverageRating.fromJson,
    );
    if (cached != null) {
      _organizerRating = cached;
      notifyListeners();
    }

    _isRatingLoading = true;
    notifyListeners();

    try {
      final fresh = await _reviewRepository.fetchOrganizerAverageRating(
        organizerId,
        accessToken: _accessToken,
        tokenType: _tokenType,
      );

      final freshHash = jsonEncode(fresh.toJson()).hashCode;
      final cachedHash = await _cache.getHash(cacheKey);

      if (freshHash != cachedHash) {
        _organizerRating = fresh;
        await _cache.set(cacheKey, fresh.toJson(), hash: freshHash);
        notifyListeners();
      }
    } catch (e) {
      if (_organizerRating == null) {
        _ratingError = e.toString();
        notifyListeners();
      }
    } finally {
      _isRatingLoading = false;
      notifyListeners();
    }
  }

  // ── Event reviews ─────────────────────────────────────────────────────

  Future<void> loadEventReviews(String eventId) async {
    _isReviewsLoading = true;
    notifyListeners();

    try {
      _eventReviews = await _reviewRepository.fetchEventReviews(
        eventId,
        accessToken: _accessToken,
        tokenType: _tokenType,
      );
      notifyListeners();
    } catch (_) {
    } finally {
      _isReviewsLoading = false;
      notifyListeners();
    }
  }

  // ── User's own review ─────────────────────────────────────────────────

  Future<void> loadMyReviewForEvent(String eventId) async {
    if (_accessToken == null) return;

    _isUserReviewLoading = true;
    notifyListeners();

    try {
      _userReview = await _reviewRepository.fetchMyReviewForEvent(
        eventId,
        accessToken: _accessToken!,
        tokenType: _tokenType,
      );
      notifyListeners();
    } catch (_) {
    } finally {
      _isUserReviewLoading = false;
      notifyListeners();
    }
  }

  // ── Organizer reviews overview ────────────────────────────────────────

  Future<void> loadOrganizerReviews(String organizerId) async {
    if (_accessToken == null) return;

    _isOrganizerReviewsLoading = true;
    notifyListeners();

    try {
      _organizerReviewsOverview = await _reviewRepository
          .fetchMyOrganizerReviews(
            organizerId: organizerId,
            accessToken: _accessToken!,
            tokenType: _tokenType,
          );
      notifyListeners();
    } catch (_) {
    } finally {
      _isOrganizerReviewsLoading = false;
      notifyListeners();
    }
  }

  Future<ReviewResponse> submitReview(
    String eventId,
    ReviewRequest request,
  ) async {
    if (_accessToken == null) {
      throw const ReviewRepositoryException('Not authenticated');
    }

    final response = await _reviewRepository.submitEventReview(
      eventId,
      request,
      accessToken: _accessToken!,
      tokenType: _tokenType,
    );

    _userReview = response;
    notifyListeners();

    unawaited(loadEventReviews(eventId));

    return response;
  }

  void clear() {
    _organizerRating = null;
    _eventReviews = [];
    _userReview = null;
    _organizerReviewsOverview = null;
  }
}
