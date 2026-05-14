import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:locario/features/explore/explore_area_controller.dart';
import 'package:locario/features/explore/models.dart';
import 'package:locario/features/explore/widgets/advanced_filter_sheet.dart';
import 'package:locario/features/saved/saved_filters_controller.dart';
import 'package:locario/features/saved/saved_filters_repository.dart';
import 'package:locario/features/saved/saved_filters_scope.dart';
import 'package:locario/features/saved/saved_filter_model.dart';

import '../../test_helpers/test_app.dart';

void main() {
  group('ExploreAdvancedFilterSheet', () {
    testWidgets('enables save dialog action after entering a name', (
      tester,
    ) async {
      final controller = SavedFiltersController(
        repository: _NoopSavedFiltersRepository(),
      );

      await tester.pumpWidget(
        buildLocalizedTestApp(
          home: SavedFiltersScope(
            controller: controller,
            child: Scaffold(
              body: ExploreAdvancedFilterSheet(
                initialFilters: const ExploreAdvancedFilters(),
                areaController: ExploreAreaController(),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Save').first);
      await tester.pumpAndSettle();

      final saveButtonBeforeInput = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Save'),
      );
      expect(saveButtonBeforeInput.onPressed, isNull);

      await tester.enterText(find.byType(TextField), 'My filter');
      await tester.pump();

      final saveButtonAfterInput = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Save'),
      );
      expect(saveButtonAfterInput.onPressed, isNotNull);
    });

    testWidgets(
      'clear action is disabled for default filters and enables after change',
      (tester) async {
        await tester.pumpWidget(
          buildLocalizedTestApp(
            home: Scaffold(
              body: ExploreAdvancedFilterSheet(
                initialFilters: const ExploreAdvancedFilters(),
                areaController: ExploreAreaController(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final clearButton = tester.widget<TextButton>(
          find.widgetWithText(TextButton, 'Clear'),
        );
        expect(clearButton.onPressed, isNull);

        final slider = find.byType(Slider);
        expect(slider, findsOneWidget);
        await tester.drag(slider, const Offset(200, 0));
        await tester.pumpAndSettle();

        final enabledClearButton = tester.widget<TextButton>(
          find.widgetWithText(TextButton, 'Clear'),
        );
        expect(enabledClearButton.onPressed, isNotNull);
      },
    );
  });
}

class _NoopSavedFiltersRepository implements SavedFiltersRepository {
  @override
  Future<void> clear() async {}

  @override
  Future<void> delete(String id) async {}

  @override
  Future<List<SavedFilter>> loadAll() async => const [];

  @override
  Future<void> save(SavedFilter filter) async {}

  @override
  Future<void> update(SavedFilter filter) async {}
}
