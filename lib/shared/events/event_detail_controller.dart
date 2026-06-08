import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../features/explore/models.dart';
import '../auth/session_controller.dart';
import '../cache/cache_service.dart';
import 'event_registration_api.dart';
import 'event_repository.dart';
import 'event_slots_response.dart';

class EventDetailController extends ChangeNotifier {
  EventDetailController({
    required EventRepository eventRepository,
    required EventRegistrationApi registrationApi,
    required CacheService cacheService,
    required SessionController sessionController,
  }) : _eventRepository = eventRepository,
       _registrationApi = registrationApi,
       _cache = cacheService,
       _sessionController = sessionController;

  final EventRepository _eventRepository;
  final EventRegistrationApi _registrationApi;
  final CacheService _cache;
  final SessionController _sessionController;

  String? get _accessToken => _sessionController.tokens?.accessToken;
  String get _tokenType => _sessionController.tokens?.tokenType ?? 'Bearer';

  ExploreEvent? _event;
  EventSlotsResponse? _slots;
  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _error;

  List<ExploreEvent> _organizerEvents = [];
  bool _isOrganizerEventsLoading = false;

  ExploreEvent? get event => _event;
  EventSlotsResponse? get slots => _slots;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get error => _error;
  List<ExploreEvent> get organizerEvents => List.unmodifiable(_organizerEvents);
  bool get isOrganizerEventsLoading => _isOrganizerEventsLoading;

  int _computeHash(Object? data) =>
      jsonEncode((data as dynamic).toJson()).hashCode;

  // ── Single event ──────────────────────────────────────────────────────

  Future<void> loadEvent(String eventId, {bool forceRefresh = false}) async {
    final cacheKey = 'event_$eventId';
    _error = null;

    if (!forceRefresh) {
      final cached = await _cache.get<ExploreEvent>(
        cacheKey,
        ExploreEvent.fromJson,
      );
      if (cached != null) {
        _event = cached;
        _isLoading = false;
        _isRefreshing = true;
        notifyListeners();
      }
    }

    if (_event == null || _event!.id != eventId) {
      if (!forceRefresh) {
        _event = null;
        _isLoading = true;
        notifyListeners();
      }
    }

    try {
      final fresh = await _eventRepository.fetchEvent(eventId);
      final freshHash = _computeHash(fresh);
      final cachedHash = await _cache.getHash(cacheKey);

      if (freshHash != cachedHash) {
        final merged = _mergeEventDetails(previousEvent: _event, fresh: fresh);
        _event = merged;
        await _cache.set(cacheKey, merged.toJson(), hash: _computeHash(merged));
        notifyListeners();
      }

      unawaited(loadEventSlots(eventId, fresh.organizerId));
    } catch (e) {
      if (_event == null) {
        _error = e.toString();
        notifyListeners();
      }
    } finally {
      _isLoading = false;
      _isRefreshing = false;
      notifyListeners();
    }
  }

  Future<void> loadEventSlots(String eventId, String? organizerId) async {
    try {
      _slots = await _registrationApi.fetchSlots(eventId);
      notifyListeners();
    } catch (_) {}
  }

  // ── Organizer events ──────────────────────────────────────────────────

  Future<void> loadOrganizerEvents({String? organizerId}) async {
    if (_accessToken == null) return;

    _isOrganizerEventsLoading = true;
    notifyListeners();

    try {
      _organizerEvents = await _eventRepository.fetchOrganizerEvents(
        accessToken: _accessToken!,
        tokenType: _tokenType,
      );
      notifyListeners();
    } catch (_) {
    } finally {
      _isOrganizerEventsLoading = false;
      notifyListeners();
    }
  }

  void clearEvent() {
    _event = null;
    _slots = null;
    _isLoading = false;
    _isRefreshing = false;
    _error = null;
  }

  ExploreEvent _mergeEventDetails({
    required ExploreEvent? previousEvent,
    required ExploreEvent fresh,
  }) {
    final previous = previousEvent;
    if (previous == null || previous.id != fresh.id) {
      return fresh;
    }

    return ExploreEvent(
      id: fresh.id,
      title: fresh.title,
      categories: fresh.categories,
      media: fresh.media,
      thumbnailUrl: fresh.thumbnailUrl,
      startsAt: fresh.startsAt,
      endsAt: fresh.endsAt,
      trendingScore: fresh.trendingScore,
      venue: fresh.venue,
      location: fresh.location,
      minAge: fresh.minAge,
      maxAge: fresh.maxAge,
      eventType: fresh.eventType,
      eventSource: fresh.eventSource,
      description: fresh.description,
      address: fresh.address,
      tags: fresh.tags,
      status: fresh.status,
      slotLimit: fresh.slotLimit,
      ticketUrl: fresh.ticketUrl,
      organizers: fresh.organizers.isNotEmpty
          ? fresh.organizers
          : previous.organizers,
      organizerId: fresh.organizerId ?? previous.organizerId,
      organizerUsername: fresh.organizerUsername ?? previous.organizerUsername,
      createdAt: fresh.createdAt ?? previous.createdAt,
      updatedAt: fresh.updatedAt ?? previous.updatedAt,
      groupIds: fresh.groupIds.isNotEmpty ? fresh.groupIds : previous.groupIds,
      groups: fresh.groups.isNotEmpty ? fresh.groups : previous.groups,
      publicEvent: fresh.publicEvent,
    );
  }
}
