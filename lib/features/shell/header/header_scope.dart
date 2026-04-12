import 'package:flutter/widgets.dart';

import 'header_controller.dart';

class ShellHeaderScope extends InheritedNotifier<ShellHeaderController> {
  const ShellHeaderScope({
    super.key,
    required ShellHeaderController controller,
    required super.child,
  }) : super(notifier: controller);

  static ShellHeaderController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ShellHeaderScope>()
        ?.notifier;
  }

  static ShellHeaderController of(BuildContext context) {
    final controller = maybeOf(context);
    assert(controller != null, 'ShellHeaderScope not found in context');
    return controller!;
  }
}
