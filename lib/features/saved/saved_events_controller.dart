import 'package:flutter/foundation.dart' hide Category;
import 'package:latlong2/latlong.dart';

import '../../features/explore/models.dart';
import '../../shared/auth/auth_models.dart';
import '../../shared/auth/favorites_api.dart';
import '../../shared/auth/session_controller.dart';
import '../../shared/events/event_repository.dart';
import 'saved_events_repository.dart';

enum SavedToggleOutcome { saved, removed }

class SavedEventsController extends ChangeNotifier {
  SavedEventsController({
    required SavedEventsRepository repository,
    FavoritesApi? favoritesApi,
    SessionController? sessionController,
    EventRepository? eventRepository,
  }) : _repository = repository,
       _favoritesApi = favoritesApi,
       _sessionController = sessionController,
       _eventRepository = eventRepository {
    _sessionController?.addListener(_onSessionChanged);
  }

  final SavedEventsRepository _repository;
  final FavoritesApi? _favoritesApi;
  final SessionController? _sessionController;
  final EventRepository? _eventRepository;

  List<SavedEventRecord> _records = const [];
  bool _isLoading = false;
  bool _isSyncing = false;
  String? _error;

  List<SavedEventRecord> get records => List.unmodifiable(_records);
  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
  String? get error => _error;

