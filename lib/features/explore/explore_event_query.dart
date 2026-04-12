import 'package:latlong2/latlong.dart';
import 'package:locario/l10n/app_localizations.dart';

import 'models.dart';

class ExploreEventQuery {
  const ExploreEventQuery();

  List<ExploreEvent> visibleEvents({
    required List<ExploreEvent> events,
    required Iterable<ExploreCategory> selectedCategories,
    required String query,
    required ExploreSortOption sort,
    required LatLng referenceLocation,
    required AppLocalizations l10n,
    int? maxDistanceMeters,
  }) {
    final normalizedQuery = query.trim().toLowerCase();
    final categories = selectedCategories
        .where((category) => category != ExploreCategory.all)
        .toSet();
    Iterable<ExploreEvent> filteredEvents = events;

    if (categories.isNotEmpty) {
      filteredEvents = filteredEvents.where(
        (event) => categories.contains(event.category),
      );
    }

    if (normalizedQuery.isNotEmpty) {
      filteredEvents = filteredEvents.where((event) {
        final haystack = [
          event.title,
          event.venue,
          event.categoryLabel(l10n),
          event.timeLabel(l10n),
        ].join(' ').toLowerCase();
        return haystack.contains(normalizedQuery);
      });
    }

    if (maxDistanceMeters != null) {
      filteredEvents = filteredEvents.where(
        (event) =>
            event.distanceMetersFrom(referenceLocation) <= maxDistanceMeters,
      );
    }

    final sortedEvents = filteredEvents.toList(growable: false);
    sortedEvents.sort((first, second) {
      return switch (sort) {
        ExploreSortOption.distance =>
          first
              .distanceMetersFrom(referenceLocation)
              .compareTo(second.distanceMetersFrom(referenceLocation)),
        ExploreSortOption.soonest => first.startsAt.compareTo(second.startsAt),
        ExploreSortOption.trending => second.trendingScore.compareTo(
          first.trendingScore,
        ),
      };
    });

    return sortedEvents;
  }

  List<ExploreEvent> searchResults({
    required List<ExploreEvent> events,
    required Iterable<ExploreCategory> selectedCategories,
    required String query,
    required ExploreSortOption sort,
    required LatLng referenceLocation,
    required AppLocalizations l10n,
    int? maxDistanceMeters,
  }) {
    if (query.trim().isEmpty) {
      return const [];
    }

    return visibleEvents(
      events: events,
      selectedCategories: selectedCategories,
      query: query,
      sort: sort,
      referenceLocation: referenceLocation,
      l10n: l10n,
      maxDistanceMeters: maxDistanceMeters,
    );
  }
}
