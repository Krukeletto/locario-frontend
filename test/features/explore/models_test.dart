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
