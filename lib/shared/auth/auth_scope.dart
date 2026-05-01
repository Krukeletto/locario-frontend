import 'package:flutter/widgets.dart';

import 'session_controller.dart';

class AuthScope extends InheritedNotifier<SessionController> {
  const AuthScope({
    super.key,
    required SessionController controller,
    required super.child,
  }) : super(notifier: controller);

  static SessionController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AuthScope>();
    assert(scope != null, 'AuthScope is missing in the widget tree.');
    return scope!.notifier!;
  }

  static SessionController? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AuthScope>()?.notifier;
  }
}
