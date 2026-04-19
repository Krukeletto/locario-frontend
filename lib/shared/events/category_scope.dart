import 'package:flutter/widgets.dart';
import 'category_controller.dart';

class CategoryScope extends InheritedWidget {
  const CategoryScope({
    super.key,
    required this.controller,
    required super.child,
  });

  final CategoryController controller;

  static CategoryController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<CategoryScope>();
    assert(scope != null, 'No CategoryScope found in context');
    return scope!.controller;
  }

  static CategoryController? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<CategoryScope>()?.controller;
  }

  @override
  bool updateShouldNotify(CategoryScope oldWidget) {
    return controller != oldWidget.controller;
  }
}
