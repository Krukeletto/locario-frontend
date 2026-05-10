import 'package:flutter/widgets.dart';

import 'notification_controller.dart';

class NotificationScope extends InheritedNotifier<NotificationController> {
  const NotificationScope({
    super.key,
    required NotificationController controller,
    required super.child,
  }) : super(notifier: controller);

  static NotificationController of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<NotificationScope>();
    assert(scope != null, 'NotificationScope is missing in the widget tree.');
    return scope!.notifier!;
  }

  static NotificationController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<NotificationScope>()
        ?.notifier;
  }
}
