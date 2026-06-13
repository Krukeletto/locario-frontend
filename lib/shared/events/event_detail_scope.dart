import 'package:flutter/widgets.dart';

import 'event_detail_controller.dart';

class EventDetailScope extends InheritedNotifier<EventDetailController> {
  const EventDetailScope({
    super.key,
    required EventDetailController controller,
    required super.child,
  }) : super(notifier: controller);

  static EventDetailController of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<EventDetailScope>();
    assert(scope != null, 'No EventDetailScope found in context');
    return scope!.notifier!;
  }

  static EventDetailController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<EventDetailScope>()
        ?.notifier;
  }
}
