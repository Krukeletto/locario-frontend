import 'package:flutter/material.dart';

import '../explore_map_style_repository.dart';
import '../explore_map_view_model.dart';
import 'map_widget.dart';

class ExploreMapView extends StatelessWidget {
  const ExploreMapView({
    super.key,
    required this.controller,
    required this.styleRepository,
  });

  final ExploreMapViewModel controller;
  final ExploreMapStyleRepository styleRepository;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ColoredBox(
      color: colorScheme.surfaceContainerLowest,
      child: MapWidget(
        controller: controller,
        styleRepository: styleRepository,
        overlayPadding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
        attributionAlignment: Alignment.bottomRight,
        attributionPadding: const EdgeInsets.only(right: 8, bottom: 8),
        recenterAlignment: Alignment.topRight,
        recenterPadding: const EdgeInsets.only(right: 16, top: 12),
      ),
    );
  }
}
