import 'package:flutter/material.dart';
import 'package:locario/l10n/app_localizations.dart';
import 'package:latlong2/latlong.dart';
import 'package:maplibre/maplibre.dart';

import '../../../shared/map/style_repository.dart';
import '../map_view_model.dart';
import '../models.dart';
import 'map_camera_sync.dart';
import 'map_style_coordinator.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({
    super.key,
    required this.controller,
    required this.events,
    this.styleRepository = const MapStyleRepository(),
    this.overlayPadding = EdgeInsets.zero,
    this.attributionAlignment = Alignment.bottomRight,
    this.attributionPadding = const EdgeInsets.only(right: 8, bottom: 8),
    this.recenterAlignment = Alignment.bottomRight,
    this.recenterPadding = const EdgeInsets.only(right: 16, bottom: 16),
    this.onCameraCenterChanged,
  });

  final ExploreMapViewModel controller;
  final List<ExploreEvent> events;
  final MapStyleRepository styleRepository;
  final EdgeInsets overlayPadding;
  final Alignment attributionAlignment;
  final EdgeInsets attributionPadding;
  final Alignment recenterAlignment;
  final EdgeInsets recenterPadding;
  final ValueChanged<LatLng>? onCameraCenterChanged;

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  static const _mapControlBottomOffset = 16.0;
  static final _supportsMapLibre = _detectMapLibreSupport();

  MapController? _mapController;
  bool _isStyleLoaded = false;
  bool? _isUserLocationVisible;
  Brightness? _resolvedBrightness;
  late Future<String> _styleFuture;
  int _styleRevision = 0;
  final MapStyleCoordinator _styleCoordinator = MapStyleCoordinator();
  final MapCameraSync _cameraSync = MapCameraSync();

  static bool _detectMapLibreSupport() {
    try {
      const MapLibreMap().createState();
      return true;
    } on UnsupportedError {
      return false;
    }
  }

  Future<String> _loadStyleJson(Brightness brightness) {
    if (!_supportsMapLibre) {
      return Future.value('');
    }

    return widget.styleRepository.loadStyleJson(brightness: brightness);
  }

  void _refreshStyle(Brightness brightness) {
    final nextStyleFuture = _loadStyleJson(brightness);
    final nextStyleRevision = ++_styleRevision;
    _resolvedBrightness = brightness;
    _styleFuture = nextStyleFuture;
    _isStyleLoaded = false;
    _styleCoordinator.reset();
    _cameraSync.reset();
    _isUserLocationVisible = null;

    if (_supportsMapLibre && _mapController != null) {
      _applyStyleToExistingMap(nextStyleFuture, nextStyleRevision);
    }
  }

  Future<void> _applyStyleToExistingMap(
    Future<String> styleFuture,
    int styleRevision,
  ) async {
    try {
      final styleJson = await styleFuture;
      if (!mounted || styleRevision != _styleRevision) {
        return;
      }

      final mapController = _mapController;
      if (mapController == null) {
        return;
      }

      mapController.setStyle(styleJson);
    } catch (error) {
      debugPrint('Map style apply failed: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    _styleFuture = Future.value('');
    widget.controller.addListener(_handleControllerChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final brightness = Theme.of(context).brightness;
    if (_resolvedBrightness != brightness) {
      _refreshStyle(brightness);
    }
  }

  @override
  void didUpdateWidget(covariant MapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.styleRepository != widget.styleRepository) {
      _refreshStyle(_resolvedBrightness ?? Theme.of(context).brightness);
    }

    if (oldWidget.events != widget.events && _isStyleLoaded) {
      _syncEventMarkers();
    }

    if (oldWidget.controller == widget.controller) {
      return;
    }

    oldWidget.controller.removeListener(_handleControllerChanged);
    widget.controller.addListener(_handleControllerChanged);
    _cameraSync.reset();
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
    final command = _cameraSync.commandForTarget(
      targetCenter: targetCenter,
      currentLocation: widget.controller.currentLocation,
    );
    if (command == null) {
      return;
    }

    _moveTo(command.center, command.zoom);
    _cameraSync.markSynced(command.center);
    _updateUserLocationVisibility();
  }

  void _handleMapCreated(MapController controller) {
    _mapController = controller;
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _handleStyleLoaded(StyleController _) async {
    _isStyleLoaded = true;
    await _styleCoordinator.initializeEventLayers(
      style: _mapController?.style,
      colorScheme: Theme.of(context).colorScheme,
      events: widget.events,
      markerBuilder: _buildEventMarkerBadge,
    );
    if (mounted) {
      setState(() {});
    }

    if (!mounted) return;

    final currentLocation = widget.controller.currentLocation;
    if (currentLocation != null) {
      await _moveTo(currentLocation, _cameraSync.userLocationZoom);
      _cameraSync.markSynced(currentLocation);
      widget.onCameraCenterChanged?.call(currentLocation);
      await _syncEventMarkers();
      _updateUserLocationVisibility();
      return;
    }

    final targetCenter = widget.controller.mapCenter;
    await _moveTo(targetCenter, _cameraSync.fallbackZoom);
    _cameraSync.markSynced(targetCenter);
    widget.onCameraCenterChanged?.call(targetCenter);
    await _syncEventMarkers();
    _updateUserLocationVisibility();
  }

  Future<void> _syncEventMarkers() async {
    final mapController = _mapController;
    final style = mapController?.style;
    if (!_styleCoordinator.eventLayersReady &&
        mapController != null &&
        style != null) {
      await _styleCoordinator.initializeEventLayers(
        style: style,
        colorScheme: Theme.of(context).colorScheme,
        events: widget.events,
        markerBuilder: _buildEventMarkerBadge,
      );
    }
    if (!_styleCoordinator.eventLayersReady ||
        mapController == null ||
        style == null) {
      return;
    }
    if (!mounted) {
      return;
    }

    await _styleCoordinator.syncEventMarkers(
      style: style,
      mapController: mapController,
      viewportSize: MediaQuery.sizeOf(context),
      events: widget.events,
      markerBuilder: _buildEventMarkerBadge,
    );
  }

  bool _isLocationVisible(LatLng location) {
    final mapController = _mapController;
    if (mapController == null) {
      return false;
    }

    try {
      return _cameraSync.isLocationVisible(mapController, location);
    } catch (error) {
      debugPrint('Map location visibility check failed: $error');
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
    _moveTo(location, _cameraSync.userLocationZoom, animate: true);
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
    if (event is MapEventClick) {
      _handleMapTap(event.screenPoint);
    }
    if (event is MapEventMoveCamera) {
      widget.onCameraCenterChanged?.call(_fromGeographic(event.camera.center));
    }
    if (event is MapEventCameraIdle) {
      final camera = _mapController?.camera;
      if (camera != null) {
        widget.onCameraCenterChanged?.call(_fromGeographic(camera.center));
      }
      _syncEventMarkers();
      _updateUserLocationVisibility();
    }
  }

  void _handleMapTap(Offset screenPoint) {
    final mapController = _mapController;
    if (mapController == null || !_styleCoordinator.eventLayersReady) {
      return;
    }

    final features = mapController.featuresAtPoint(
      screenPoint,
      layerIds: _styleCoordinator.layerIdsForTap(),
    );
    if (features.isEmpty) {
      return;
    }

    final eventIds = (features.first.properties['eventIds']?.toString() ?? '')
        .split('|')
        .where((id) => id.isNotEmpty)
        .toList(growable: false);
    final events = [
      for (final id in eventIds)
        ...widget.events.where((event) => event.id == id),
    ];
    if (events.isEmpty) {
      return;
    }

    if (events.length == 1) {
      _openEvent(events.first);
      return;
    }

    _showClusterEvents(events);
  }

  void _openEvent(ExploreEvent event) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(l10n.mapEventOpenSoon(event.title))),
      );
  }

  Future<void> _showClusterEvents(List<ExploreEvent> events) async {
    final l10n = AppLocalizations.of(context)!;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        top: false,
        child: ListView.separated(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          itemCount: events.length + 1,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  l10n.mapClusterSheetTitle(events.length),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              );
            }

            final event = events[index - 1];
            return _ClusterEventTile(
              event: event,
              onTap: () {
                Navigator.of(context).pop();
                _openEvent(event);
              },
            );
          },
        ),
      ),
    );
  }

  Geographic _toGeographic(LatLng latLng) {
    return Geographic(lat: latLng.latitude, lon: latLng.longitude);
  }

  LatLng _fromGeographic(Geographic geographic) {
    return LatLng(geographic.lat, geographic.lon);
  }

  Widget _buildEventMarkerBadge(ExploreEvent event) {
    return _EventMarkerBadge(
      backgroundColor: event.accentColor,
      icon: event.icon,
    );
  }

  Widget _buildMapSurface(
    BuildContext context,
    ColorScheme colorScheme,
    Brightness brightness,
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
      layers: [
        if (currentLocation != null)
          CircleLayer(
            points: [Feature(geometry: Point(_toGeographic(currentLocation)))],
            radius: 8,
            color: colorScheme.primary,
            strokeWidth: 3,
            strokeColor: colorScheme.onPrimary,
          ),
      ],
      options: MapOptions(
        initCenter: _toGeographic(widget.controller.mapCenter),
        initZoom: currentLocation != null
            ? _cameraSync.userLocationZoom
            : _cameraSync.fallbackZoom,
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
    final brightness = Theme.of(context).brightness;
    final l10n = AppLocalizations.of(context)!;

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
                  brightness,
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
                      message: l10n.mapStyleLoadFailed('$styleLoadError'),
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
                            tooltip: l10n.mapReturnToLocation,
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
    final l10n = AppLocalizations.of(context)!;

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
                  _messageFor(l10n, controller.message!),
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
                child: Text(l10n.mapRetry),
              ),
              if (controller.status == ExploreMapStatus.permissionDenied &&
                  controller.canOpenAppSettings)
                TextButton(
                  onPressed: controller.openAppSettings,
                  child: Text(l10n.mapAppSettings),
                ),
              if (controller.status == ExploreMapStatus.serviceDisabled &&
                  controller.canOpenLocationSettings)
                TextButton(
                  onPressed: controller.openLocationSettings,
                  child: Text(l10n.mapLocationSettings),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _messageFor(AppLocalizations l10n, ExploreMapMessage message) {
    return switch (message) {
      ExploreMapMessage.serviceDisabled => l10n.mapServiceDisabled,
      ExploreMapMessage.permissionDenied => l10n.mapPermissionDenied,
      ExploreMapMessage.permissionDeniedForever =>
        l10n.mapPermissionDeniedForever,
      ExploreMapMessage.unableDetermineLocation =>
        l10n.mapUnableDetermineLocation,
      ExploreMapMessage.timeout => l10n.mapLocationTimeout,
      ExploreMapMessage.unableLoadLocation => l10n.mapUnableLoadLocation,
    };
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

class _EventMarkerBadge extends StatelessWidget {
  const _EventMarkerBadge({required this.backgroundColor, required this.icon});

  final Color backgroundColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.16),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

class _ClusterEventTile extends StatelessWidget {
  const _ClusterEventTile({required this.event, required this.onTap});

  final ExploreEvent event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: scheme.outline.withValues(alpha: 0.18)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: event.accentColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(event.icon, color: event.accentColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${event.categoryLabel(l10n)} • ${event.timeLabel(l10n)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    event.venue,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: event.accentColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, color: scheme.primary),
          ],
        ),
      ),
    );
  }
}
