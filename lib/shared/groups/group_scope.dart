import 'package:flutter/widgets.dart';

import 'group_controller.dart';

class GroupScope extends InheritedNotifier<GroupController> {
  const GroupScope({
    super.key,
    required GroupController controller,
    required super.child,
  }) : super(notifier: controller);

  static GroupController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<GroupScope>();
    assert(scope != null, 'No GroupScope found in context');
    return scope!.notifier!;
  }

  static GroupController? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<GroupScope>()?.notifier;
  }
}
