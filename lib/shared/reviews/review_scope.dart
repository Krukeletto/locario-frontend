import 'package:flutter/widgets.dart';

import 'review_controller.dart';

class ReviewScope extends InheritedNotifier<ReviewController> {
  const ReviewScope({
    super.key,
    required ReviewController controller,
    required super.child,
  }) : super(notifier: controller);

  static ReviewController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ReviewScope>();
    assert(scope != null, 'No ReviewScope found in context');
    return scope!.notifier!;
  }

  static ReviewController? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ReviewScope>()?.notifier;
  }
}
