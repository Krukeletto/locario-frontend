import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:locario/features/explore/models.dart';
import 'package:locario/shared/auth/auth_api.dart';
import 'package:locario/shared/auth/auth_models.dart';
import 'package:locario/shared/auth/auth_repository.dart';
import 'package:locario/shared/auth/session_controller.dart';
import 'package:locario/shared/cache/cache_service.dart';
import 'package:locario/shared/events/event_detail_controller.dart';
import 'package:locario/shared/events/event_registration_api.dart';
import 'package:locario/shared/events/event_slots_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../test_helpers/fake_event_repository.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test(
    'loadEvent preserves author metadata when fresh payload omits it',
    () async {
      final cachedEvent = _event(
        organizerId: 'user-1',
        organizerUsername: 'tester',
        organizers: const ['tester'],
      );
      final freshEvent = _event();
      final cache = _InMemoryCacheService();
      await cache.set('event_${cachedEvent.id}', cachedEvent.toJson());

      final controller = EventDetailController(
        eventRepository: FakeEventRepository(eventDetails: freshEvent),
        registrationApi: _NoopEventRegistrationApi(),
        cacheService: cache,
        sessionController: _UnauthenticatedSessionController(),
      );

      await controller.loadEvent(cachedEvent.id);

      expect(controller.event, isNotNull);
      expect(controller.event!.organizerId, 'user-1');
      expect(controller.event!.organizerUsername, 'tester');
      expect(controller.event!.organizers, ['tester']);
    },
  );
}

ExploreEvent _event({
  String? organizerId,
  String? organizerUsername,
  List<String> organizers = const [],
}) {
  return ExploreEvent(
    id: '11111111-1111-1111-1111-111111111111',
    title: 'Jazz Evening',
    startsAt: DateTime.utc(2026, 6, 12, 19),
    venue: 'Piotrkowska 10, Lodz',
    location: const LatLng(51.7592, 19.4550),
    description: 'Live music and open-air atmosphere.',
    address: 'Piotrkowska 10, Lodz',
    organizerId: organizerId,
    organizerUsername: organizerUsername,
    organizers: organizers,
  );
}

class _InMemoryCacheService extends CacheService {
  final Map<String, String> _store = {};
  final Map<String, int> _hashes = {};

  @override
  Future<void> init() async {}

  @override
  Future<String?> getRaw(String key) async => _store[key];

  @override
  Future<T?> get<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final raw = _store[key];
    if (raw == null) return null;
    return fromJson(Map<String, dynamic>.from(jsonDecode(raw) as Map));
  }

  @override
  Future<void> set(String key, Map<String, dynamic> data, {int? hash}) async {
    _store[key] = jsonEncode(data);
    _hashes[key] = hash ?? _store[key]!.hashCode;
  }

  @override
  Future<int?> getHash(String key) async => _hashes[key];

  @override
  Future<void> invalidate(String key) async {
    _store.remove(key);
    _hashes.remove(key);
  }

  @override
  Future<void> invalidateByPrefix(String prefix) async {
    final keys = _store.keys.where((key) => key.startsWith(prefix)).toList();
    for (final key in keys) {
      await invalidate(key);
    }
  }

  @override
  Future<void> clear() async {
    _store.clear();
    _hashes.clear();
  }

  @override
  Future<void> dispose() async {}
}

class _NoopEventRegistrationApi extends EventRegistrationApi {
  _NoopEventRegistrationApi()
    : super(client: null, baseUrl: 'http://localhost');

  @override
  Future<EventSlotsResponse> fetchSlots(String eventId) async {
    return const EventSlotsResponse(
      slotLimit: 0,
      registeredCount: 0,
      availableSlots: 0,
      waitlistCount: 0,
      soldOut: false,
    );
  }
}

class _UnauthenticatedSessionController extends SessionController {
  _UnauthenticatedSessionController()
    : super(
        authRepository: AuthRepository(
          api: AuthApi(),
          storage: _NoopTokenStorage(),
        ),
      );

  @override
  bool get isAuthenticated => false;

  @override
  AuthTokens? get tokens => null;

  @override
  UserProfile? get profile => null;
}

class _NoopTokenStorage implements AuthTokenStorage {
  @override
  Future<void> clear() async {}

  @override
  Future<AuthTokens?> readTokens() async => null;

  @override
  Future<void> saveTokens(AuthTokens tokens) async {}
}
