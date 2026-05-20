import 'package:flutter/material.dart';

import 'legal_controller.dart';

class LegalScope extends InheritedNotifier<LegalController> {
  const LegalScope({
    super.key,
    required LegalController controller,
    required super.child,
  }) : super(notifier: controller);

  static LegalController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<LegalScope>();
    assert(scope != null, 'LegalScope is missing in the widget tree.');
    return scope!.notifier!;
  }

  static LegalController? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<LegalScope>()?.notifier;
  }
}
