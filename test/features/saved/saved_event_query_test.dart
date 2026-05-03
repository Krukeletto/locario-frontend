import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:locario/features/explore/models.dart';
import 'package:locario/features/saved/saved_event_query.dart';
import 'package:locario/features/saved/saved_events_repository.dart';

void main() {
  group('SavedEventQuery', () {
    test('filters by category, age and tags', () {
      final query = SavedEventQuery();
      final records = [
        _record(
          '1',
          title: 'Jazz Night',
          category: const Category(id: 'music', name: 'Music', slug: 'music'),
          tags: const ['live', 'night'],
          minAge: 12,
        ),
        _record(
          '2',
          title: 'Kids Workshop',
          category: const Category(id: 'art', name: 'Art', slug: 'art'),
          tags: const ['workshop'],
          maxAge: 12,
        ),
      ];

      final visible = query.visibleRecords(
        records: records,
        filters: const SavedFilters(
          selectedCategoryIds: {'music'},
          selectedTags: {'live'},
          minAge: 12,
          maxAge: 18,
        ),
        sort: SavedSortOption.recent,
        referenceLocation: null,
      );

      expect(visible, hasLength(1));
      expect(visible.single.event.id, '1');
    });

    test('sorts by distance when reference location is available', () {
      final query = SavedEventQuery();
      final records = [
        _record(
          '1',
          title: 'Far',
          location: const LatLng(51.8, 19.7),
          savedAt: DateTime.utc(2026, 5, 1, 12),
        ),
        _record(
          '2',
          title: 'Near',
          location: const LatLng(51.7595, 19.4552),
          savedAt: DateTime.utc(2026, 5, 1, 13),
        ),
      ];

      final visible = query.visibleRecords(
        records: records,
        filters: SavedFilters.defaults,
        sort: SavedSortOption.distance,
        referenceLocation: const LatLng(51.7592, 19.4550),
      );

      expect(visible.first.event.id, '2');
      expect(visible.last.event.id, '1');
    });

    test('falls back to recent when distance has no reference location', () {
      final query = SavedEventQuery();
      final records = [
        _record('1', title: 'Older', savedAt: DateTime.utc(2026, 5, 1, 12)),
        _record('2', title: 'Newer', savedAt: DateTime.utc(2026, 5, 1, 13)),
      ];

      final visible = query.visibleRecords(
        records: records,
        filters: SavedFilters.defaults,
        sort: SavedSortOption.distance,
        referenceLocation: null,
      );

      expect(visible.first.event.id, '2');
      expect(visible.last.event.id, '1');
    });
  });
}

SavedEventRecord _record(
  String id, {
  required String title,
  Category? category,
  List<String> tags = const [],
  int? minAge,
  int? maxAge,
  LatLng? location,
  DateTime? savedAt,
}) {
  return SavedEventRecord(
    event: ExploreEvent(
      id: id,
      title: title,
      startsAt: DateTime.utc(2026, 5, 1, 18),
      venue: 'Venue',
      location: location ?? const LatLng(51.7592, 19.4550),
      categories: category == null ? const [] : [category],
      tags: tags,
      minAge: minAge,
      maxAge: maxAge,
    ),
    savedAt: savedAt ?? DateTime.utc(2026, 5, 1, 12),
  );
}
