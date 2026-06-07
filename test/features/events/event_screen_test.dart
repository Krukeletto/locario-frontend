import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:locario/features/events/joined_events_controller.dart';
import 'package:locario/features/events/joined_events_scope.dart';
import 'package:locario/features/explore/models.dart';
import 'package:locario/features/events/event_screen.dart';
import 'package:locario/shared/auth/auth_api.dart';
import 'package:locario/shared/auth/auth_models.dart';
import 'package:locario/shared/auth/auth_repository.dart';
import 'package:locario/shared/auth/auth_scope.dart';
import 'package:locario/shared/auth/session_controller.dart';
import 'package:locario/shared/cache/cache_service.dart';
import 'package:locario/shared/events/event_detail_controller.dart';
import 'package:locario/shared/events/event_detail_scope.dart';
import 'package:locario/shared/events/event_registration_api.dart';
import 'package:locario/shared/events/event_repository.dart';
import 'package:locario/shared/reviews/review_controller.dart';
import 'package:locario/shared/reviews/review_scope.dart';
import 'package:locario/shared/reviews/review_repository.dart';
import 'package:locario/features/saved/saved_events_controller.dart';
import 'package:locario/features/saved/saved_events_repository.dart';
import 'package:locario/features/saved/saved_events_scope.dart';
import 'package:locario/shared/services/calendar_service.dart';

import '../../test_helpers/fake_event_repository.dart';
import '../../test_helpers/test_app.dart';

ExploreEvent _futureEvent() {
  return ExploreEvent(
    id: '11111111-1111-1111-1111-111111111111',
    title: 'Jazz Evening',
    startsAt: DateTime.utc(2026, 6, 12, 19),
    venue: 'Piotrkowska 10, Lodz',
    location: const LatLng(51.7592, 19.4550),
    description: 'Live music and open-air atmosphere.',
    address: 'Piotrkowska 10, Lodz',
  );
}

Widget _buildTestApp({
  required Widget child,
  EventDetailController? detailController,
  ReviewController? reviewController,
}) {
  return buildLocalizedTestApp(
    home: EventDetailScope(
      controller: detailController ?? _stubDetailController(),
      child: ReviewScope(
        controller: reviewController ?? _stubReviewController(),
        child: child,
      ),
    ),
  );
}

EventDetailController _createDetailController({
  ExploreEvent? eventDetails,
  Object? fetchEventError,
}) {
  return EventDetailController(
    eventRepository: FakeEventRepository(
      eventDetails: eventDetails,
      fetchEventError: fetchEventError as EventRepositoryException?,
    ),
    registrationApi: EventRegistrationApi(
      client: http.Client(),
      baseUrl: 'http://localhost',
    ),
    cacheService: _InMemoryCacheService(),
    sessionController: _UnauthenticatedSessionController(),
  );
}

EventDetailController _stubDetailController() {
  return _createDetailController();
}

ReviewController _stubReviewController() {
  return ReviewController(
    reviewRepository: HttpReviewRepository(),
    cacheService: _InMemoryCacheService(),
    sessionController: _UnauthenticatedSessionController(),
  );
}

class _PausingDetailController extends EventDetailController {
  _PausingDetailController._({required _PendingEventRepository pendingRepo})
    : _pendingRepo = pendingRepo,
      super(
        eventRepository: pendingRepo,
        registrationApi: EventRegistrationApi(
          client: http.Client(),
          baseUrl: 'http://localhost',
        ),
        cacheService: _InMemoryCacheService(),
        sessionController: _UnauthenticatedSessionController(),
      );

  factory _PausingDetailController() {
    final repo = _PendingEventRepository();
    return _PausingDetailController._(pendingRepo: repo);
  }

  final _PendingEventRepository _pendingRepo;

  void completePending() => _pendingRepo.complete();
}

class _PendingEventRepository extends FakeEventRepository {
  final Completer<ExploreEvent> _completer = Completer<ExploreEvent>();

  @override
  Future<ExploreEvent> fetchEvent(String id) => _completer.future;

  void complete() {
    if (!_completer.isCompleted) {
      _completer.complete(_futureEvent());
    }
  }
}

class _UnauthenticatedSessionController extends SessionController {
  _UnauthenticatedSessionController()
    : super(
        authRepository: AuthRepository(
          api: AuthApi(client: http.Client(), baseUrl: 'http://localhost'),
          storage: _NoopAuthTokenStorage(),
        ),
      );

  @override
  bool get isAuthenticated => false;

  @override
  AuthTokens? get tokens => null;
}

class _InMemoryCacheService extends CacheService {
  final Map<String, String> _store = {};

  @override
  Future<void> init() async {}

  @override
  Future<String?> getRaw(String key) async => _store[key];

  @override
  Future<void> setRaw(String key, String data, {int? hash}) async {
    _store[key] = data;
  }

  @override
  Future<int?> getHash(String key) async {
    final data = _store[key];
    if (data == null) return null;
    return data.hashCode;
  }

  @override
  Future<void> invalidate(String key) async {
    _store.remove(key);
  }

  @override
  Future<void> invalidateByPrefix(String prefix) async {
    _store.removeWhere((key, _) => key.startsWith(prefix));
  }

  @override
  Future<void> clear() async {
    _store.clear();
  }

  @override
  Future<void> dispose() async {}
}

