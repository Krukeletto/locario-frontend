import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../explore/models.dart';

enum SavedEventSyncState { localOnly, pendingSync, synced, syncFailed }

class SavedEventRecord {
  const SavedEventRecord({
    required this.event,
    required this.savedAt,
    this.syncState = SavedEventSyncState.localOnly,
    this.remoteId,
  });

  final ExploreEvent event;
  final DateTime savedAt;
  final SavedEventSyncState syncState;
  final String? remoteId;

  SavedEventRecord copyWith({
    ExploreEvent? event,
    DateTime? savedAt,
    SavedEventSyncState? syncState,
    String? remoteId,
  }) {
    return SavedEventRecord(
      event: event ?? this.event,
      savedAt: savedAt ?? this.savedAt,
      syncState: syncState ?? this.syncState,
      remoteId: remoteId ?? this.remoteId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'event': event.toJson(),
      'savedAt': savedAt.toUtc().toIso8601String(),
      'syncState': syncState.name,
      if (remoteId != null) 'remoteId': remoteId,
    };
  }

  factory SavedEventRecord.fromJson(Map<String, dynamic> json) {
    return SavedEventRecord(
      event: ExploreEvent.fromJson(
        Map<String, dynamic>.from(json['event'] as Map),
      ),
      savedAt:
          DateTime.tryParse(json['savedAt'] as String? ?? '') ??
          DateTime.now().toUtc(),
      syncState: SavedEventSyncState.values.firstWhere(
        (state) => state.name == json['syncState'],
        orElse: () => SavedEventSyncState.localOnly,
      ),
      remoteId: json['remoteId'] as String?,
    );
  }
}

abstract class SavedEventsRepository {
  Future<List<SavedEventRecord>> loadSavedEvents();
  Future<void> upsertSavedEvent(SavedEventRecord record);
  Future<void> removeSavedEvent(String eventId);
  Future<void> replaceSavedEvents(List<SavedEventRecord> records);
  Future<void> clear();
}

class SharedPreferencesSavedEventsRepository implements SavedEventsRepository {
  static const _storageKey = 'saved.events.v1';

  const SharedPreferencesSavedEventsRepository();

  Future<SharedPreferences> get _preferences async =>
      SharedPreferences.getInstance();

  @override
  Future<List<SavedEventRecord>> loadSavedEvents() async {
    final raw = (await _preferences).getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return const [];
    }

    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return const [];
    }

    return decoded
        .map((item) {
          if (item is Map) {
            return SavedEventRecord.fromJson(Map<String, dynamic>.from(item));
          }
          return null;
        })
        .whereType<SavedEventRecord>()
        .toList(growable: false)
      ..sort(_compareBySavedAtDescending);
  }

  @override
  Future<void> upsertSavedEvent(SavedEventRecord record) async {
    final records = await loadSavedEvents();
    final updated = <SavedEventRecord>[
      record,
      ...records.where((item) => item.event.id != record.event.id),
    ]..sort(_compareBySavedAtDescending);
    await _writeRecords(updated);
  }

  @override
  Future<void> removeSavedEvent(String eventId) async {
    final records = await loadSavedEvents();
    final updated = records.where((item) => item.event.id != eventId).toList();
    await _writeRecords(updated);
  }

  @override
  Future<void> replaceSavedEvents(List<SavedEventRecord> records) async {
    final updated = [...records]..sort(_compareBySavedAtDescending);
    await _writeRecords(updated);
  }

  @override
  Future<void> clear() async {
    await (await _preferences).remove(_storageKey);
  }

  Future<void> _writeRecords(List<SavedEventRecord> records) async {
    final payload = jsonEncode(
      records.map((record) => record.toJson()).toList(),
    );
    await (await _preferences).setString(_storageKey, payload);
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