  List<ExploreEvent> get events =>
      _records.map((record) => record.event).toList(growable: false);

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
    if (_isAuthenticated && !_isSyncing) {
      syncWithRemote();
    }
  }

  Future<void> syncWithRemote() async {
    if (!_isAuthenticated || _isSyncing) {
      return;
    }

    _isSyncing = true;
    notifyListeners();

    try {
      final session = _sessionController!;
      final api = _favoritesApi!;

      // Push local-only records to backend
      for (final record in _records) {
        if (record.syncState == SavedEventSyncState.localOnly ||
            record.syncState == SavedEventSyncState.pendingSync) {
          try {
            await api.addFavorite(
              record.event.id,
              session.tokens!.accessToken,
              tokenType: session.tokens!.tokenType,
            );
          } catch (e) {
            debugPrint('Failed to push saved event to remote: $e');
          }
        }
      }

      await session.refreshProfile();
      final profile = session.profile;
      if (profile == null) {
        return;
      }

      final remoteFavorites = profile.favorites;
      final existingIds = _records.map((r) => r.event.id).toSet();
      final remoteIds = remoteFavorites.map((f) => f.eventId).toSet();

      final newRecords = <SavedEventRecord>[];
      for (final fav in remoteFavorites) {
        if (!existingIds.contains(fav.eventId)) {
          newRecords.add(await _fetchFullRecord(fav));
        }
      }

      final updated = _records.map((r) {
        if (remoteIds.contains(r.event.id) &&
            r.syncState != SavedEventSyncState.synced) {
          return r.copyWith(
            syncState: SavedEventSyncState.synced,
            remoteId: r.event.id,
          );
        }
        return r;
      }).toList();

      if (newRecords.isNotEmpty || updated != _records) {
        await replaceAll([...updated, ...newRecords]);
      }
    } catch (error) {
      debugPrint('Sync with remote failed: $error');
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  bool isSaved(String eventId) {
    return _records.any((record) => record.event.id == eventId);
  }

  SavedEventRecord? recordFor(String eventId) {
    for (final record in _records) {
      if (record.event.id == eventId) {
        return record;
      }
    }
    return null;
  }

  Future<void> load() async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _records = await _repository.loadSavedEvents();
      _error = null;
    } catch (error) {
      debugPrint('Saved events load failed: $error');
      _records = const [];
      _error = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    if (_isAuthenticated && !_isSyncing) {
      syncWithRemote();
    }
  }

  Future<SavedToggleOutcome> toggleSaved(ExploreEvent event) async {
    if (isSaved(event.id)) {
      await removeEvent(event.id);
      if (_isAuthenticated) {
        try {
          await _favoritesApi!.removeFavorite(
            event.id,
            _accessToken,
            tokenType: _tokenType,
          );
        } catch (e) {
          debugPrint('Failed to remove remote favorite: $e');
        }
      }
      return SavedToggleOutcome.removed;
    }

    SavedEventSyncState syncState;
    String? remoteId;

    if (_isAuthenticated) {
      try {
        await _favoritesApi!.addFavorite(
          event.id,
          _accessToken,
          tokenType: _tokenType,
        );
        syncState = SavedEventSyncState.synced;
        remoteId = event.id;
      } catch (e) {
        debugPrint('Failed to add remote favorite: $e');
        syncState = SavedEventSyncState.pendingSync;
      }
    } else {
      syncState = SavedEventSyncState.localOnly;
    }

    await saveEvent(event, syncState: syncState, remoteId: remoteId);
    return SavedToggleOutcome.saved;
  }

  Future<void> saveEvent(
    ExploreEvent event, {
    SavedEventSyncState syncState = SavedEventSyncState.localOnly,
    String? remoteId,
    DateTime? savedAt,
  }) async {
    final record = SavedEventRecord(
      event: event,
      savedAt: savedAt ?? DateTime.now().toUtc(),
      syncState: syncState,
      remoteId: remoteId,
    );

    _records = [record, ..._records.where((item) => item.event.id != event.id)]
      ..sort(_compareBySavedAtDescending);
    notifyListeners();

    try {
      await _repository.upsertSavedEvent(record);
    } catch (error) {
      debugPrint('Saved events write failed: $error');
      _error = error.toString();
      await load();
      rethrow;
    }
  }

  Future<void> removeEvent(String eventId) async {
    _records = _records.where((item) => item.event.id != eventId).toList();
    notifyListeners();

    try {
      await _repository.removeSavedEvent(eventId);
    } catch (error) {
      debugPrint('Saved events delete failed: $error');
      _error = error.toString();
      await load();
      rethrow;
    }
  }

  Future<void> replaceAll(List<SavedEventRecord> records) async {
    _records = [...records]..sort(_compareBySavedAtDescending);
    notifyListeners();
    await _repository.replaceSavedEvents(_records);
  }

  Future<void> clear() async {
    _records = const [];
    notifyListeners();
    await _repository.clear();
  }

  Future<SavedEventRecord> _fetchFullRecord(
    FavoriteEventSummary summary,
  ) async {
    final repo = _eventRepository;
    if (repo != null) {
      try {
        final event = await repo.fetchEvent(summary.eventId);
        return SavedEventRecord(
          event: event,
          savedAt: summary.startAt.toUtc(),
          syncState: SavedEventSyncState.synced,
          remoteId: summary.eventId,
        );
      } catch (_) {
        // fallback to minimal record below
      }
    }

    return _summaryToRecord(summary);
  }

  SavedEventRecord _summaryToRecord(FavoriteEventSummary summary) {
    final categories = summary.categoryNames
        .map(
          (name) => Category(
            id: name.toLowerCase().replaceAll(' ', '-'),
            name: name,
            slug: name.toLowerCase().replaceAll(' ', '-'),
          ),
        )
        .toList(growable: false);

    final event = ExploreEvent(
      id: summary.eventId,
      title: summary.name,
      startsAt: summary.startAt,
      endsAt: summary.endAt,
      venue: summary.name,
      location: const LatLng(0, 0),
      categories: categories,
    );

    return SavedEventRecord(
      event: event,
      savedAt: summary.startAt.toUtc(),
      syncState: SavedEventSyncState.synced,
      remoteId: summary.eventId,
    );
  }

  static int _compareBySavedAtDescending(
    SavedEventRecord left,
    SavedEventRecord right,
  ) {
    final comparison = right.savedAt.compareTo(left.savedAt);
    if (comparison != 0) {
      return comparison;
    }

    return left.event.title.compareTo(right.event.title);
  }
}
