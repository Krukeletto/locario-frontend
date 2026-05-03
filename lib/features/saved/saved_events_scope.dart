import 'package:flutter/widgets.dart';

import 'saved_events_controller.dart';

class SavedEventsScope extends InheritedNotifier<SavedEventsController> {
  const SavedEventsScope({
    super.key,
    required SavedEventsController controller,
    required super.child,
  }) : super(notifier: controller);

  static SavedEventsController of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<SavedEventsScope>();
    assert(scope != null, 'SavedEventsScope is missing in the widget tree.');
    return scope!.notifier!;
  }

  static SavedEventsController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<SavedEventsScope>()
        ?.notifier;
  }
}
