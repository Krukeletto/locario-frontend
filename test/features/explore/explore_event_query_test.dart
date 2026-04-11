import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:locario/features/explore/explore_event_query.dart';
import 'package:locario/features/explore/models.dart';
import 'package:locario/l10n/app_localizations_pl.dart';

void main() {
  const query = ExploreEventQuery();
  final l10n = AppLocalizationsPl();
  final events = buildExploreEvents(l10n);
  const referenceLocation = LatLng(51.695664, 19.416611);

  group('ExploreEventQuery', () {
    test('sorts by startsAt for soonest', () {
      final visibleEvents = query.visibleEvents(
        events: events,
        selectedCategories: const [ExploreCategory.all],
        query: '',
        sort: ExploreSortOption.soonest,
        referenceLocation: referenceLocation,
        l10n: l10n,
      );

      expect(visibleEvents.map((event) => event.id), [
        'night-sketching-vistula',
        'jazz-botanical-garden',
        'run-club-coffee-stop',
        'street-food-vinyl-market',
      ]);
    });

    test('sorts by trendingScore for trending', () {
      final visibleEvents = query.visibleEvents(
        events: events,
        selectedCategories: const [ExploreCategory.all],
        query: '',
        sort: ExploreSortOption.trending,
        referenceLocation: referenceLocation,
        l10n: l10n,
      );

      expect(visibleEvents.map((event) => event.id), [
        'jazz-botanical-garden',
        'street-food-vinyl-market',
        'night-sketching-vistula',
        'run-club-coffee-stop',
      ]);
    });

    test('filters by category and search query', () {
      final visibleEvents = query.visibleEvents(
        events: events,
        selectedCategories: const [ExploreCategory.food],
        query: 'hala',
        sort: ExploreSortOption.distance,
        referenceLocation: referenceLocation,
        l10n: l10n,
      );

      expect(visibleEvents.map((event) => event.id), [
        'street-food-vinyl-market',
      ]);
    });

    test('returns empty search results for empty query', () {
      expect(
        query.searchResults(
          events: events,
          selectedCategories: const [ExploreCategory.all],
          query: '',
          sort: ExploreSortOption.distance,
          referenceLocation: referenceLocation,
          l10n: l10n,
        ),
        isEmpty,
      );
    });
  });
}
