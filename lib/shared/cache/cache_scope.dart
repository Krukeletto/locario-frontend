import 'package:flutter/widgets.dart';
import 'cache_service.dart';

class CacheScope extends InheritedWidget {
  const CacheScope({
    super.key,
    required this.cacheService,
    required super.child,
  });

  final CacheService cacheService;

  static CacheService of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<CacheScope>();
    assert(scope != null, 'No CacheScope found in context');
    return scope!.cacheService;
  }

  static CacheService? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<CacheScope>()
        ?.cacheService;
  }

  @override
  bool updateShouldNotify(CacheScope oldWidget) => false;
}
