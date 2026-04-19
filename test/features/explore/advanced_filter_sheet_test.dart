import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:locario/features/explore/explore_area_controller.dart';
import 'package:locario/features/explore/models.dart';
import 'package:locario/features/explore/widgets/advanced_filter_sheet.dart';

import '../../test_helpers/test_app.dart';

void main() {
  group('ExploreAdvancedFilterSheet', () {
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
