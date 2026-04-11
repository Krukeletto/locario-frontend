import 'package:latlong2/latlong.dart';
import 'package:maplibre/maplibre.dart';

class MapCameraCommand {
  const MapCameraCommand({required this.center, required this.zoom});

  final LatLng center;
  final double zoom;
}

class MapCameraSync {
  MapCameraSync({
    this.fallbackZoom = 16,
    this.userLocationZoom = 16,
    this.recenterThresholdInMeters = 150,
  });

  final double fallbackZoom;
  final double userLocationZoom;
  final double recenterThresholdInMeters;
  final Distance _distance = const Distance();

  LatLng? _lastSyncedCenter;

  void reset() {
    _lastSyncedCenter = null;
  }

  void markSynced(LatLng center) {
    _lastSyncedCenter = center;
  }

  MapCameraCommand? commandForTarget({
    required LatLng targetCenter,
    required LatLng? currentLocation,
  }) {
    if (targetCenter == _lastSyncedCenter) {
      return null;
    }

    final lastSyncedCenter = _lastSyncedCenter;
    if (lastSyncedCenter != null &&
        _distance(lastSyncedCenter, targetCenter) < recenterThresholdInMeters) {
      _lastSyncedCenter = targetCenter;
      return null;
    }

    return MapCameraCommand(
      center: targetCenter,
      zoom: currentLocation != null ? userLocationZoom : fallbackZoom,
    );
  }

  bool isLocationVisible(MapController mapController, LatLng location) {
    final visibleRegion = mapController.getVisibleRegion();
    return location.latitude >= visibleRegion.latitudeSouth &&
        location.latitude <= visibleRegion.latitudeNorth &&
        location.longitude >= visibleRegion.longitudeWest &&
        location.longitude <= visibleRegion.longitudeEast;
  }
}
