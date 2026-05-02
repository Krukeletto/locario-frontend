import 'package:latlong2/latlong.dart';

import '../explore/models.dart';
import 'saved_events_repository.dart';

enum SavedSortOption { recent, distance }

class SavedFilters {
  const SavedFilters({
    this.selectedCategoryIds = const <String>{},
    this.selectedTags = const <String>{},
    this.minAge,
    this.maxAge,
  });

  final Set<String> selectedCategoryIds;
  final Set<String> selectedTags;
  final int? minAge;
  final int? maxAge;

  static const defaults = SavedFilters();

  SavedFilters copyWith({
    Set<String>? selectedCategoryIds,
    Set<String>? selectedTags,
    int? Function()? minAge,
    int? Function()? maxAge,
  }) {
    return SavedFilters(
      selectedCategoryIds: selectedCategoryIds ?? this.selectedCategoryIds,
      selectedTags: selectedTags ?? this.selectedTags,
      minAge: minAge != null ? minAge() : this.minAge,
      maxAge: maxAge != null ? maxAge() : this.maxAge,
    );
  }

  bool get hasActiveFilters =>
      selectedCategoryIds.isNotEmpty ||
      selectedTags.isNotEmpty ||
      minAge != null ||
      maxAge != null;

  int get activeFiltersCount {
    int count = 0;
    if (selectedCategoryIds.isNotEmpty) count++;
    if (selectedTags.isNotEmpty) count++;
    if (minAge != null || maxAge != null) count++;
    return count;
  }
}

class SavedEventQuery {
  const SavedEventQuery();

  List<SavedEventRecord> visibleRecords({
    required List<SavedEventRecord> records,
    required SavedFilters filters,
    required SavedSortOption sort,
    required LatLng? referenceLocation,
  }) {
    Iterable<SavedEventRecord> filteredRecords = records;

    if (filters.selectedCategoryIds.isNotEmpty) {
      filteredRecords = filteredRecords.where((record) {
        if (record.event.categories.isEmpty) {
          return false;
        }

        return record.event.categories.any((category) {
          return _normalizedCategoryValues(
            category,
          ).any(filters.selectedCategoryIds.contains);
        });
      });
    }

    if (filters.selectedTags.isNotEmpty) {
      filteredRecords = filteredRecords.where((record) {
        if (record.event.tags.isEmpty) {
          return false;
        }

        return record.event.tags.any(
          (tag) => filters.selectedTags.contains(tag.trim().toLowerCase()),
        );
      });
    }

    if (filters.minAge != null || filters.maxAge != null) {
      final selectedMinAge = filters.minAge ?? 0;
      final selectedMaxAge = filters.maxAge ?? 999;
      filteredRecords = filteredRecords.where((record) {
        final eventMinAge = record.event.minAge ?? 0;
        final eventMaxAge = record.event.maxAge ?? 999;
        return eventMinAge <= selectedMaxAge && eventMaxAge >= selectedMinAge;
      });
    }

    final sortedRecords = filteredRecords.toList(growable: false);
    sortedRecords.sort((left, right) {
      final comparison = switch (sort) {
        SavedSortOption.recent => right.savedAt.compareTo(left.savedAt),
        SavedSortOption.distance =>
          referenceLocation == null
              ? right.savedAt.compareTo(left.savedAt)
              : left.event
                    .distanceMetersFrom(referenceLocation)
                    .compareTo(
                      right.event.distanceMetersFrom(referenceLocation),
                    ),
      };

      if (comparison != 0) {
        return comparison;
      }

      return left.event.title.compareTo(right.event.title);
    });

    return sortedRecords;
  }
}

Set<String> _normalizedCategoryValues(Category category) {
  return {
    category.id.trim().toLowerCase(),
    category.slug.trim().toLowerCase(),
    category.name.trim().toLowerCase(),
  };
}
