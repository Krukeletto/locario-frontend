import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:locario/features/explore/models.dart';
import 'package:locario/features/saved/saved_screen.dart';
import 'package:locario/features/saved/saved_events_controller.dart';
import 'package:locario/features/saved/saved_events_repository.dart';
import 'package:locario/features/saved/saved_events_scope.dart';

import '../../test_helpers/fake_location_service.dart';
import '../../test_helpers/test_app.dart';

void main() {
  group('SavedScreen', () {
    testWidgets('shows empty state for guests with no saved events', (
      tester,
    ) async {
      final controller = SavedEventsController(
        repository: _MemorySavedEventsRepository(),
      );
      await controller.load();

      await tester.pumpWidget(
        buildLocalizedTestApp(
          home: SavedEventsScope(
            controller: controller,
            child: SavedScreen(
              locationService: FakeLocationService(serviceEnabled: false),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Saved'), findsOneWidget);
      expect(find.text('No saved events yet'), findsOneWidget);
    });

    testWidgets('lists saved events and lets the user remove them', (
      tester,
    ) async {
      final repository = _MemorySavedEventsRepository(
        initialRecords: [
          SavedEventRecord(
            event: _event('1', 'Jazz Evening'),
            savedAt: DateTime.utc(2026, 6, 1, 12),
          ),
        ],
      );
      final controller = SavedEventsController(repository: repository);
      await controller.load();

      await tester.pumpWidget(
        buildLocalizedTestApp(
          home: SavedEventsScope(
            controller: controller,
            child: SavedScreen(
              locationService: FakeLocationService(serviceEnabled: false),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Jazz Evening'), findsOneWidget);
      expect(find.byTooltip('Remove from saved'), findsOneWidget);

      await tester.tap(find.byTooltip('Remove from saved'));
      await tester.pumpAndSettle();

      expect(find.text('No saved events yet'), findsOneWidget);
      expect(controller.records, isEmpty);
    });
  });
}

class _MemorySavedEventsRepository implements SavedEventsRepository {
  _MemorySavedEventsRepository({List<SavedEventRecord>? initialRecords})
    : _records = [...?initialRecords];

  final List<SavedEventRecord> _records;

  @override
  Future<List<SavedEventRecord>> loadSavedEvents() async => [..._records];

  @override
  Future<void> upsertSavedEvent(SavedEventRecord record) async {
    _records.removeWhere((item) => item.event.id == record.event.id);
    _records.add(record);
    _records.sort((left, right) => right.savedAt.compareTo(left.savedAt));
  }

  @override
  Future<void> removeSavedEvent(String eventId) async {
    _records.removeWhere((item) => item.event.id == eventId);
  }

  @override
  Future<void> replaceSavedEvents(List<SavedEventRecord> records) async {
    _records
      ..clear()
      ..addAll(records);
  }

  @override
  Future<void> clear() async {
    _records.clear();
  }
}

ExploreEvent _event(String id, String title) {
  return ExploreEvent(
    id: id,
    title: title,
    startsAt: DateTime.utc(2026, 6, 1, 18),
    venue: 'Venue',
    location: const LatLng(51.7592, 19.4550),
    categories: const [Category(id: 'music', name: 'Music', slug: 'music')],
    tags: const ['live'],
  );
}
