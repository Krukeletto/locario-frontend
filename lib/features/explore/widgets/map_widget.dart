import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:maplibre/maplibre.dart';

import '../explore_map_style_repository.dart';
import '../explore_map_view_model.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({
    super.key,
    required this.controller,
    this.styleRepository = const ExploreMapStyleRepository(),
    this.overlayPadding = EdgeInsets.zero,
    this.attributionAlignment = Alignment.bottomRight,
    this.attributionPadding = const EdgeInsets.only(right: 8, bottom: 8),
    this.recenterAlignment = Alignment.bottomRight,
    this.recenterPadding = const EdgeInsets.only(right: 16, bottom: 16),
  });

  final ExploreMapViewModel controller;
  final ExploreMapStyleRepository styleRepository;
  final EdgeInsets overlayPadding;
  final Alignment attributionAlignment;
  final EdgeInsets attributionPadding;
  final Alignment recenterAlignment;
  final EdgeInsets recenterPadding;

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  static const _fallbackZoom = 16.0;
  static const _userLocationZoom = 16.0;
  static const _mapControlBottomOffset = 16.0;
  static const _cameraRecenterThresholdInMeters = 150.0;
  static final _supportsMapLibre = _detectMapLibreSupport();
  static const _distance = Distance();

  MapController? _mapController;
  bool _isStyleLoaded = false;
  LatLng? _lastSyncedCenter;
  bool? _isUserLocationVisible;
  late Future<String> _styleFuture;

  static bool _detectMapLibreSupport() {
    try {
      const MapLibreMap().createState();
      return true;
    } on UnsupportedError {
      return false;
    }
  }

  Future<String> _loadStyleJson() {
    if (!_supportsMapLibre) {
      return Future.value('');
    }

    return widget.styleRepository.loadStyleJson();
  }

  @override
  void initState() {
    super.initState();
    _styleFuture = _loadStyleJson();
    widget.controller.addListener(_handleControllerChanged);
  }

  @override
  void didUpdateWidget(covariant MapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.styleRepository != widget.styleRepository) {
      _styleFuture = _loadStyleJson();
      _isStyleLoaded = false;
      _mapController = null;
    }

    if (oldWidget.controller == widget.controller) {
      return;
    }

    oldWidget.controller.removeListener(_handleControllerChanged);
    widget.controller.addListener(_handleControllerChanged);
    _lastSyncedCenter = null;
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

    final targetCenter = widget.controller.mapCenter;
    if (targetCenter == _lastSyncedCenter) {
      return;
    }

    final lastSyncedCenter = _lastSyncedCenter;
    if (lastSyncedCenter != null &&
        _distance(lastSyncedCenter, targetCenter) <
            _cameraRecenterThresholdInMeters) {
      _lastSyncedCenter = targetCenter;
      return;
    }

    final currentLocation = widget.controller.currentLocation;
    final targetZoom = currentLocation != null
        ? _userLocationZoom
        : _fallbackZoom;
    _moveTo(targetCenter, targetZoom);
    _lastSyncedCenter = targetCenter;
    _updateUserLocationVisibility();
  }

  void _handleMapCreated(MapController controller) {
    _mapController = controller;
  }

  void _handleStyleLoaded(StyleController _) {
    _isStyleLoaded = true;

    final currentLocation = widget.controller.currentLocation;
    if (currentLocation != null) {
      _moveTo(currentLocation, _userLocationZoom);
      _lastSyncedCenter = currentLocation;
      _updateUserLocationVisibility();
      return;
    }

    final targetCenter = widget.controller.mapCenter;
    _moveTo(targetCenter, _fallbackZoom);
    _lastSyncedCenter = targetCenter;
    _updateUserLocationVisibility();
  }

  bool _isLocationVisible(LatLng location) {
    final mapController = _mapController;
    if (mapController == null) {
      return false;
    }

    try {
      final visibleRegion = mapController.getVisibleRegion();
      return location.latitude >= visibleRegion.latitudeSouth &&
          location.latitude <= visibleRegion.latitudeNorth &&
          location.longitude >= visibleRegion.longitudeWest &&
          location.longitude <= visibleRegion.longitudeEast;
    } catch (e) {
      // If we can't determine visibility, assume it's not visible to show the button
      return false;
    }
  }

  Future<void> _moveTo(
    LatLng center,
    double zoom, {
    bool animate = false,
    Duration duration = const Duration(milliseconds: 650),
  }) async {
    final mapController = _mapController;
    if (mapController == null) {
      return;
    }

    if (animate) {
      try {
        await mapController.animateCamera(
          center: _toGeographic(center),
          zoom: zoom,
          nativeDuration: duration,
        );
      } catch (error) {
        debugPrint('Map camera animation interrupted: $error');
      }
      return;
    }

    await mapController.moveCamera(center: _toGeographic(center), zoom: zoom);
  }

  void _recenterMap() {
    final location = widget.controller.currentLocation;
    if (location == null) {
      return;
    }

    widget.controller.setPreferredMapCenter(location);
    _moveTo(location, _userLocationZoom, animate: true);
  }

  void _updateUserLocationVisibility() {
    final currentLocation = widget.controller.currentLocation;
    if (currentLocation == null) {
      setState(() {
        _isUserLocationVisible = false;
      });
      return;
    }

    final isVisible = _isLocationVisible(currentLocation);
    if (!mounted) {
      return;
    }

    setState(() {
      _isUserLocationVisible = isVisible;
    });
  }

  void _handleMapEvent(MapEvent event) {
    if (event is MapEventCameraIdle) {
      _updateUserLocationVisibility();
    }
  }

  Geographic _toGeographic(LatLng latLng) {
    return Geographic(lat: latLng.latitude, lon: latLng.longitude);
  }

  Widget _buildMapSurface(
    BuildContext context,
    ColorScheme colorScheme,
    LatLng? currentLocation,
    String? styleJson,
  ) {
    if (!_supportsMapLibre) {
      return ColoredBox(
        color: colorScheme.surfaceContainerLowest,
        child: currentLocation == null
            ? const SizedBox.expand()
            : Center(child: _CurrentLocationMarker(colorScheme: colorScheme)),
      );
    }

    if (styleJson == null) {
      return ColoredBox(color: colorScheme.surfaceContainerLowest);
    }

    return MapLibreMap(
      onMapCreated: _handleMapCreated,
      onStyleLoaded: _handleStyleLoaded,
      onEvent: _handleMapEvent,
      layers: currentLocation == null
          ? const []
          : [
              CircleLayer(
                points: [
                  Feature(
                    geometry: Point(_toGeographic(currentLocation)),
                  ),
                ],
                radius: 8,
                color: colorScheme.primary,
                strokeWidth: 3,
                strokeColor: colorScheme.onPrimary,
              ),
            ],
      options: MapOptions(
        initCenter: _toGeographic(widget.controller.mapCenter),
        initZoom: currentLocation != null ? _userLocationZoom : _fallbackZoom,
        initStyle: styleJson,
        minZoom: 2.0,
        maxZoom: 19.0,
      ),
      children: [
        SourceAttribution(
          padding: widget.attributionPadding,
          alignment: widget.attributionAlignment,
          showMapLibre: false,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FutureBuilder<String>(
      future: _styleFuture,
      builder: (context, styleSnapshot) {
        return AnimatedBuilder(
          animation: widget.controller,
          builder: (context, _) {
            final controller = widget.controller;
            final currentLocation = controller.currentLocation;
            final styleJson = styleSnapshot.data;
            final styleLoadFailed = _supportsMapLibre && styleSnapshot.hasError;
            final styleLoadError = styleSnapshot.error;
            final isStyleLoading =
                _supportsMapLibre && !styleLoadFailed && styleJson == null;

            if (styleLoadError != null) {
              debugPrint('Map style load failed: $styleLoadError');
            }

            return Stack(
              children: [
                _buildMapSurface(
                  context,
                  colorScheme,
                  currentLocation,
                  styleJson,
                ),
                if (isStyleLoading)
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
                if (styleLoadFailed)
                  Positioned(
                    top: 16 + widget.overlayPadding.top,
                    left: 16,
                    right: 16,
                    child: _StaticMapMessageBanner(
                      message:
                          'Unable to load the local map style.\n$styleLoadError',
                    ),
                  )
                else if (controller.status != ExploreMapStatus.ready &&
                    controller.message != null &&
                    !controller.isLocating)
                  Positioned(
                    top: 16 + widget.overlayPadding.top,
                    left: 16,
                    right: 16,
                    child: _MapMessageBanner(controller: controller),
                  ),
                if (_isUserLocationVisible == false)
                  Align(
                    alignment: widget.recenterAlignment,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: widget.recenterPadding.left,
                        top:
                            widget.recenterPadding.top +
                            widget.overlayPadding.top,
                        right: widget.recenterPadding.right,
                        bottom:
                            widget.recenterPadding.bottom +
                            widget.overlayPadding.bottom +
                            _mapControlBottomOffset,
                      ),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.18),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: SizedBox(
                          width: 56,
                          height: 56,
                          child: FloatingActionButton(
                            key: const Key('map-recenter-button'),
                            heroTag: 'recenter',
                            backgroundColor: colorScheme.primaryContainer,
                            foregroundColor: colorScheme.onPrimaryContainer,
                            elevation: 2,
                            focusElevation: 4,
                            hoverElevation: 4,
                            highlightElevation: 6,
                            tooltip: 'Return to my location',
                            onPressed: currentLocation == null
                                ? null
                                : _recenterMap,
                            child: const Icon(
                              Icons.my_location_rounded,
                              size: 26,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
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

class _StaticMapMessageBanner extends StatelessWidget {
  const _StaticMapMessageBanner({required this.message});

  final String message;

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
      child: Row(
        children: [
          Icon(Icons.warning_amber, color: colorScheme.onErrorContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: colorScheme.onErrorContainer,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
