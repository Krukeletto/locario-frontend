import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../../shared/map/style_repository.dart';
import '../models.dart';
import '../map_view_model.dart';
import 'map_widget.dart';

class ExploreMapView extends StatelessWidget {
  const ExploreMapView({
    super.key,
    required this.controller,
    required this.styleRepository,
    required this.events,
    required this.onEventTap,
    this.onCameraCenterChanged,
  });

  final ExploreMapViewModel controller;
  final MapStyleRepository styleRepository;
  final List<ExploreEvent> events;
  final ValueChanged<ExploreEvent> onEventTap;
  final ValueChanged<LatLng>? onCameraCenterChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ColoredBox(
      color: colorScheme.surfaceContainerLowest,
      child: MapWidget(
        controller: controller,
        events: events,
        onEventTap: onEventTap,
        styleRepository: styleRepository,
        onCameraCenterChanged: onCameraCenterChanged,
        overlayPadding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
        attributionAlignment: Alignment.bottomRight,
        attributionPadding: const EdgeInsets.only(right: 8, bottom: 8),
        recenterAlignment: Alignment.topRight,
        recenterPadding: const EdgeInsets.only(right: 16, top: 12),
      ),
    );
  }
}
