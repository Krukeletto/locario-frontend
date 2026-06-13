import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:maplibre/maplibre.dart';

import '../models.dart';
import 'map_event_clusterer.dart';

typedef EventMarkerBuilder = Widget Function(ExploreEvent event);
typedef MapLogger = void Function(String message, [Object? error]);

class MapStyleCoordinator {
  MapStyleCoordinator({MapEventClusterer? clusterer, MapLogger? logger})
    : _clusterer = clusterer ?? const MapEventClusterer(),
      _logger = logger ?? _defaultLogger;

  static const eventsSourceId = 'explore-events-source';
  static const eventsLayerId = 'explore-events-layer';
  static const clustersSourceId = 'explore-clusters-source';
  static const clustersCircleLayerId = 'explore-clusters-circle-layer';
  static const clustersLabelLayerId = 'explore-clusters-label-layer';

  final MapEventClusterer _clusterer;
  final MapLogger _logger;
  final Set<String> _registeredEventMarkerImageIds = <String>{};

  bool _eventLayersReady = false;
  bool _isInitializingEventLayers = false;

  bool get eventLayersReady => _eventLayersReady;

  void reset() {
    _eventLayersReady = false;
    _isInitializingEventLayers = false;
    _registeredEventMarkerImageIds.clear();
  }

  Future<void> initializeEventLayers({
    required StyleController? style,
    required ColorScheme colorScheme,
    required List<ExploreEvent> events,
    required EventMarkerBuilder markerBuilder,
  }) async {
    if (style == null || _eventLayersReady || _isInitializingEventLayers) {
      return;
    }

    _isInitializingEventLayers = true;
    try {
      await _registerEventMarkerImages(
        style: style,
        events: events,
        markerBuilder: markerBuilder,
      );

      await style.addSource(
        const GeoJsonSource(
          id: eventsSourceId,
          data: '{"type":"FeatureCollection","features":[]}',
        ),
      );
      await style.addSource(
        const GeoJsonSource(
          id: clustersSourceId,
          data: '{"type":"FeatureCollection","features":[]}',
        ),
      );

      await style.addLayer(
        const SymbolStyleLayer(
          id: eventsLayerId,
          sourceId: eventsSourceId,
          layout: {
            'icon-image': ['get', 'iconImage'],
            'icon-size': 1.5,
            'icon-anchor': 'center',
            'icon-allow-overlap': true,
            'icon-ignore-placement': true,
          },
        ),
      );
      await style.addLayer(
        CircleStyleLayer(
          id: clustersCircleLayerId,
          sourceId: clustersSourceId,
          paint: {
            'circle-radius': 20,
            'circle-color': colorScheme.primary.toHexString(),
            'circle-opacity': 0.9,
            'circle-stroke-width': 3,
            'circle-stroke-color': colorScheme.onPrimary.toHexString(),
            'circle-stroke-opacity': 1,
          },
        ),
      );
      await style.addLayer(
        SymbolStyleLayer(
          id: clustersLabelLayerId,
          sourceId: clustersSourceId,
          layout: const {
            'text-field': ['get', 'label'],
            'text-font': ['Noto Sans Regular'],
            'text-size': 13,
            'text-allow-overlap': true,
            'text-ignore-placement': true,
          },
          paint: {'text-color': colorScheme.onPrimary.toHexString()},
        ),
      );

      _eventLayersReady = true;
    } catch (error) {
      _logger('Map event layer initialization failed', error);
      _eventLayersReady = false;
    } finally {
      _isInitializingEventLayers = false;
    }
  }

  Future<void> syncEventMarkers({
    required StyleController? style,
    required MapController? mapController,
    required Size viewportSize,
    required List<ExploreEvent> events,
    required EventMarkerBuilder markerBuilder,
  }) async {
    if (style == null || mapController == null || !_eventLayersReady) {
      return;
    }

    await _registerEventMarkerImages(
      style: style,
      events: events,
      markerBuilder: markerBuilder,
    );

    final positions = mapController.toScreenLocations(
      events
          .map(
            (event) => Geographic(
              lat: event.location.latitude,
              lon: event.location.longitude,
            ),
          )
          .toList(),
    );
    final zoom = mapController.getCamera().zoom;
    final clusters = _clusterer.cluster(
      events: events,
      screenPositions: positions,
      zoom: zoom,
      viewportSize: viewportSize,
    );
    final eventFeatures = <Map<String, Object?>>[];
    final clusterFeatures = <Map<String, Object?>>[];

    for (var index = 0; index < clusters.length; index++) {
      final cluster = clusters[index];
      final feature = _clusterFeatureJson(cluster, index);
      if (cluster.events.length == 1) {
        eventFeatures.add(feature);
      } else {
        clusterFeatures.add(feature);
      }
    }

    try {
      await style.updateGeoJsonSource(
        id: eventsSourceId,
        data: jsonEncode({
          'type': 'FeatureCollection',
          'features': eventFeatures,
        }),
      );
      await style.updateGeoJsonSource(
        id: clustersSourceId,
        data: jsonEncode({
          'type': 'FeatureCollection',
          'features': clusterFeatures,
        }),
      );
    } catch (error) {
      _logger('Map event marker sync failed', error);
    }
  }

  List<String> layerIdsForTap() => const [
    clustersCircleLayerId,
    clustersLabelLayerId,
    eventsLayerId,
  ];

  String eventMarkerImageId(ExploreEvent event) => 'explore-event-${event.id}';

  Future<void> _registerEventMarkerImages({
    required StyleController style,
    required List<ExploreEvent> events,
    required EventMarkerBuilder markerBuilder,
  }) async {
    for (final event in events) {
      final imageId = eventMarkerImageId(event);
      if (_registeredEventMarkerImageIds.contains(imageId)) {
        continue;
      }

      try {
        await style.addImageFromWidget(
          id: imageId,
          logicalSize: const Size(56, 56),
          imageSize: const Size(112, 112),
          widget: markerBuilder(event),
        );
        _registeredEventMarkerImageIds.add(imageId);
      } catch (error) {
        _logger('Map marker image registration failed', error);
      }
    }
  }

  Map<String, Object?> _clusterFeatureJson(MapEventCluster cluster, int index) {
    final isSingle = cluster.events.length == 1;
    final singleEvent = isSingle ? cluster.events.first : null;
    return {
      'type': 'Feature',
      'id': isSingle ? singleEvent!.id : 'cluster-$index',
      'properties': {
        'kind': isSingle ? 'event' : 'cluster',
        'eventId': isSingle ? singleEvent!.id : null,
        'eventIds': cluster.events.map((event) => event.id).join('|'),
        'count': cluster.events.length,
        'label': cluster.events.length.toString(),
        'iconImage': isSingle ? eventMarkerImageId(singleEvent!) : null,
      },
      'geometry': {
        'type': 'Point',
        'coordinates': [cluster.center.longitude, cluster.center.latitude],
      },
    };
  }

  static void _defaultLogger(String message, [Object? error]) {}
}
