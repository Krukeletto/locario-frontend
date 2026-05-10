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
    required this.referenceLocation,
    this.searchRadiusMeters,
    this.showSearchRadiusOverlay = true,
    this.onCameraCenterChanged,
    this.onVisibleRadiusChanged,
  });

  final ExploreMapViewModel controller;
  final MapStyleRepository styleRepository;
  final List<ExploreEvent> events;
  final ValueChanged<ExploreEvent> onEventTap;
  final LatLng referenceLocation;
  final int? searchRadiusMeters;
  final bool showSearchRadiusOverlay;
  final ValueChanged<LatLng>? onCameraCenterChanged;
  final ValueChanged<int>? onVisibleRadiusChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ColoredBox(
      color: colorScheme.surfaceContainerLowest,
      child: MapWidget(
        controller: controller,
        events: events,
        onEventTap: onEventTap,
        searchRadiusCenter: referenceLocation,
        searchRadiusMeters: searchRadiusMeters,
        showSearchRadiusOverlay: showSearchRadiusOverlay,
        styleRepository: styleRepository,
        onCameraCenterChanged: onCameraCenterChanged,
        onVisibleRadiusChanged: onVisibleRadiusChanged,
        overlayPadding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
        attributionAlignment: Alignment.bottomLeft,
        attributionPadding: const EdgeInsets.only(left: 8, bottom: 8),
        recenterAlignment: Alignment.bottomRight,
        recenterPadding: const EdgeInsets.only(right: 16, bottom: 16),
      ),
    );
  }
}
