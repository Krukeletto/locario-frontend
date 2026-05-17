import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:locario/features/explore/models.dart';
import 'package:locario/features/saved/saved_events_controller.dart';
import 'package:locario/features/saved/saved_events_repository.dart';
import 'package:locario/shared/auth/auth_api.dart';
import 'package:locario/shared/auth/auth_models.dart';
import 'package:locario/shared/auth/auth_repository.dart';
import 'package:locario/shared/auth/auth_storage.dart';
import 'package:locario/shared/auth/favorites_api.dart';
import 'package:locario/shared/auth/session_controller.dart';

void main() {
  group('SavedEventsController', () {
    test('loads, saves, removes and keeps newest record first', () async {
      final repository = _MemorySavedEventsRepository();
      final controller = SavedEventsController(repository: repository);

      await controller.load();
      expect(controller.records, isEmpty);

      final first = _event('1', 'First');
      final second = _event('2', 'Second');

      await controller.saveEvent(first, savedAt: DateTime.utc(2026, 5, 1, 12));
      await controller.saveEvent(second, savedAt: DateTime.utc(2026, 5, 1, 13));

      expect(controller.records.map((record) => record.event.id), ['2', '1']);
      expect(controller.isSaved('1'), isTrue);
      expect(controller.isSaved('2'), isTrue);

      final toggleOutcome = await controller.toggleSaved(second);
      expect(toggleOutcome, SavedToggleOutcome.removed);
      expect(controller.isSaved('2'), isFalse);
      expect(controller.records.map((record) => record.event.id), ['1']);
    });

    test('replaceAll overwrites current state and persists it', () async {
      final repository = _MemorySavedEventsRepository();
      final controller = SavedEventsController(repository: repository);

      await controller.replaceAll([
        SavedEventRecord(
          event: _event('1', 'First'),
          savedAt: DateTime.utc(2026, 5, 1, 12),
        ),
      ]);

      expect(controller.records, hasLength(1));
      expect(repository.records, hasLength(1));

      await controller.clear();
      expect(controller.records, isEmpty);
      expect(repository.records, isEmpty);
    });

    test('keeps saved event when remote removal fails', () async {
      final repository = _MemorySavedEventsRepository();
      final sessionController = _AuthenticatedSessionController();
      await sessionController.load();

      final controller = SavedEventsController(
        repository: repository,
        sessionController: sessionController,
        favoritesApi: _FailingFavoritesApi(),
      );

      final event = _event('1', 'First');
      await controller.saveEvent(event, syncState: SavedEventSyncState.synced);

      final outcome = await controller.toggleSaved(event);

      expect(outcome, SavedToggleOutcome.failed);
      expect(controller.isSaved('1'), isTrue);
      expect(repository.records, hasLength(1));
    });

    test('removes ended saved events and syncs remote cleanup', () async {
      final repository = _MemorySavedEventsRepository();
      final sessionController = _AuthenticatedSessionController();
      await sessionController.load();
      final favoritesApi = _TrackingFavoritesApi();
      final controller = SavedEventsController(
        repository: repository,
        sessionController: sessionController,
        favoritesApi: favoritesApi,
      );

      await controller.saveEvent(
        _endedEvent('1', 'Expired'),
        savedAt: DateTime.utc(2026, 5, 1, 12),
        syncState: SavedEventSyncState.synced,
        remoteId: '1',
      );

      await controller.load();

      expect(controller.records, isEmpty);
      expect(repository.records, isEmpty);
      expect(favoritesApi.removedEventIds, ['1']);
      expect(favoritesApi.addedEventIds, isEmpty);
    });
  });
}

class _AuthenticatedSessionController extends SessionController {
  _AuthenticatedSessionController()
    : super(authRepository: _AuthenticatedAuthRepository());
}

class _AuthenticatedAuthRepository extends AuthRepository {
  _AuthenticatedAuthRepository()
    : super(api: AuthApi(), storage: const AuthStorage());

  @override
  Future<AuthTokens?> readTokens() async {
    return AuthTokens(
      accessToken: 'access-token',
      refreshToken: 'refresh-token',
      tokenType: 'Bearer',
      expiresAt: DateTime.now().toUtc().add(const Duration(hours: 1)),
    );
  }

  @override
  Future<UserProfile> fetchProfile() async {
    return UserProfile(
      id: 'user-1',
      username: 'tester',
      email: 'tester@example.com',
      hasPassword: true,
      avatarUrl: null,
      bio: null,
      websiteUrl: null,
      instagramUrl: null,
      facebookUrl: null,
      createdAt: DateTime.now().toUtc(),
      eventRegistrations: const [],
      favorites: const [],
    );
  }
}

class _FailingFavoritesApi extends FavoritesApi {
  _FailingFavoritesApi() : super();

  @override
  Future<void> removeFavorite(
    String eventId,
    String accessToken, {
    String tokenType = 'Bearer',
  }) async {
    throw const FavoritesApiException('boom');
  }
}

class _TrackingFavoritesApi extends FavoritesApi {
  _TrackingFavoritesApi() : super();

  final List<String> addedEventIds = [];
  final List<String> removedEventIds = [];

  @override
  Future<void> addFavorite(
    String eventId,
    String accessToken, {
    String tokenType = 'Bearer',
  }) async {
    addedEventIds.add(eventId);
  }

  @override
  Future<void> removeFavorite(
    String eventId,
    String accessToken, {
    String tokenType = 'Bearer',
  }) async {
    removedEventIds.add(eventId);
  }
}

class _MemorySavedEventsRepository implements SavedEventsRepository {
  final List<SavedEventRecord> records = [];

  @override
  Future<List<SavedEventRecord>> loadSavedEvents() async => [...records];

  @override
  Future<void> upsertSavedEvent(SavedEventRecord record) async {
    records.removeWhere((item) => item.event.id == record.event.id);
    records.add(record);
    records.sort((left, right) => right.savedAt.compareTo(left.savedAt));
  }

  @override
  Future<void> removeSavedEvent(String eventId) async {
    records.removeWhere((item) => item.event.id == eventId);
  }

  @override
  Future<void> replaceSavedEvents(List<SavedEventRecord> records) async {
    this.records
      ..clear()
      ..addAll(records);
  }

  @override
  Future<void> clear() async {
    records.clear();
  }
}

ExploreEvent _event(String id, String title) {
  return ExploreEvent(
    id: id,
    title: title,
    startsAt: DateTime.utc(2026, 5, 1, 18),
    venue: 'Venue',
    location: const LatLng(51.7592, 19.4550),
    categories: const [Category(id: 'music', name: 'Music', slug: 'music')],
    tags: const ['concert'],
  );
}

ExploreEvent _endedEvent(String id, String title) {
  return ExploreEvent(
    id: id,
    title: title,
    startsAt: DateTime.utc(2026, 5, 1, 18),
    endsAt: DateTime.utc(2026, 5, 1, 20),
    venue: 'Venue',
    location: const LatLng(51.7592, 19.4550),
    categories: const [Category(id: 'music', name: 'Music', slug: 'music')],
    tags: const ['concert'],
  );
}
