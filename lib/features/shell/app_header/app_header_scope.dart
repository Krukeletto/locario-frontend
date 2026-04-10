import 'package:flutter/widgets.dart';

import 'app_header_controller.dart';

class AppHeaderScope extends InheritedNotifier<AppHeaderController> {
  const AppHeaderScope({
    super.key,
    required AppHeaderController controller,
    required super.child,
  }) : super(notifier: controller);

  static AppHeaderController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<AppHeaderScope>()
        ?.notifier;
  }

  static AppHeaderController of(BuildContext context) {
    final controller = maybeOf(context);
    assert(controller != null, 'AppHeaderScope not found in context');
    return controller!;
  }
}
