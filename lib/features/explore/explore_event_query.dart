import 'package:flutter/foundation.dart' hide Category;
import 'package:latlong2/latlong.dart';
import '../../shared/services/l10n_service.dart';
import 'models.dart';

class ExploreEventQuery {
  const ExploreEventQuery();

  List<ExploreEvent> visibleEvents({
    required List<ExploreEvent> events,
    required Iterable<Category> selectedCategories,
    required String query,
    required ExploreSortOption sort,
    required bool isAscending,
    required LatLng referenceLocation,
    int? maxDistanceMeters,
    ExploreAdvancedFilters? advancedFilters,
  }) {
    final normalizedQuery = query.trim().toLowerCase();
    final categories = selectedCategories.toSet();
    Iterable<ExploreEvent> filteredEvents = events;

    if (categories.isNotEmpty) {
      filteredEvents = filteredEvents.where((event) {
        if (event.categories.isEmpty) return false;
        return event.categories.any(
          (c) => categories.any((selected) => selected.name.toLowerCase() == c.name.toLowerCase()),
        );
      });
    }
    debugPrint('After category filter: ${filteredEvents.length}');

    if (normalizedQuery.isNotEmpty) {
      final l10n = L10nService.l10n;
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

    final distanceFilterMeters =
        maxDistanceMeters ?? advancedFilters?.distanceFilter.maxDistanceMeters;
    if (distanceFilterMeters != null) {
      filteredEvents = filteredEvents.where((event) {
        final distance = event.distanceMetersFrom(referenceLocation);
        debugPrint(
          'Event "${event.title}" distance: $distance m (limit: $distanceFilterMeters)',
        );
        return distance <= distanceFilterMeters;
      });
    }
    debugPrint(
      'After distance filter ($distanceFilterMeters): ${filteredEvents.length}',
    );
    debugPrint(
      'After distance filter ($distanceFilterMeters): ${filteredEvents.length}',
    );

    if (advancedFilters != null) {
      if (advancedFilters.dateFrom != null) {
        final from = advancedFilters.dateFrom!;
        final fromDate = DateTime(from.year, from.month, from.day);
        filteredEvents = filteredEvents.where((event) {
          final eventDate = DateTime(
            event.startsAt.year,
            event.startsAt.month,
            event.startsAt.day,
          );
          return eventDate.isAtSameMomentAs(fromDate) ||
              eventDate.isAfter(fromDate);
        });
      }

      if (advancedFilters.dateTo != null) {
        final to = advancedFilters.dateTo!;
        final toDate = DateTime(to.year, to.month, to.day, 23, 59, 59);
        filteredEvents = filteredEvents.where((event) {
          final compareDate = event.endsAt ?? event.startsAt;
          return compareDate.isBefore(toDate) ||
              compareDate.isAtSameMomentAs(toDate);
        });
      }

      if (advancedFilters.ageFrom != null || advancedFilters.ageTo != null) {
        final ageFrom = advancedFilters.ageFrom ?? 0;
        final ageTo = advancedFilters.ageTo ?? 999;
        filteredEvents = filteredEvents.where((event) {
          final eventMinAge = event.minAge ?? 0;
          final eventMaxAge = event.maxAge ?? 999;

          return eventMinAge <= ageTo && eventMaxAge >= ageFrom;
        });
      }
    }
    debugPrint('After advanced filters: ${filteredEvents.length}');

    final sortedEvents = filteredEvents.toList(growable: false);
    sortedEvents.sort((first, second) {
      final comparison = switch (sort) {
        ExploreSortOption.distance =>
          first
              .distanceMetersFrom(referenceLocation)
              .compareTo(second.distanceMetersFrom(referenceLocation)),
        ExploreSortOption.soonest => first.startsAt.compareTo(second.startsAt),
        ExploreSortOption.trending => second.trendingScore.compareTo(
          first.trendingScore,
        ),
      };
      return isAscending ? comparison : -comparison;
    });

    return sortedEvents;
  }

  List<ExploreEvent> searchResults({
    required List<ExploreEvent> events,
    required Iterable<Category> selectedCategories,
    required String query,
    required ExploreSortOption sort,
    required bool isAscending,
    required LatLng referenceLocation,
    int? maxDistanceMeters,
    ExploreAdvancedFilters? advancedFilters,
  }) {
    if (query.trim().isEmpty) {
      return const [];
    }

    return visibleEvents(
      events: events,
      selectedCategories: selectedCategories,
      query: query,
      sort: sort,
      isAscending: isAscending,
      referenceLocation: referenceLocation,
      maxDistanceMeters: maxDistanceMeters,
      advancedFilters: advancedFilters,
    );
  }
}
