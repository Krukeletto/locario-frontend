import 'package:flutter/material.dart';

import 'saved_filters_controller.dart';

class SavedFiltersScope extends InheritedNotifier<SavedFiltersController> {
  const SavedFiltersScope({
    super.key,
    required SavedFiltersController controller,
    required super.child,
  }) : super(notifier: controller);

  static SavedFiltersController of(BuildContext context) {
    final controller = context
        .dependOnInheritedWidgetOfExactType<SavedFiltersScope>()
        ?.notifier;
    assert(controller != null, 'No SavedFiltersScope found in context');
    return controller!;
  }

  static SavedFiltersController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<SavedFiltersScope>()
        ?.notifier;
  }
}
