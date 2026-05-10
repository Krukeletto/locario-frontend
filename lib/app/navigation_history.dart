import 'package:flutter/widgets.dart';

class NavigationHistoryController {
  String? _currentLocation;
  String? _lastSafeLocation;

  String? get currentLocation => _currentLocation;
  String? get lastSafeLocation => _lastSafeLocation;

  void recordLocation(String location, {required bool rememberAsSafe}) {
    _currentLocation = location;
    if (rememberAsSafe) {
      _lastSafeLocation = location;
    }
  }
}

class RouteHistoryReporter extends StatefulWidget {
  const RouteHistoryReporter({
    super.key,
    required this.controller,
    required this.location,
    required this.rememberAsSafe,
    required this.child,
  });

  final NavigationHistoryController controller;
  final String location;
  final bool rememberAsSafe;
  final Widget child;

  @override
  State<RouteHistoryReporter> createState() => _RouteHistoryReporterState();
}

class _RouteHistoryReporterState extends State<RouteHistoryReporter> {
  String? _reportedLocation;

  @override
  void initState() {
    super.initState();
    _scheduleReport();
  }

  @override
  void didUpdateWidget(covariant RouteHistoryReporter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.location != widget.location ||
        oldWidget.rememberAsSafe != widget.rememberAsSafe) {
      _scheduleReport();
    }
  }

  void _scheduleReport() {
    if (_reportedLocation == widget.location) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      widget.controller.recordLocation(
        widget.location,
        rememberAsSafe: widget.rememberAsSafe,
      );
      _reportedLocation = widget.location;
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
