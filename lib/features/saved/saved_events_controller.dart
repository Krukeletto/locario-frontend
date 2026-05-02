import 'package:flutter/foundation.dart';

import '../../features/explore/models.dart';
import 'saved_events_repository.dart';

enum SavedToggleOutcome { saved, removed }

class SavedEventsController extends ChangeNotifier {
  SavedEventsController({required SavedEventsRepository repository})
    : _repository = repository;

  final SavedEventsRepository _repository;

  List<SavedEventRecord> _records = const [];
  bool _isLoading = false;
  String? _error;

  List<SavedEventRecord> get records => List.unmodifiable(_records);
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<ExploreEvent> get events =>
      _records.map((record) => record.event).toList(growable: false);

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
  }

  Future<SavedToggleOutcome> toggleSaved(ExploreEvent event) async {
    if (isSaved(event.id)) {
      await removeEvent(event.id);
      return SavedToggleOutcome.removed;
    }

    await saveEvent(event);
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
