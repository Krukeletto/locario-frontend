import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:maplibre/maplibre.dart';

import '../explore_map_view_model.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({super.key, required this.controller});

  final ExploreMapViewModel controller;

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  static const _fallbackZoom = 16.0;
  static const _userLocationZoom = 16.0;
  static const _mapControlBottomOffset = 16.0;
  static final _supportsMapLibre = _detectMapLibreSupport();

  MapController? _mapController;
  bool _isStyleLoaded = false;
  LatLng? _lastSyncedLocation;

  static bool _detectMapLibreSupport() {
    try {
      const MapLibreMap().createState();
      return true;
    } on UnsupportedError {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleControllerChanged);
  }

  @override
  void didUpdateWidget(covariant MapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) {
      return;
    }

    oldWidget.controller.removeListener(_handleControllerChanged);
    widget.controller.addListener(_handleControllerChanged);
    _lastSyncedLocation = null;
    _handleControllerChanged();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerChanged);
    super.dispose();
  }

  void _handleControllerChanged() {
    if (!_isStyleLoaded) {
      return;
    }

    final currentLocation = widget.controller.currentLocation;
    if (currentLocation == null || currentLocation == _lastSyncedLocation) {
      return;
    }

    _moveTo(currentLocation, _userLocationZoom);
    _lastSyncedLocation = currentLocation;
  }

  void _handleMapCreated(MapController controller) {
    _mapController = controller;
  }

  void _handleStyleLoaded(StyleController _) {
    _isStyleLoaded = true;

    final currentLocation = widget.controller.currentLocation;
    if (currentLocation != null) {
      _moveTo(currentLocation, _userLocationZoom);
      _lastSyncedLocation = currentLocation;
      return;
    }

    _moveTo(widget.controller.mapCenter, _fallbackZoom);
  }

  Future<void> _moveTo(LatLng center, double zoom) async {
    await _mapController?.moveCamera(
      center: _toGeographic(center),
      zoom: zoom,
    );
  }

  void _recenterMap() {
    final location = widget.controller.currentLocation;
    if (location == null) {
      return;
    }

    _moveTo(location, _userLocationZoom);
  }

  Geographic _toGeographic(LatLng latLng) {
    return Geographic(lat: latLng.latitude, lon: latLng.longitude);
  }

  Widget _buildMapSurface(
    BuildContext context,
    ColorScheme colorScheme,
    LatLng? currentLocation,
  ) {
    if (!_supportsMapLibre) {
      return ColoredBox(
        color: colorScheme.surfaceContainerLowest,
        child: currentLocation == null
            ? const SizedBox.expand()
            : Center(
                child: _CurrentLocationMarker(colorScheme: colorScheme),
              ),
      );
    }

    return MapLibreMap(
      onMapCreated: _handleMapCreated,
      onStyleLoaded: _handleStyleLoaded,
      options: MapOptions(
        initCenter: _toGeographic(widget.controller.mapCenter),
        initZoom: currentLocation != null ? _userLocationZoom : _fallbackZoom,
        initStyle: ExploreMapViewModel.mapStyleUrl,
        minZoom: 2.0,
        maxZoom: 19.0,
      ),
      children: [
        SourceAttribution(
          padding: const EdgeInsets.only(right: 8, bottom: 8),
          alignment: Alignment.bottomRight,
          showMapLibre: false,
        ),
        if (currentLocation != null)
          WidgetLayer(
            markers: [
              Marker(
                point: _toGeographic(currentLocation),
                size: const Size(24, 24),
                child: _CurrentLocationMarker(colorScheme: colorScheme),
              ),
            ],
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final controller = widget.controller;
        final currentLocation = controller.currentLocation;

        return Stack(
          children: [
            _buildMapSurface(context, colorScheme, currentLocation),
            if (controller.isLoading)
              Container(
                color: Colors.black.withValues(alpha: 0.3),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      colorScheme.primary,
                    ),
                  ),
                ),
              ),
            if (controller.status != ExploreMapStatus.ready &&
                controller.message != null &&
                !controller.isLoading)
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: _MapMessageBanner(controller: controller),
              ),
            Positioned(
              bottom: _mapControlBottomOffset,
              left: 16,
              child: SizedBox(
                width: 48,
                height: 48,
                child: FloatingActionButton(
                  heroTag: 'recenter',
                  backgroundColor: colorScheme.surface,
                  foregroundColor: colorScheme.onSurface,
                  tooltip: 'Return to my location',
                  onPressed: currentLocation == null ? null : _recenterMap,
                  child: const Icon(Icons.my_location, size: 24),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CurrentLocationMarker extends StatelessWidget {
  const _CurrentLocationMarker({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('current-location-marker'),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: colorScheme.primary,
        shape: BoxShape.circle,
        border: Border.all(color: colorScheme.onPrimary, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: colorScheme.onPrimary,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _MapMessageBanner extends StatelessWidget {
  const _MapMessageBanner({required this.controller});

  final ExploreMapViewModel controller;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      key: const Key('map-message-banner'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber, color: colorScheme.onErrorContainer),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  controller.message!,
                  style: TextStyle(
                    color: colorScheme.onErrorContainer,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              TextButton(
                onPressed: controller.refreshLocation,
                child: const Text('Retry'),
              ),
              if (controller.status == ExploreMapStatus.permissionDenied &&
                  controller.canOpenAppSettings)
                TextButton(
                  onPressed: controller.openAppSettings,
                  child: const Text('App settings'),
                ),
              if (controller.status == ExploreMapStatus.serviceDisabled &&
                  controller.canOpenLocationSettings)
                TextButton(
                  onPressed: controller.openLocationSettings,
                  child: const Text('Location settings'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
