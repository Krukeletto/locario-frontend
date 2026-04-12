import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../models.dart';

class MapEventCluster {
  const MapEventCluster({required this.events, required this.center});

  final List<ExploreEvent> events;
  final LatLng center;
}

class MapEventClusterer {
  const MapEventClusterer();

  List<MapEventCluster> cluster({
    required List<ExploreEvent> events,
    required List<Offset> screenPositions,
    required double zoom,
    required Size viewportSize,
  }) {
    if (events.isEmpty) {
      return const [];
    }

    if (viewportSize.isEmpty) {
      return [
        for (final event in events)
          MapEventCluster(events: [event], center: event.location),
      ];
    }

    final threshold = (74 - (zoom * 2.4)).clamp(36.0, 64.0);
    final remaining = [
      for (var index = 0; index < events.length; index++)
        _ProjectedEvent(
          event: events[index],
          screenPosition: screenPositions[index],
        ),
    ];
    final clusters = <MapEventCluster>[];

    while (remaining.isNotEmpty) {
      final seed = remaining.removeAt(0);
      final members = <_ProjectedEvent>[seed];
      var didAdd = true;

      while (didAdd) {
        didAdd = false;
        final centroid = _averageOffset(
          members
              .map((member) => member.screenPosition)
              .toList(growable: false),
        );

        for (var index = remaining.length - 1; index >= 0; index--) {
          final candidate = remaining[index];
          if ((candidate.screenPosition - centroid).distance <= threshold) {
            members.add(candidate);
            remaining.removeAt(index);
            didAdd = true;
          }
        }
      }

      clusters.add(
        MapEventCluster(
          events: members.map((member) => member.event).toList(growable: false),
          center: _averageLatLng(
            members
                .map((member) => member.event.location)
                .toList(growable: false),
          ),
        ),
      );
    }

    return clusters;
  }

  Offset _averageOffset(List<Offset> points) {
    final dx = points.fold<double>(0, (sum, point) => sum + point.dx);
    final dy = points.fold<double>(0, (sum, point) => sum + point.dy);
    return Offset(dx / points.length, dy / points.length);
  }

  LatLng _averageLatLng(List<LatLng> points) {
    final latitude = points.fold<double>(
      0,
      (sum, point) => sum + point.latitude,
    );
    final longitude = points.fold<double>(
      0,
      (sum, point) => sum + point.longitude,
    );
    return LatLng(latitude / points.length, longitude / points.length);
  }
}

class _ProjectedEvent {
  const _ProjectedEvent({required this.event, required this.screenPosition});

  final ExploreEvent event;
  final Offset screenPosition;
}
