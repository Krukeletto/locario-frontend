import 'package:flutter_test/flutter_test.dart';
import 'package:locario/features/explore/models.dart';

void main() {
  group('ExploreAdvancedFilters', () {
    test('default filters are not counted as active', () {
      const filters = ExploreAdvancedFilters();

      expect(filters.activeFiltersCount, 0);
      expect(filters.hasActiveFilters, isFalse);
    });

    test('non-default distance filter is counted as active', () {
      const filters = ExploreAdvancedFilters(
        distanceFilter: ExploreDistanceFilter.within5Km,
      );

      expect(filters.activeFiltersCount, 1);
      expect(filters.hasActiveFilters, isTrue);
    });
  });
}
