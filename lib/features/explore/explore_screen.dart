import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:locario/l10n/app_localizations.dart';

import '../../shared/location/location_service.dart';
import '../../shared/map/style_repository.dart';
import 'map_view_model.dart';
import 'models.dart';
import '../shell/header/header.dart';
import '../shell/header/header_controller.dart';
import '../shell/header/header_scope.dart';
import 'widgets/header.dart';
import 'widgets/list_view.dart';
import 'widgets/map_view.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({
    super.key,
    ExploreMapViewModel? controller,
    MapStyleRepository? styleRepository,
  }) : _controller = controller,
       _styleRepository = styleRepository;

  final ExploreMapViewModel? _controller;
  final MapStyleRepository? _styleRepository;

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  late final ExploreMapViewModel _controller;
  late final MapStyleRepository _styleRepository;
  late final bool _ownsController;
  late final ShellHeaderController _localHeaderController;

  ExploreSortOption _selectedSort = ExploreSortOption.distance;
  bool _isPickingAreaOnMap = false;
  String? _typedAreaLabel;
  LatLng? _selectedAreaCenter;
  LatLng? _mapViewportCenter;

  @override
  void initState() {
    super.initState();
    _ownsController = widget._controller == null;
    _controller =
        widget._controller ??
        ExploreMapViewModel(locationService: GeolocatorLocationService());
    _styleRepository = widget._styleRepository ?? const MapStyleRepository();
    _localHeaderController = ShellHeaderController();
    _controller.loadInitialLocation();
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    _localHeaderController.dispose();
    super.dispose();
  }

  ShellHeaderController get _headerController {
    final scopedController = ShellHeaderScope.maybeOf(context);
    if (scopedController != null) {
      return scopedController;
    }
    return _localHeaderController;
  }

  void _toggleFilter(int index) {
    _headerController.toggleFilter(index);
  }

  LatLng get _referenceLocation =>
      _selectedAreaCenter ??
      _controller.currentLocation ??
      _controller.mapCenter;

  Future<void> _handleAreaPressed() async {
    final l10n = AppLocalizations.of(context)!;
    final action = await showModalBottomSheet<_AreaSelectionAction>(
      context: context,
      showDragHandle: true,
      builder: (context) => _AreaSelectionSheet(
        title: l10n.areaPickerTitle,
        subtitle: l10n.areaPickerSubtitle,
        onActionSelected: (action) => Navigator.of(context).pop(action),
      ),
    );

    if (!mounted || action == null) {
      return;
    }

    switch (action) {
      case _AreaSelectionAction.currentLocation:
        setState(() {
          _typedAreaLabel = null;
          _selectedAreaCenter = null;
          _isPickingAreaOnMap = false;
        });
        _controller.setPreferredMapCenter(_controller.currentLocation);
        return;
      case _AreaSelectionAction.enterAddress:
        _promptForAddress();
        return;
      case _AreaSelectionAction.pickOnMap:
        _startMapAreaPicking();
        return;
    }
  }

  Future<void> _promptForAddress() async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: _typedAreaLabel ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        final scheme = Theme.of(context).colorScheme;
        return AlertDialog(
          title: Text(l10n.areaAddressDialogTitle),
          content: TextField(
            controller: controller,
            autofocus: true,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: l10n.areaAddressDialogHint,
              filled: true,
              fillColor: scheme.surfaceContainerLow,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
            onSubmitted: (value) => Navigator.of(context).pop(value.trim()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.areaDialogCancel),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(controller.text.trim()),
              child: Text(l10n.areaDialogConfirm),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (!mounted || result == null || result.isEmpty) {
      return;
    }

    try {
      final locations = await locationFromAddress(result);
      if (!mounted) {
        return;
      }

      if (locations.isEmpty) {
        _showAddressLookupMessage(l10n.areaAddressNotFound);
        return;
      }

      final location = locations.first;
      final center = LatLng(location.latitude, location.longitude);
      setState(() {
        _typedAreaLabel = result;
        _selectedAreaCenter = center;
        _isPickingAreaOnMap = false;
      });
      _controller.setPreferredMapCenter(center);
    } catch (_) {
      if (!mounted) {
        return;
      }

      _showAddressLookupMessage(l10n.areaAddressLookupFailed);
    }
  }

  void _startMapAreaPicking() {
    _headerController.setSelectedView(ExploreContentView.map);
    setState(() {
      _isPickingAreaOnMap = true;
    });
  }

  void _cancelMapAreaPicking() {
    setState(() {
      _isPickingAreaOnMap = false;
    });
    _headerController.setSelectedView(ExploreContentView.list);
  }

  void _confirmMapAreaPicking() {
    final selectedCenter = _mapViewportCenter ?? _controller.mapCenter;
    setState(() {
      _typedAreaLabel = null;
      _selectedAreaCenter = selectedCenter;
      _isPickingAreaOnMap = false;
    });
    _controller.setPreferredMapCenter(selectedCenter);
    _headerController.setSelectedView(ExploreContentView.list);
  }

  ExploreAreaSelection _selectedArea(AppLocalizations l10n) {
    final typedAreaLabel = _typedAreaLabel;
    if (typedAreaLabel != null && typedAreaLabel.isNotEmpty) {
      return buildTypedAddressAreaSelection(
        l10n,
        address: typedAreaLabel,
        center: _selectedAreaCenter,
      );
    }

    final selectedAreaCenter = _selectedAreaCenter;
    if (selectedAreaCenter != null) {
      return buildPinnedAreaSelection(l10n, center: selectedAreaCenter);
    }

    return buildCurrentLocationAreaSelection(l10n);
  }

  void _showAddressLookupMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final headerController = _headerController;
    final l10n = AppLocalizations.of(context)!;
    final filters = buildExploreFilters(l10n);
    final allFilter = filters.firstWhere(
      (filter) => filter.category == ExploreCategory.all,
    );
    final selectedArea = _selectedArea(l10n);

    return AnimatedBuilder(
      animation: headerController,
      builder: (context, _) {
        final selectedFilters = _selectedFilters(filters);
        final selectedFilterSummary = _selectedFilterSummary(
          selectedFilters,
          allFilter,
        );
        final visibleEvents = _visibleEvents(selectedFilters, l10n);
        final referenceLocation = _referenceLocation;
        final showShellHeader = ShellHeaderScope.maybeOf(context) == null;

        return Scaffold(
          body: ColoredBox(
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              children: [
                if (showShellHeader)
                  ShellHeader(
                    selectedView: headerController.selectedView,
                    onViewChanged: headerController.setSelectedView,
                  ),
                ExploreHeader(
                  selectedFilterIndices: headerController.selectedFilterIndices,
                  filters: filters,
                  onFilterToggled: _toggleFilter,
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 260),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.03, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child:
                        headerController.selectedView == ExploreContentView.map
                        ? Stack(
                            key: const ValueKey('explore-map-view'),
                            children: [
                              ExploreMapView(
                                controller: _controller,
                                styleRepository: _styleRepository,
                                events: visibleEvents,
                                onCameraCenterChanged: (center) {
                                  _mapViewportCenter = center;
                                },
                              ),
                              if (_isPickingAreaOnMap)
                                _MapAreaPickerOverlay(
                                  title: l10n.areaPickOnMapTitle,
                                  subtitle: l10n.areaPickOnMapSubtitle,
                                  cancelLabel: l10n.areaDialogCancel,
                                  confirmLabel: l10n.areaPickOnMapConfirm,
                                  onCancel: _cancelMapAreaPicking,
                                  onConfirm: _confirmMapAreaPicking,
                                ),
                            ],
                          )
                        : ExploreListView(
                            key: const ValueKey('explore-list-view'),
                            events: visibleEvents,
                            referenceLocation: referenceLocation,
                            selectedFilterSummary: selectedFilterSummary,
                            selectedArea: selectedArea,
                            selectedSort: _selectedSort,
                            onAreaPressed: _handleAreaPressed,
                            onSortChanged: (sort) {
                              setState(() {
                                _selectedSort = sort;
                              });
                            },
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<ExploreFilter> _selectedFilters(List<ExploreFilter> filters) {
    final selected = _headerController.selectedFilterIndices.toList()..sort();
    return selected.map((index) => filters[index]).toList();
  }

  String _selectedFilterSummary(
    List<ExploreFilter> filters,
    ExploreFilter allFilter,
  ) {
    if (filters.isEmpty ||
        (filters.length == 1 && filters.first.category == allFilter.category)) {
      return allFilter.label;
    }

    return filters.map((filter) => filter.label).join(' + ');
  }

  List<ExploreEvent> _visibleEvents(
    List<ExploreFilter> selectedFilters,
    AppLocalizations l10n,
  ) {
    final selectedCategories = selectedFilters
        .where((filter) => filter.category != ExploreCategory.all)
        .map((filter) => filter.category)
        .toSet();
    Iterable<ExploreEvent> events = buildExploreEvents(l10n);

    if (selectedCategories.isNotEmpty) {
      events = events.where(
        (event) => selectedCategories.contains(event.category),
      );
    }

    final sorted = events.toList();
    final referenceLocation = _referenceLocation;
    if (_selectedSort == ExploreSortOption.distance) {
      sorted.sort(
        (a, b) => a
            .distanceMetersFrom(referenceLocation)
            .compareTo(b.distanceMetersFrom(referenceLocation)),
      );
    } else if (_selectedSort == ExploreSortOption.soonest) {
      sorted.sort((a, b) => a.timeLabel.compareTo(b.timeLabel));
    } else {
      sorted.sort(
        (a, b) => b
            .distanceMetersFrom(referenceLocation)
            .compareTo(a.distanceMetersFrom(referenceLocation)),
      );
    }

    return sorted;
  }
}

enum _AreaSelectionAction { currentLocation, enterAddress, pickOnMap }

class _AreaSelectionSheet extends StatelessWidget {
  const _AreaSelectionSheet({
    required this.title,
    required this.subtitle,
    required this.onActionSelected,
  });

  final String title;
  final String subtitle;
  final ValueChanged<_AreaSelectionAction> onActionSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: scheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.72),
                ),
              ),
              const SizedBox(height: 16),
              _AreaSelectionActionTile(
                icon: Icons.my_location_rounded,
                title: l10n.areaUseCurrentLocation,
                subtitle: l10n.areaUseCurrentLocationSubtitle,
                onTap: () =>
                    onActionSelected(_AreaSelectionAction.currentLocation),
              ),
              const SizedBox(height: 10),
              _AreaSelectionActionTile(
                icon: Icons.search_rounded,
                title: l10n.areaEnterAddress,
                subtitle: l10n.areaEnterAddressSubtitle,
                onTap: () =>
                    onActionSelected(_AreaSelectionAction.enterAddress),
              ),
              const SizedBox(height: 10),
              _AreaSelectionActionTile(
                icon: Icons.place_rounded,
                title: l10n.areaPickOnMap,
                subtitle: l10n.areaPickOnMapSubtitle,
                onTap: () => onActionSelected(_AreaSelectionAction.pickOnMap),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AreaSelectionActionTile extends StatelessWidget {
  const _AreaSelectionActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

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
                color: scheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: scheme.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.72),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: scheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _MapAreaPickerOverlay extends StatelessWidget {
  const _MapAreaPickerOverlay({
    required this.title,
    required this.subtitle,
    required this.cancelLabel,
    required this.confirmLabel,
    required this.onCancel,
    required this.onConfirm,
  });

  final String title;
  final String subtitle;
  final String cancelLabel;
  final String confirmLabel;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Stack(
      children: [
        IgnorePointer(
          child: Center(
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: scheme.primary,
                shape: BoxShape.circle,
                border: Border.all(color: scheme.onPrimary, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.22),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh.withValues(alpha: 0.96),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: scheme.outline.withValues(alpha: 0.18)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.72),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onCancel,
                  child: Text(cancelLabel),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: onConfirm,
                  child: Text(confirmLabel),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
