import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:locario/l10n/app_localizations.dart';
import 'package:locario/app/theme/app_theme_colors.dart';
import 'package:latlong2/latlong.dart';
import 'package:maplibre/maplibre.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../shared/groups/pin_styles.dart';
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
    required this.onEventTap,
    this.styleRepository = const MapStyleRepository(),
    this.overlayPadding = EdgeInsets.zero,
    this.attributionAlignment = Alignment.bottomRight,
    this.attributionPadding = const EdgeInsets.only(right: 8, bottom: 8),
    this.recenterAlignment = Alignment.bottomRight,
    this.recenterPadding = const EdgeInsets.only(right: 16, bottom: 16),
    this.onCameraCenterChanged,
    this.onVisibleRadiusChanged,
    this.searchRadiusCenter,
    this.searchRadiusMeters,
    this.showSearchRadiusOverlay = true,
    this.requireLocation = true,
  });

  final ExploreMapViewModel controller;
  final List<ExploreEvent> events;
  final ValueChanged<ExploreEvent> onEventTap;
  final MapStyleRepository styleRepository;
  final EdgeInsets overlayPadding;
  final Alignment attributionAlignment;
  final EdgeInsets attributionPadding;
  final Alignment recenterAlignment;
  final EdgeInsets recenterPadding;
  final ValueChanged<LatLng>? onCameraCenterChanged;
  final ValueChanged<int>? onVisibleRadiusChanged;
  final LatLng? searchRadiusCenter;
  final int? searchRadiusMeters;
  final bool showSearchRadiusOverlay;
  final bool requireLocation;

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  static const _mapControlBottomOffset = 16.0;
  static const _searchRadiusSourceId = 'explore-search-radius-source';
  static const _searchRadiusFillLayerId = 'explore-search-radius-fill-layer';
  static const _searchRadiusLineLayerId = 'explore-search-radius-line-layer';
  static final _supportsMapLibre = _detectMapLibreSupport();

  MapController? _mapController;
  bool _isStyleLoaded = false;
  bool? _isUserLocationVisible;
  Brightness? _resolvedBrightness;
  late Future<String> _styleFuture;
  int _styleRevision = 0;
  bool _hasCompletedStartupLoading = false;
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
    } catch (_) {}
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

    if ((oldWidget.events != widget.events ||
            oldWidget.searchRadiusCenter != widget.searchRadiusCenter ||
            oldWidget.searchRadiusMeters != widget.searchRadiusMeters ||
            oldWidget.showSearchRadiusOverlay !=
                widget.showSearchRadiusOverlay) &&
        _isStyleLoaded) {
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
    final currentLocation = widget.controller.currentLocation;
    final command = _cameraSync.commandForTarget(
      targetCenter: targetCenter,
      currentLocation: currentLocation,
    );
    if (command == null) {
      return;
    }

    _moveTo(command.center, command.zoom);
    _cameraSync.markSynced(command.center);
    if (currentLocation != null &&
        _sameLocation(command.center, currentLocation)) {
      widget.onCameraCenterChanged?.call(currentLocation);
    }
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
    await _initializeSearchRadiusLayers();
    if (mounted) {
      setState(() {});
    }

    if (!mounted) return;

    final targetCenter = widget.controller.mapCenter;
    final currentLocation = widget.controller.currentLocation;
    await _moveTo(
      targetCenter,
      currentLocation != null
          ? _cameraSync.userLocationZoom
          : _cameraSync.fallbackZoom,
    );
    _cameraSync.markSynced(targetCenter);
    widget.onCameraCenterChanged?.call(targetCenter);
    await _syncEventMarkers();
    _updateVisibleSearchRadius();
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
    await _syncSearchRadiusOverlay();
  }

  Future<void> _initializeSearchRadiusLayers() async {
    if (!widget.showSearchRadiusOverlay) {
      return;
    }

    final style = _mapController?.style;
    if (style == null) {
      return;
    }

    try {
      await style.addSource(
        const GeoJsonSource(
          id: _searchRadiusSourceId,
          data: '{"type":"FeatureCollection","features":[]}',
        ),
      );
    } catch (_) {}

    if (!mounted) return;

    final colorScheme = Theme.of(context).colorScheme;
    try {
      await style.addLayer(
        FillStyleLayer(
          id: _searchRadiusFillLayerId,
          sourceId: _searchRadiusSourceId,
          paint: {
            'fill-color': colorScheme.primary.toHexString(),
            'fill-opacity': 0.12,
          },
        ),
      );
    } catch (_) {}

    try {
      await style.addLayer(
        LineStyleLayer(
          id: _searchRadiusLineLayerId,
          sourceId: _searchRadiusSourceId,
          paint: {
            'line-color': colorScheme.primary.toHexString(),
            'line-width': 2,
            'line-opacity': 0.45,
          },
        ),
      );
    } catch (_) {}

    await _syncSearchRadiusOverlay();
  }

  Future<void> _syncSearchRadiusOverlay() async {
    if (!widget.showSearchRadiusOverlay) {
      return;
    }

    final style = _mapController?.style;
    if (style == null) {
      return;
    }

    final center = widget.searchRadiusCenter;
    final radiusMeters = widget.searchRadiusMeters;
    final data = center == null || radiusMeters == null
        ? '{"type":"FeatureCollection","features":[]}'
        : _buildSearchRadiusGeoJson(center, radiusMeters);

    try {
      await style.updateGeoJsonSource(id: _searchRadiusSourceId, data: data);
    } catch (_) {}
  }

  String _buildSearchRadiusGeoJson(LatLng center, int radiusMeters) {
    const distance = Distance();
    final ring = <String>[];
    for (var step = 0; step <= 64; step++) {
      final bearing = step * (360 / 64);
      final point = distance.offset(center, radiusMeters.toDouble(), bearing);
      ring.add('[${point.longitude},${point.latitude}]');
    }

    return '{"type":"FeatureCollection","features":[{"type":"Feature","properties":{},"geometry":{"type":"Polygon","coordinates":[[${ring.join(',')}]]}}]}';
  }

  bool _isLocationVisible(LatLng location) {
    final mapController = _mapController;
    if (mapController == null) {
      return false;
    }

    try {
      return _cameraSync.isLocationVisible(mapController, location);
    } catch (_) {
      return false;
    }
  }

  void _updateVisibleSearchRadius() {
    final mapController = _mapController;
    if (mapController == null) {
      return;
    }

    try {
      final visibleRegion = mapController.getVisibleRegion();
      final cameraCenter = mapController.camera?.center;
      if (cameraCenter == null) {
        return;
      }

      final center = _fromGeographic(cameraCenter);
      const distance = Distance();
      final corners = [
        LatLng(visibleRegion.latitudeNorth, visibleRegion.longitudeEast),
        LatLng(visibleRegion.latitudeNorth, visibleRegion.longitudeWest),
        LatLng(visibleRegion.latitudeSouth, visibleRegion.longitudeEast),
        LatLng(visibleRegion.latitudeSouth, visibleRegion.longitudeWest),
      ];

      final radiusMeters = corners
          .map((corner) => distance(center, corner).round())
          .fold<int>(0, (max, value) => value > max ? value : max);

      if (radiusMeters > 0) {
        widget.onVisibleRadiusChanged?.call(radiusMeters);
      }
    } catch (_) {}
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
      } catch (_) {}
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

  bool _sameLocation(LatLng left, LatLng right) {
    return left.latitude == right.latitude && left.longitude == right.longitude;
  }

  void _updateUserLocationVisibility() {
    final currentLocation = widget.controller.currentLocation;
    if (currentLocation == null) {
      if (!mounted) {
        return;
      }
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
      final center = _fromGeographic(event.camera.center);
      _cameraSync.markSynced(center);
      widget.onCameraCenterChanged?.call(center);
    }
    if (event is MapEventCameraIdle) {
      final camera = _mapController?.camera;
      if (camera != null) {
        final center = _fromGeographic(camera.center);
        _cameraSync.markSynced(center);
        widget.onCameraCenterChanged?.call(center);
      }
      _syncEventMarkers();
      _updateVisibleSearchRadius();
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

    final currentZoom = mapController.camera?.zoom ?? 16.0;
    if (currentZoom >= 18.0) {
      _showClusterEvents(events);
      return;
    }

    double minLat = events.first.location.latitude;
    double maxLat = minLat;
    double minLng = events.first.location.longitude;
    double maxLng = minLng;
    for (final event in events) {
      if (event.location.latitude < minLat) minLat = event.location.latitude;
      if (event.location.latitude > maxLat) maxLat = event.location.latitude;
      if (event.location.longitude < minLng) minLng = event.location.longitude;
      if (event.location.longitude > maxLng) maxLng = event.location.longitude;
    }

    final diffLat = maxLat - minLat;
    final diffLng = maxLng - minLng;
    if (diffLat < 0.0001 && diffLng < 0.0001) {
      _showClusterEvents(events);
      return;
    }

    final targetZoom = (currentZoom + 2.5).clamp(2.0, 19.0);
    final center = LatLng((minLat + maxLat) / 2, (minLng + maxLng) / 2);
    _moveTo(center, targetZoom, animate: true);
  }

  void _openEvent(ExploreEvent event) {
    widget.onEventTap(event);
  }

  Future<void> _showClusterEvents(List<ExploreEvent> events) async {
    final l10n = AppLocalizations.of(context);
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
    final groupPin = _findGroupPin(event);
    if (groupPin != null) {
      if (groupPin.mapPinIconUrl != null &&
          groupPin.mapPinIconUrl!.isNotEmpty) {
        return _EventMarkerImageBadge(imageUrl: groupPin.mapPinIconUrl!);
      }
      final predefined = PredefinedPin.fromStyleKey(groupPin.mapPinStyle);
      if (predefined != null) {
        return _EventMarkerBadge(
          backgroundColor: event.accentColor,
          icon: predefined.icon,
        );
      }
    }
    return _EventMarkerBadge(
      backgroundColor: event.accentColor,
      icon: event.icon,
    );
  }

  EventGroupSummary? _findGroupPin(ExploreEvent event) {
    for (final group in event.groups) {
      if (group.mapPinStyle != null && group.mapPinStyle!.isNotEmpty) {
        return group;
      }
      if (group.mapPinIconUrl != null && group.mapPinIconUrl!.isNotEmpty) {
        return group;
      }
    }
    return null;
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
        _CollapsedSourceAttribution(
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
    final l10n = AppLocalizations.of(context);

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
            final isWaitingForStartup =
                isStyleLoading ||
                (widget.requireLocation && controller.isInitialLoading);
            final showStartupLoading =
                !_hasCompletedStartupLoading && isWaitingForStartup;

            if (showStartupLoading) {
              return _StartupLoadingView(
                colorScheme: colorScheme,
                title: l10n.exploreLoadingTitle,
                subtitle: l10n.exploreLoadingSubtitle,
              );
            }

            _hasCompletedStartupLoading = true;
            if (widget.requireLocation &&
                currentLocation == null &&
                !controller.isLocating &&
                (controller.status == ExploreMapStatus.permissionDenied ||
                    controller.status == ExploreMapStatus.serviceDisabled)) {
              return _MapLocationRequiredView(controller: controller);
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
                    color: colorScheme.scrim.withValues(alpha: 0.3),
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
                else if (widget.requireLocation &&
                    controller.status != ExploreMapStatus.ready &&
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
                          color: currentLocation == null
                              ? colorScheme.surfaceContainerHighest
                              : colorScheme.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: SizedBox.square(
                          dimension: 56,
                          child: IconButton(
                            key: const Key('map-recenter-button'),
                            tooltip: l10n.mapReturnToLocation,
                            onPressed: currentLocation == null
                                ? null
                                : _recenterMap,
                            color: colorScheme.onPrimaryContainer,
                            disabledColor: colorScheme.onSurface.withValues(
                              alpha: 0.38,
                            ),
                            icon: const Icon(
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

class _StartupLoadingView extends StatelessWidget {
  const _StartupLoadingView({
    required this.colorScheme,
    required this.title,
    required this.subtitle,
  });

  final ColorScheme colorScheme;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ColoredBox(
      color: colorScheme.surfaceContainerLowest,
      child: Center(
        child: Semantics(
          label: title,
          child: Container(
            key: const Key('map-startup-loading'),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.45),
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor,
                  blurRadius: 28,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 34,
                  height: 34,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MapLocationRequiredView extends StatelessWidget {
  const _MapLocationRequiredView({required this.controller});

  final ExploreMapViewModel controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final isBlocked =
        controller.message == ExploreMapMessage.permissionDeniedForever;
    final isServiceDisabled =
        controller.status == ExploreMapStatus.serviceDisabled;
    final canOpenSettings = isBlocked && controller.canOpenAppSettings;
    final canOpenLocationSettings =
        isServiceDisabled && controller.canOpenLocationSettings;

    return ColoredBox(
      color: scheme.surfaceContainerLowest,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Icon(
                    Icons.my_location_rounded,
                    color: scheme.primary,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  l10n.mapLocationRequiredTitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isServiceDisabled
                      ? l10n.mapServiceDisabled
                      : l10n.mapLocationRequiredSubtitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.68),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: canOpenLocationSettings
                      ? controller.openLocationSettings
                      : canOpenSettings
                      ? controller.openAppSettings
                      : controller.requestLocationPermission,
                  icon: const Icon(Icons.location_on_rounded),
                  label: Text(
                    canOpenLocationSettings
                        ? l10n.mapLocationSettings
                        : canOpenSettings
                        ? l10n.mapAppSettings
                        : l10n.mapGrantLocation,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CollapsedSourceAttribution extends StatefulWidget {
  const _CollapsedSourceAttribution({
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    this.alignment = Alignment.bottomRight,
    this.showMapLibre = true,
  });

  final EdgeInsets padding;
  final Alignment alignment;
  final bool showMapLibre;

  @override
  State<_CollapsedSourceAttribution> createState() =>
      _CollapsedSourceAttributionState();
}

class _CollapsedSourceAttributionState
    extends State<_CollapsedSourceAttribution> {
  bool _expanded = false;
  MapCamera? _initMapCamera;

  @override
  Widget build(BuildContext context) {
    final style = MapController.maybeOf(context)?.style;
    final camera = MapCamera.maybeOf(context);
    if (style == null || camera == null) {
      return const SizedBox.shrink();
    }

    _initMapCamera ??= camera;
    if (_expanded && _initMapCamera != camera) {
      _initMapCamera = null;
      _expanded = false;
    }

    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final attributions = [
      if (widget.showMapLibre) '<a href="https://maplibre.org/">MapLibre</a>',
      ...style.getAttributionsSync(),
    ];

    return SafeArea(
      child: Container(
        alignment: widget.alignment,
        padding: widget.padding,
        child: PointerInterceptor(
          child: Container(
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_expanded)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5, top: 5, left: 10),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: size.width / 2),
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 2,
                        runSpacing: 2,
                        children: attributions
                            .map(_MapAttributionHtml.new)
                            .toList(growable: false),
                      ),
                    ),
                  ),
                SizedBox.square(
                  dimension: 30,
                  child: IconButton(
                    onPressed: () => setState(() {
                      _initMapCamera = null;
                      _expanded = !_expanded;
                    }),
                    icon: const Icon(Icons.info, size: 18),
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MapAttributionHtml extends StatefulWidget {
  const _MapAttributionHtml(this.html);

  final String html;

  @override
  State<_MapAttributionHtml> createState() => _MapAttributionHtmlState();
}

class _MapAttributionHtmlState extends State<_MapAttributionHtml> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    var textStyle = Theme.of(context).textTheme.bodySmall;
    if (_hovering) {
      textStyle = textStyle?.copyWith(decoration: TextDecoration.underline);
    }

    final textSpans = <TextSpan>[];
    final document = html_parser.parse(widget.html);

    for (final node in document.body?.nodes ?? const <dom.Node>[]) {
      if (node is dom.Text) {
        textSpans.add(TextSpan(text: node.text));
      } else if (node is dom.Element && node.localName == 'a') {
        textSpans.add(
          TextSpan(
            onEnter: (_) => setState(() => _hovering = true),
            onExit: (_) => setState(() => _hovering = false),
            text: node.text,
            style: textStyle,
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                final href = node.attributes['href'];
                if (href != null) {
                  launchUrl(Uri.parse(href));
                }
              },
          ),
        );
      }
    }

    return RichText(
      text: TextSpan(style: textStyle, children: textSpans),
    );
  }
}

class _CurrentLocationMarker extends StatelessWidget {
  const _CurrentLocationMarker({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
            color: theme.shadowColor,
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
    final theme = Theme.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Container(
      key: const Key('map-message-banner'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: theme.shadowColor, blurRadius: 4)],
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
                onPressed: controller.requestLocationPermission,
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      key: const Key('map-message-banner'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: theme.shadowColor, blurRadius: 4)],
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
    final theme = Theme.of(context);
    final themeColors =
        theme.extension<LocarioThemeColors>() ??
        const LocarioThemeColors(onScrim: Colors.white);

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
                color: theme.shadowColor,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: themeColors.onScrim, size: 22),
        ),
      ),
    );
  }
}

class _EventMarkerImageBadge extends StatelessWidget {
  const _EventMarkerImageBadge({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Image.network(
              imageUrl,
              width: 44,
              height: 44,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                color: theme.colorScheme.surfaceContainerHigh,
                child: Icon(
                  Icons.place_rounded,
                  color: theme.colorScheme.onSurface,
                  size: 22,
                ),
              ),
            ),
          ),
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
    final l10n = AppLocalizations.of(context);

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
