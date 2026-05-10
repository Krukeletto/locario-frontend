import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:locario/l10n/app_localizations.dart';

import '../../../shared/location/location_service.dart';
import '../../../shared/map/style_repository.dart';
import '../../explore/map_view_model.dart';
import '../../explore/widgets/area_picker.dart';
import '../../explore/widgets/map_widget.dart';

class EventMapPickerScreen extends StatefulWidget {
  const EventMapPickerScreen({
    super.key,
    required this.locationService,
    this.initialCenter,
    this.styleRepository = const MapStyleRepository(),
  });

  final LocationService locationService;
  final LatLng? initialCenter;
  final MapStyleRepository styleRepository;

  @override
  State<EventMapPickerScreen> createState() => _EventMapPickerScreenState();
}

class _EventMapPickerScreenState extends State<EventMapPickerScreen> {
  late final ExploreMapViewModel _controller;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _controller = ExploreMapViewModel(
      locationService: widget.locationService,
      fallbackCenter: widget.initialCenter ?? const LatLng(0, 0),
    );
    if (widget.initialCenter != null) {
      _controller.setPreferredMapCenter(widget.initialCenter);
    }
    _controller.loadInitialLocation();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _controller.dispose();
    super.dispose();
  }

  void _handleCameraCenterChanged(LatLng center) {
    if (!mounted || _isDisposed) {
      return;
    }
    _controller.setPreferredMapCenter(center);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: Stack(
        children: [
          MapWidget(
            controller: _controller,
            styleRepository: widget.styleRepository,
            events: const [],
            onEventTap: (_) {},
            onCameraCenterChanged: _handleCameraCenterChanged,
            overlayPadding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
            attributionAlignment: Alignment.bottomRight,
            attributionPadding: const EdgeInsets.only(right: 8, bottom: 8),
            recenterAlignment: Alignment.topRight,
            recenterPadding: const EdgeInsets.only(right: 16, top: 80),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 16, top: 8),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHigh,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
            ),
          ),
          ExploreMapAreaPickerOverlay(
            title: l10n.areaPickOnMapTitle,
            subtitle: l10n.areaPickOnMapSubtitle,
            cancelLabel: l10n.areaDialogCancel,
            confirmLabel: l10n.areaPickOnMapConfirm,
            onCancel: () => Navigator.of(context).maybePop(),
            onConfirm: () => Navigator.of(context).pop(_controller.mapCenter),
          ),
        ],
      ),
    );
  }
}