void main() {
  group('EventScreen', () {
    testWidgets('renders info cards for loaded event', (tester) async {
      final savedController = SavedEventsController(
        repository: _MemorySavedEventsRepository(),
      );

      final detailController = _createDetailController(
        eventDetails: _futureEvent(),
      );

      await tester.pumpWidget(
        _buildTestApp(
          detailController: detailController,
          child: SavedEventsScope(
            controller: savedController,
            child: const EventScreen(
              eventId: '11111111-1111-1111-1111-111111111111',
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('Jazz Evening'), findsOneWidget);
      expect(find.text('Piotrkowska 10, Lodz'), findsOneWidget);
      expect(find.text('Show on map'), findsOneWidget);
      expect(find.text('Save event'), findsOneWidget);
      expect(find.byType(FilledButton), findsNWidgets(2));
    });

    testWidgets('shows loading state before fetch completes', (tester) async {
      final pausingController = _PausingDetailController();

      await tester.pumpWidget(
        _buildTestApp(
          detailController: pausingController,
          child: const EventScreen(
            eventId: '11111111-1111-1111-1111-111111111111',
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Loading event'), findsOneWidget);

      pausingController.completePending();
      await tester.pumpAndSettle();
    });

    testWidgets('shows error state when fetch fails', (tester) async {
      final detailController = _createDetailController(
        fetchEventError: const EventRepositoryException('boom'),
      );

      await tester.pumpWidget(
        _buildTestApp(
          detailController: detailController,
          child: const EventScreen(
            eventId: '11111111-1111-1111-1111-111111111111',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Event unavailable'), findsOneWidget);
    });

    testWidgets('prompts to add the event to calendar after join', (
      tester,
    ) async {
      final authController = _AuthenticatedSessionController();
      final joinedController = _FakeJoinedEventsController(authController);
      final calendarService = _FakeCalendarService();
      final detailController = _createDetailController(
        eventDetails: _futureEvent(),
      );

      await tester.pumpWidget(
        _buildTestApp(
          detailController: detailController,
          child: AuthScope(
            controller: authController,
            child: JoinedEventsScope(
              controller: joinedController,
              child: EventScreen(
                eventId: '11111111-1111-1111-1111-111111111111',
                calendarService: calendarService,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(find.text('Join'), 300);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Join'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Add to calendar?'), findsOneWidget);
      expect(
        find.text(
          'You can add this event now or later from the event details screen. The calendar will open with the details already filled in.',
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Add now'));
      await tester.pumpAndSettle();

      expect(calendarService.addedEvent?.id, _futureEvent().id);
    });
  });
}

class _MemorySavedEventsRepository implements SavedEventsRepository {
  @override
  Future<List<SavedEventRecord>> loadSavedEvents() async => const [];

  @override
  Future<void> upsertSavedEvent(SavedEventRecord record) async {}

  @override
  Future<void> removeSavedEvent(String eventId) async {}

  @override
  Future<void> replaceSavedEvents(List<SavedEventRecord> records) async {}

  @override
  Future<void> clear() async {}
}

class _AuthenticatedSessionController extends SessionController {
  _AuthenticatedSessionController()
    : super(
        authRepository: AuthRepository(
          api: AuthApi(client: http.Client(), baseUrl: 'http://localhost'),
          storage: _NoopAuthTokenStorage(),
        ),
      );

  final AuthTokens _tokens = AuthTokens(
    accessToken: 'access-token',
    refreshToken: 'refresh-token',
    tokenType: 'Bearer',
    expiresAt: DateTime.utc(2030, 1, 1),
  );
  final UserProfile _profile = UserProfile(
    id: 'user-1',
    username: 'tester',
    email: 'tester@example.com',
    hasPassword: true,
    avatarUrl: null,
    bio: null,
    websiteUrl: null,
    instagramUrl: null,
    facebookUrl: null,
    createdAt: DateTime.utc(2026, 1, 1),
    eventRegistrations: const [],
  );

  @override
  bool get isAuthenticated => true;

  @override
  bool get isLoading => false;

  @override
  SessionStatus get status => SessionStatus.authenticated;

  @override
  AuthTokens? get tokens => _tokens;

  @override
  UserProfile? get profile => _profile;

  @override
  Future<void> refreshProfile() async {}
}

class _FakeJoinedEventsController extends JoinedEventsController {
  _FakeJoinedEventsController(SessionController sessionController)
    : super(
        registrationApi: EventRegistrationApi(
          client: http.Client(),
          baseUrl: 'http://localhost',
        ),
        sessionController: sessionController,
      );

  final Set<String> _joinedEventIds = {};

  @override
  Set<String> get joinedEventIds => Set.unmodifiable(_joinedEventIds);

  @override
  bool isJoined(String eventId) => _joinedEventIds.contains(eventId);

  @override
  Future<void> joinEvent(ExploreEvent event) async {
    _joinedEventIds.add(event.id);
    notifyListeners();
  }

  @override
  Future<void> cancelRegistration(String eventId) async {
    _joinedEventIds.remove(eventId);
    notifyListeners();
  }
}

class _FakeCalendarService extends CalendarService {
  _FakeCalendarService() : super();

  ExploreEvent? addedEvent;

  @override
  Future<bool> addEvent(ExploreEvent event) async {
    addedEvent = event;
    return true;
  }
}

class _NoopAuthTokenStorage implements AuthTokenStorage {
  @override
  Future<void> clear() async {}

  @override
  Future<AuthTokens?> readTokens() async => null;

  @override
  Future<void> saveTokens(AuthTokens tokens) async {}
}
