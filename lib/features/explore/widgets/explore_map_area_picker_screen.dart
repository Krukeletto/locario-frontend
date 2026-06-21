import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:locario/l10n/app_localizations.dart';

import '../../../shared/map/style_repository.dart';
import '../map_view_model.dart';
import 'area_picker.dart';
import 'map_widget.dart';

class ExploreMapAreaPickerScreen extends StatefulWidget {
  const ExploreMapAreaPickerScreen({
    super.key,
    required this.controller,
    required this.initialCenter,
    this.styleRepository = const MapStyleRepository(),
  });

  final ExploreMapViewModel controller;
  final LatLng initialCenter;
  final MapStyleRepository styleRepository;

  @override
  State<ExploreMapAreaPickerScreen> createState() =>
      _ExploreMapAreaPickerScreenState();
}

class _ExploreMapAreaPickerScreenState
    extends State<ExploreMapAreaPickerScreen> {
  bool _confirmed = false;

  @override
  void initState() {
    super.initState();
    widget.controller.setPreferredMapCenter(widget.initialCenter);
  }

  @override
  void dispose() {
    if (!_confirmed) {
      widget.controller.setPreferredMapCenter(widget.initialCenter);
    }
    super.dispose();
  }

  void _handleCameraCenterChanged(LatLng center) {
    if (!mounted) {
      return;
    }
    widget.controller.setPreferredMapCenter(center);
  }

  void _cancel() {
    Navigator.of(context).maybePop();
  }

  void _confirm() {
    _confirmed = true;
    Navigator.of(context).pop(widget.controller.mapCenter);
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
            controller: widget.controller,
            styleRepository: widget.styleRepository,
            events: const [],
            onEventTap: (_) {},
            onCameraCenterChanged: _handleCameraCenterChanged,
            overlayPadding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
            attributionAlignment: Alignment.bottomRight,
            attributionPadding: const EdgeInsets.only(right: 8, bottom: 8),
            recenterAlignment: Alignment.topRight,
            recenterPadding: const EdgeInsets.only(right: 16, top: 80),
            showSearchRadiusOverlay: false,
            requireLocation: false,
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
                  tooltip: l10n.areaDialogCancel,
                  onPressed: _cancel,
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
            onCancel: _cancel,
            onConfirm: _confirm,
          ),
        ],
      ),
    );
  }
}
