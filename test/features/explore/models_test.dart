import 'package:flutter_test/flutter_test.dart';
import 'package:locario/features/explore/models.dart';

void main() {
  group('primaryCategoryForSubmission', () {
    test('returns null for empty categories', () {
      expect(primaryCategoryForSubmission(const []), isNull);
    });

    test('uses the most recently selected category', () {
      expect(
        primaryCategoryForSubmission(const [
          ExploreCategory.music,
          ExploreCategory.art,
          ExploreCategory.food,
        ]),
        ExploreCategory.food,
      );
    });

    test('ignores default music when another category was selected later', () {
      expect(
        primaryCategoryForSubmission(const [
          ExploreCategory.music,
          ExploreCategory.workshops,
        ]),
        ExploreCategory.workshops,
      );
    });
  });

  group('ExploreEvent.fromJson', () {
    test('maps alternate startsAt and endsAt date keys', () {
      final event = ExploreEvent.fromJson({
        'id': 'event-1',
        'name': 'Picnic',
        'latitude': 51.7559,
        'longitude': 19.4626,
        'address': 'Park',
        'startsAt': '2026-07-12T14:00:00',
        'endsAt': '2026-07-12T19:00:00',
      });

      expect(event.startsAt, DateTime(2026, 7, 12, 14));
      expect(event.endsAt, DateTime(2026, 7, 12, 19));
    });

    test('uses media thumbnail variant for effective thumbnail fallback', () {
      final event = ExploreEvent.fromJson({
        'id': 'event-1',
        'name': 'Picnic',
        'latitude': 51.7559,
        'longitude': 19.4626,
        'address': 'Park',
        'startAt': '2026-07-12T14:00:00',
        'media': [
          {
            'id': 'media-1',
            'url': 'http://localhost:9000/original.jpg',
            'thumbnailUrl': 'http://localhost:9000/thumb_640.jpg',
            'pinUrl': 'http://localhost:9000/pin_128.jpg',
            'type': 'image',
            'sortOrder': 0,
          },
        ],
      });

      expect(
        event.media.single.previewUrl,
        'http://localhost:9000/thumb_640.jpg',
      );
      expect(
        event.media.single.compactUrl,
        'http://localhost:9000/pin_128.jpg',
      );
      expect(
        event.effectiveThumbnailUrl,
        'http://localhost:9000/thumb_640.jpg',
      );
    });

    test('maps capitalized StartsAt and EndsAt date keys', () {
      final event = ExploreEvent.fromJson({
        'id': 'event-1',
        'name': 'Picnic',
        'latitude': 51.7559,
        'longitude': 19.4626,
        'address': 'Park',
        'StartsAt': '2026-07-12T14:00:00',
        'EndsAt': '2026-07-12T19:00:00',
      });

      expect(event.startsAt, DateTime(2026, 7, 12, 14));
      expect(event.endsAt, DateTime(2026, 7, 12, 19));
    });

    test(
      'throws instead of falling back to current date without start date',
      () {
        expect(
          () => ExploreEvent.fromJson({
            'id': 'event-1',
            'name': 'Picnic',
            'latitude': 51.7559,
            'longitude': 19.4626,
            'address': 'Park',
            'endAt': '2026-07-12T19:00:00',
          }),
          throwsFormatException,
        );
      },
    );
  });

  group('ExploreAdvancedFilters', () {
    test('compares by value', () {
      expect(
        const ExploreAdvancedFilters(
          distanceFilter: ExploreDistanceFilter.within5Km,
          ageFrom: 18,
        ),
        const ExploreAdvancedFilters(
          distanceFilter: ExploreDistanceFilter.within5Km,
          ageFrom: 18,
        ),
      );
    });
  });
}
