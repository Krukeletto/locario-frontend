import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:locario/l10n/app_localizations.dart';

import '../../shared/location/location_service.dart';
import '../../shared/map/style_repository.dart';
import 'explore_area_controller.dart';
import 'explore_event_query.dart';
import 'map_view_model.dart';
import 'models.dart';
import '../shell/header/header.dart';
import '../shell/header/header_controller.dart';
import '../shell/header/header_scope.dart';
import 'widgets/area_picker.dart';
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
  late final TextEditingController _searchController;
  late final ExploreAreaController _areaController;
  final ExploreEventQuery _eventQuery = const ExploreEventQuery();

  ExploreSortOption _selectedSort = ExploreSortOption.distance;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _ownsController = widget._controller == null;
    _controller =
        widget._controller ??
        ExploreMapViewModel(locationService: GeolocatorLocationService());
    _styleRepository = widget._styleRepository ?? const MapStyleRepository();
    _localHeaderController = ShellHeaderController();
    _searchController = TextEditingController();
    _areaController = ExploreAreaController();
    _controller.loadInitialLocation();
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    _searchController.dispose();
    _areaController.dispose();
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

  Future<void> _handleAreaPressed() async {
    final l10n = AppLocalizations.of(context)!;
    final action = await showModalBottomSheet<ExploreAreaSelectionAction>(
      context: context,
      showDragHandle: true,
      builder: (context) => ExploreAreaSelectionSheet(
        title: l10n.areaPickerTitle,
        subtitle: l10n.areaPickerSubtitle,
        onActionSelected: (action) => Navigator.of(context).pop(action),
      ),
    );

    if (!mounted || action == null) {
      return;
    }

    switch (action) {
      case ExploreAreaSelectionAction.currentLocation:
        _areaController.selectCurrentLocation();
        _controller.setPreferredMapCenter(_controller.currentLocation);
        return;
      case ExploreAreaSelectionAction.enterAddress:
        await _promptForAddress();
        return;
      case ExploreAreaSelectionAction.pickOnMap:
        _startMapAreaPicking();
        return;
    }
  }

  Future<void> _promptForAddress() async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showDialog<String>(
      context: context,
      builder: (context) => const ExploreAddressInputDialog(),
    );

    if (!mounted || result == null || result.isEmpty) {
      return;
    }

    final lookupResult = await _areaController.selectAddress(result);
    if (!mounted) {
      return;
    }

    switch (lookupResult.status) {
      case ExploreAddressLookupStatus.notFound:
        _showAddressLookupMessage(l10n.areaAddressNotFound);
        return;
      case ExploreAddressLookupStatus.error:
        _showAddressLookupMessage(l10n.areaAddressLookupFailed);
        return;
      case ExploreAddressLookupStatus.success:
        _controller.setPreferredMapCenter(lookupResult.center);
    }
  }

  void _startMapAreaPicking() {
    _headerController.setSelectedView(ExploreContentView.map);
    _areaController.startMapPicking();
  }

  void _cancelMapAreaPicking() {
    _areaController.cancelMapPicking();
    _headerController.setSelectedView(ExploreContentView.list);
  }

  void _confirmMapAreaPicking() {
    final selectedCenter = _areaController.confirmMapPicking(
      _controller.mapCenter,
    );
    _controller.setPreferredMapCenter(selectedCenter);
    _headerController.setSelectedView(ExploreContentView.list);
  }

  void _showAddressLookupMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _handleSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
  }

  void _handleSearchResultSelected(ExploreEvent event) {
    _searchController.value = TextEditingValue(
      text: event.title,
      selection: TextSelection.collapsed(offset: event.title.length),
    );
    setState(() {
      _searchQuery = event.title;
    });

    if (_headerController.selectedView == ExploreContentView.map) {
      _controller.setPreferredMapCenter(event.location);
      _areaController.updateViewportCenter(event.location);
    }
  }

  void _openEvent(ExploreEvent event) {
    context.push('/events/${Uri.encodeComponent(event.id)}');
  }

  @override
  Widget build(BuildContext context) {
    final headerController = _headerController;
    final l10n = AppLocalizations.of(context)!;
    final filters = buildExploreFilters(l10n);
    final allFilter = filters.firstWhere(
      (filter) => filter.category == ExploreCategory.all,
    );

    return AnimatedBuilder(
      animation: Listenable.merge([headerController, _areaController]),
      builder: (context, _) {
        final selectedFilters = _selectedFilters(filters);
        final selectedFilterSummary = _selectedFilterSummary(
          selectedFilters,
          allFilter,
        );
        final allEvents = buildExploreEvents(l10n);
        final referenceLocation = _areaController.referenceLocation(
          currentLocation: _controller.currentLocation,
          fallbackCenter: _controller.mapCenter,
        );
        final visibleEvents = _eventQuery.visibleEvents(
          events: allEvents,
          selectedCategories: selectedFilters.map((filter) => filter.category),
          query: _searchQuery,
          sort: _selectedSort,
          referenceLocation: referenceLocation,
          l10n: l10n,
        );
        final searchResults = _eventQuery.searchResults(
          events: allEvents,
          selectedCategories: selectedFilters.map((filter) => filter.category),
          query: _searchQuery,
          sort: _selectedSort,
          referenceLocation: referenceLocation,
          l10n: l10n,
        );
        final selectedArea = _areaController.selectedArea(l10n);
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
                  searchController: _searchController,
                  searchResults: searchResults,
                  onSearchChanged: _handleSearchChanged,
                  onSearchResultSelected: _handleSearchResultSelected,
                  onSearchCleared: _clearSearch,
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
                                onEventTap: _openEvent,
                                onCameraCenterChanged: (center) {
                                  _areaController.updateViewportCenter(center);
                                },
                              ),
                              if (_areaController.isPickingAreaOnMap)
                                ExploreMapAreaPickerOverlay(
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
                            isSearchActive: _searchQuery.trim().isNotEmpty,
                            onAreaPressed: _handleAreaPressed,
                            onEventTap: _openEvent,
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
}
