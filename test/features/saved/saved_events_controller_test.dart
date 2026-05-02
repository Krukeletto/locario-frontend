import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:locario/features/explore/models.dart';
import 'package:locario/features/saved/saved_events_controller.dart';
import 'package:locario/features/saved/saved_events_repository.dart';

void main() {
  group('SavedEventsController', () {
    test('loads, saves, removes and keeps newest record first', () async {
      final repository = _MemorySavedEventsRepository();
      final controller = SavedEventsController(repository: repository);

      await controller.load();
      expect(controller.records, isEmpty);

      final first = _event('1', 'First');
      final second = _event('2', 'Second');

      await controller.saveEvent(
        first,
        savedAt: DateTime.utc(2026, 5, 1, 12),
      );
      await controller.saveEvent(
        second,
        savedAt: DateTime.utc(2026, 5, 1, 13),
      );

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
  });
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
