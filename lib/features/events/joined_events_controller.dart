import 'package:flutter/foundation.dart';

import '../../shared/auth/session_controller.dart';
import '../../shared/events/event_registration_api.dart';
import '../../shared/events/event_slots_response.dart';
import '../explore/models.dart';

class JoinedEventsController extends ChangeNotifier {
  JoinedEventsController({
    required EventRegistrationApi registrationApi,
    SessionController? sessionController,
  }) : _registrationApi = registrationApi,
       _sessionController = sessionController {
    _sessionController?.addListener(_onSessionChanged);
  }

  final EventRegistrationApi _registrationApi;
  final SessionController? _sessionController;

  Set<String> _joinedEventIds = {};
  final Map<String, EventSlotsResponse> _slotsCache = {};
  final bool _isLoading = false;

  Set<String> get joinedEventIds => Set.unmodifiable(_joinedEventIds);
  bool get isLoading => _isLoading;

  bool get _isAuthenticated =>
      _sessionController?.isAuthenticated == true &&
      _sessionController?.tokens != null;

  String get _accessToken => _sessionController!.tokens!.accessToken;
  String get _tokenType => _sessionController!.tokens!.tokenType;

  @override
  void dispose() {
    _sessionController?.removeListener(_onSessionChanged);
    super.dispose();
  }

  void _onSessionChanged() {
    if (_sessionController?.isAuthenticated == true) {
      load();
    } else {
      _joinedEventIds = {};
      _slotsCache.clear();
      notifyListeners();
    }
  }

  bool isJoined(String eventId) => _joinedEventIds.contains(eventId);

  EventSlotsResponse? slotsFor(String eventId) => _slotsCache[eventId];

  void load() {
    final profile = _sessionController?.profile;
    if (profile != null) {
      _joinedEventIds = profile.eventRegistrations
          .map((r) => r.eventId)
          .toSet();
      notifyListeners();
    }
  }

  Future<EventSlotsResponse> fetchSlots(String eventId) async {
    try {
      final slots = await _registrationApi.fetchSlots(eventId);
      _slotsCache[eventId] = slots;
      notifyListeners();
      return slots;
    } catch (e) {
      debugPrint('Failed to fetch slots: $e');
      rethrow;
    }
  }

  Future<void> joinEvent(ExploreEvent event) async {
    if (!_isAuthenticated) return;

    await _registrationApi.joinEvent(
      event.id,
      _accessToken,
      tokenType: _tokenType,
    );

    _joinedEventIds.add(event.id);
    notifyListeners();

    await _sessionController?.refreshProfile();
    load();
  }

  Future<void> cancelRegistration(String eventId) async {
    if (!_isAuthenticated) return;

    await _registrationApi.cancelRegistration(
      eventId,
      _accessToken,
      tokenType: _tokenType,
    );

    _joinedEventIds.remove(eventId);
    notifyListeners();

    await _sessionController?.refreshProfile();
    load();
  }
}
