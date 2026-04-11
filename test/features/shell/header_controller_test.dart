import 'package:flutter_test/flutter_test.dart';
import 'package:locario/features/explore/models.dart';
import 'package:locario/features/shell/header/header_controller.dart';

void main() {
  group('ShellHeaderController', () {
    test('selectedFilterIndices is read-only', () {
      final controller = ShellHeaderController();

      expect(
        () => controller.selectedFilterIndices.add(2),
        throwsUnsupportedError,
      );
    });

    test('toggleFilter keeps all-filter fallback behavior', () {
      final controller = ShellHeaderController();

      controller.toggleFilter(1);
      expect(controller.selectedFilterIndices, {1});

      controller.toggleFilter(1);
      expect(
        controller.selectedFilterIndices,
        {ShellHeaderController.allFilterIndex},
      );
    });

    test('setSelectedView updates current view', () {
      final controller = ShellHeaderController();

      controller.setSelectedView(ExploreContentView.list);

      expect(controller.selectedView, ExploreContentView.list);
    });
  });
}

