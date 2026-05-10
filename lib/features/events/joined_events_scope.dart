import 'package:flutter/material.dart';

import 'joined_events_controller.dart';

class JoinedEventsScope extends InheritedNotifier<JoinedEventsController> {
  const JoinedEventsScope({
    super.key,
    required JoinedEventsController controller,
    required super.child,
  }) : super(notifier: controller);

  static JoinedEventsController? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<JoinedEventsScope>()
        ?.notifier;
  }

  static JoinedEventsController of(BuildContext context) {
    final result = maybeOf(context);
    assert(result != null, 'No JoinedEventsScope found in context');
    return result!;
  }
}
