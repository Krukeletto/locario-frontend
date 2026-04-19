import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:locario/l10n/app_localizations.dart';

import '../../shared/events/event_repository.dart';
import '../../shared/location/location_service.dart';
import '../../shared/map/style_repository.dart';
import '../../shared/widgets/state_panel.dart';
import 'explore_area_controller.dart';
import 'explore_controller.dart';
import 'explore_state.dart';
import 'map_view_model.dart';
import 'models.dart';
import 'widgets/advanced_filter_sheet.dart';
import 'widgets/area_picker.dart';
import 'widgets/header.dart';
import 'widgets/list_view.dart';
import 'widgets/map_view.dart';
import 'widgets/search_this_area_button.dart';
import '../../shared/events/category_scope.dart';
import '../shell/header/header_controller.dart';
import '../shell/header/header_scope.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({
    super.key,
    this.controller,
    this.mapViewModel,
    this.areaController,
    this.styleRepository,
    this.headerController,
    this.eventRefreshSignal,
    this.autoRefreshInterval = const Duration(minutes: 5),
  });

  final ExploreController? controller;
  final ExploreMapViewModel? mapViewModel;
  final ExploreAreaController? areaController;
  final MapStyleRepository? styleRepository;
  final ShellHeaderController? headerController;
  final Stream<void>? eventRefreshSignal;
  final Duration autoRefreshInterval;

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  late final ExploreController _exploreController;
  late final ExploreMapViewModel _mapViewModel;
  late final ExploreAreaController _areaController;
  late final MapStyleRepository _styleRepository;
  late final ShellHeaderController _internalHeaderController;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  StreamSubscription<void>? _refreshSubscription;
  Timer? _autoRefreshTimer;
  LatLng? _lastSearchedLocation;
  int? _pendingMapSearchRadiusMeters;
  int? _appliedMapSearchRadiusMeters;

  bool _isMinLoadingElapsed = true;
  Timer? _loadingTimer;
  bool _isEmptyResultsNoticeDismissed = false;

  ShellHeaderController? _activeHeaderController;

  @override
  void initState() {
    super.initState();

    // Initialize or use provided dependencies
    _areaController = widget.areaController ?? ExploreAreaController();

    _exploreController =
        widget.controller ??
        ExploreController(eventRepository: HttpEventRepository());

    _mapViewModel =
        widget.mapViewModel ??
        ExploreMapViewModel(locationService: GeolocatorLocationService());

    _styleRepository = widget.styleRepository ?? const MapStyleRepository();
    _internalHeaderController =
        widget.headerController ?? ShellHeaderController();

    _searchFocusNode.addListener(_handleSearchFocusChanged);
    _exploreController.addListener(_handleStateChanged);
    _areaController.addListener(_handleAreaChanged);
    _mapViewModel.addListener(_handleMapViewModelChanged);

    _refreshSubscription = widget.eventRefreshSignal?.listen((_) {
      _exploreController.loadEvents(forceRefresh: true);
    });

    _autoRefreshTimer = Timer.periodic(widget.autoRefreshInterval, (_) {
      if (mounted) {
        _exploreController.loadEvents();
      }
    });

    _exploreController.loadEvents();
    _mapViewModel.loadInitialLocation();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newHeaderController =
        ShellHeaderScope.maybeOf(context) ?? _internalHeaderController;
    if (newHeaderController != _activeHeaderController) {
      _activeHeaderController?.removeListener(_handleHeaderChanged);
      _activeHeaderController = newHeaderController;
      _activeHeaderController?.addListener(_handleHeaderChanged);
      _syncControllerParams();
    }
  }

  @override
  void dispose() {
    _searchFocusNode.removeListener(_handleSearchFocusChanged);
    _exploreController.removeListener(_handleStateChanged);
    _areaController.removeListener(_handleAreaChanged);
    _mapViewModel.removeListener(_handleMapViewModelChanged);
    _activeHeaderController?.removeListener(_handleHeaderChanged);

    // Dispose only if created internally
    if (widget.areaController == null) _areaController.dispose();
    if (widget.controller == null) _exploreController.dispose();
    if (widget.mapViewModel == null) _mapViewModel.dispose();
    if (widget.headerController == null) _internalHeaderController.dispose();

    _searchController.dispose();
    _searchFocusNode.dispose();
    _refreshSubscription?.cancel();
    _autoRefreshTimer?.cancel();
    _loadingTimer?.cancel();
    super.dispose();
  }

  void _syncControllerParams() {
    if (!mounted) return;

    _exploreController.updateSearchQuery(_searchController.text);
    _exploreController.updateReferenceLocation(
      _areaController.referenceLocation(
        currentLocation: _mapViewModel.currentLocation,
        fallbackCenter: _mapViewModel.mapCenter,
      ),
    );
    final isMapView =
        (_activeHeaderController ?? _internalHeaderController).selectedView ==
        ExploreContentView.map;
    _exploreController.updateDistanceOverride(
      isMapView ? _appliedMapSearchRadiusMeters : null,
    );

    if (!mounted) return;

    if (_activeHeaderController != null) {
      final available = CategoryScope.maybeOf(context)?.categories ?? [];
      final categories = _activeHeaderController!.selectedFilterIndices
          .where((i) => i > 0 && (i - 1) < available.length)
          .map((i) => available[i - 1]);
      _exploreController.updateCategories(categories.cast<Category>().toList());
    }
  }

  void _handleHeaderChanged() {
    _syncControllerParams();
  }

  LatLng _currentSearchAreaCenter() {
    return _areaController.referenceLocation(
      currentLocation: _mapViewModel.currentLocation,
      fallbackCenter: _mapViewModel.mapCenter,
    );
  }

  void _markCurrentAreaAsSearched({bool force = false}) {
    if (_lastSearchedLocation != null && !force) {
      return;
    }
    _lastSearchedLocation = _currentSearchAreaCenter();
    _appliedMapSearchRadiusMeters ??= _pendingMapSearchRadiusMeters;
  }

  void _handleStateChanged() {
    if (_exploreController.state is! ExploreEmpty &&
        _isEmptyResultsNoticeDismissed) {
      _isEmptyResultsNoticeDismissed = false;
    }
    if (_exploreController.state is ExploreLoading ||
        _exploreController.state is ExploreDataLoading) {
      _startLoadingTimer();
    } else {
      _isMinLoadingElapsed = true;
      _loadingTimer?.cancel();
    }
    setState(() {});
  }

  void _handleMapViewModelChanged() {
    _syncControllerParams();
    _markCurrentAreaAsSearched();
    if (mounted) {
      setState(() {});
      // If we just got a location and haven't loaded events yet, or if we need to refresh
      if (_mapViewModel.currentLocation != null &&
          _exploreController.state is ExploreLoading) {
        _exploreController.loadEvents();
      }
    }
  }

  void _startLoadingTimer() {
    _isMinLoadingElapsed = false;
    _loadingTimer?.cancel();
    _loadingTimer = Timer(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() => _isMinLoadingElapsed = true);
      }
    });
  }

  void _handleAreaChanged() {
    _syncControllerParams();
    _markCurrentAreaAsSearched(force: true);
    setState(() {});
  }

  void _handleSearchFocusChanged() {
    setState(() {});
  }

  void _handleSearchChanged(String query) {
    _exploreController.updateSearchQuery(query);
  }

  void _dismissSearchFocus() {
    if (_searchFocusNode.hasFocus) {
      _searchFocusNode.unfocus();
    }
  }

  void _handleSearchCleared() {
    _searchController.clear();
    _exploreController.updateSearchQuery('');
  }

  void _handleSearchResultSelected(ExploreEvent event) {
    _dismissSearchFocus();
    _handleEventTap(event);
  }

  bool get _showSearchThisArea {
    if (_areaController.isPickingAreaOnMap) return false;
    if (_lastSearchedLocation == null) return false;
    final current = _mapViewModel.mapCenter;
    const distance = Distance();
    final centerChanged =
        distance.as(LengthUnit.Meter, _lastSearchedLocation!, current) > 500;
    final appliedRadius = _appliedMapSearchRadiusMeters;
    final pendingRadius = _pendingMapSearchRadiusMeters;
    final radiusChanged =
        appliedRadius != null &&
        pendingRadius != null &&
        (pendingRadius - appliedRadius).abs() >
            ((appliedRadius * 0.15).round().clamp(250, 5000));
    return centerChanged || radiusChanged;
  }

  Future<void> _handleFilterPressed() async {
    final result = await showModalBottomSheet<ExploreAdvancedFilterResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => ExploreAdvancedFilterSheet(
        initialFilters: _exploreController.advancedFilters,
        areaController: _areaController,
      ),
    );

    if (mounted && result != null) {
      _exploreController.updateAdvancedFilters(result.filters);
      if (result.shouldPickOnMap) {
        final headerController =
            _activeHeaderController ?? _internalHeaderController;
        headerController.setSelectedView(ExploreContentView.map);
        _areaController.startMapPicking();
      }
    }
  }

  void _handleEventTap(ExploreEvent event) {
    context.push('/events/${event.id}');
  }

  @override
  Widget build(BuildContext context) {
    final state = _exploreController.state;
    final headerController =
        _activeHeaderController ?? _internalHeaderController;
    final includeHeaderTopInset = ShellHeaderScope.maybeOf(context) == null;

    return ListenableBuilder(
      listenable: headerController,
      builder: (context, _) {
        final currentView = headerController.selectedView;

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: ExploreHeader(
            searchController: _searchController,
            searchFocusNode: _searchFocusNode,
            onFilterPressed: () {
              _dismissSearchFocus();
              _handleFilterPressed();
            },
            includeTopInset: includeHeaderTopInset,
            searchResults: _exploreController.searchResults,
            activeFiltersCount:
                _exploreController.advancedFilters.activeFiltersCount,
            onSearchChanged: _handleSearchChanged,
            onSearchResultSelected: _handleSearchResultSelected,
            onSearchCleared: _handleSearchCleared,
            selectedFilterIndices: headerController.selectedFilterIndices,
            availableCategories:
                (CategoryScope.maybeOf(context)?.categories ?? [])
                    .cast<Category>()
                    .toList(),
            onFilterToggled: (index) {
              _dismissSearchFocus();
              headerController.toggleFilter(index);
            },
          ),
          body: Stack(
            children: [
              _buildContent(context, state, currentView),
              if (_areaController.isPickingAreaOnMap)
                ExploreMapAreaPickerOverlay(
                  title: AppLocalizations.of(context)!.areaPickOnMapTitle,
                  subtitle: AppLocalizations.of(context)!.areaPickOnMapSubtitle,
                  cancelLabel: AppLocalizations.of(context)!.areaDialogCancel,
                  confirmLabel: AppLocalizations.of(context)!.areaDialogConfirm,
                  onCancel: _areaController.cancelMapPicking,
                  onConfirm: () {
                    final center = _areaController.confirmMapPicking(
                      _mapViewModel.mapCenter,
                    );
                    _appliedMapSearchRadiusMeters =
                        _pendingMapSearchRadiusMeters;
                    _mapViewModel.setPreferredMapCenter(center);
                  },
                ),
              if (state is ExploreDataLoading && !_isMinLoadingElapsed)
                const _LoadingOverlay(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    ExploreState state,
    ExploreContentView currentView,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final effectiveView = _areaController.isPickingAreaOnMap
        ? ExploreContentView.map
        : currentView;

    return switch (state) {
      ExploreLoading() => StatePanel.loading(
        title: l10n.exploreLoadingTitle,
        subtitle: l10n.exploreLoadingSubtitle,
      ),
      ExploreError(type: var type, details: var details) => StatePanel.error(
        title: _errorTitle(type, l10n),
        subtitle: _errorSubtitle(type, l10n, details),
        retryLabel: l10n.exploreRetryButton,
        onRetry: () => _exploreController.loadEvents(forceRefresh: true),
      ),
      ExploreEmpty() => _buildMainUI(
        const [],
        effectiveView,
        showEmptyResultsMessage: true,
      ),
      ExploreData(events: var events) => _buildMainUI(events, effectiveView),
      ExploreDataLoading(previous: var previous) => _buildMainUI(
        previous,
        effectiveView,
      ),
    };
  }

  Widget _buildMainUI(
    List<ExploreEvent> events,
    ExploreContentView currentView, {
    bool showEmptyResultsMessage = false,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final referenceLocation =
        _exploreController.referenceLocation ?? const LatLng(0, 0);
    final searchRadiusMeters =
        _areaController.selectionMode == ExploreAreaSelectionMode.mapPin
        ? _appliedMapSearchRadiusMeters ??
              _exploreController.distanceOverrideMeters ??
              _exploreController
                  .advancedFilters
                  .distanceFilter
                  .maxDistanceMeters
        : null;
    final topContentOffset = (ShellHeaderScope.maybeOf(context) == null)
        ? MediaQuery.paddingOf(context).top + 112
        : 112.0;
    final content = currentView == ExploreContentView.map
        ? Stack(
            children: [
              ExploreMapView(
                controller: _mapViewModel,
                styleRepository: _styleRepository,
                events: events,
                referenceLocation: referenceLocation,
                searchRadiusMeters: searchRadiusMeters,
                onEventTap: _handleEventTap,
                onCameraCenterChanged: _mapViewModel.setPreferredMapCenter,
                onVisibleRadiusChanged: (radiusMeters) {
                  if (_pendingMapSearchRadiusMeters == radiusMeters) {
                    return;
                  }
                  setState(() {
                    _pendingMapSearchRadiusMeters = radiusMeters;
                  });
                },
              ),
              if (_showSearchThisArea)
                Positioned(
                  top: 16,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: SearchThisAreaButton(
                      onPressed: () {
                        _areaController.searchInArea(_mapViewModel.mapCenter);
                        _appliedMapSearchRadiusMeters =
                            _pendingMapSearchRadiusMeters;
                        _syncControllerParams();
                        _markCurrentAreaAsSearched(force: true);
                        _exploreController.loadEvents(forceRefresh: true);
                      },
                    ),
                  ),
                ),
              if (showEmptyResultsMessage)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surface.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.outline.withValues(alpha: 0.14),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: StatePanel.empty(
                              title: l10n.exploreEmptyTitle,
                              subtitle: l10n.exploreEmptySubtitle,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          )
        : Stack(
            children: [
              ExploreListView(
                events: events,
                referenceLocation: referenceLocation,
                selectedFilterSummary:
                    _exploreController.selectedCategories.isEmpty
                    ? l10n.filterAll
                    : _exploreController.selectedCategories
                          .map((c) => c.name)
                          .join(', '),
                selectedSort: _exploreController.selectedSort,
                sortAscending: _exploreController.sortAscending,
                isSearchActive: _searchFocusNode.hasFocus,
                onSortOpened: _dismissSearchFocus,
                onSortChanged: (sort) {
                  _dismissSearchFocus();
                  _exploreController.updateSort(sort);
                },
                onSortOrderToggled: _exploreController.toggleSortOrder,
                onEventTap: (event) {
                  _dismissSearchFocus();
                  _handleEventTap(event);
                },
              ),
            ],
          );

    return Column(
      children: [
        SizedBox(height: topContentOffset),
        Expanded(child: content),
      ],
    );
  }

  String _errorTitle(ExploreErrorType type, AppLocalizations l10n) {
    return switch (type) {
      ExploreErrorType.network => l10n.networkError,
      ExploreErrorType.permission => l10n.exploreErrorPermissionTitle,
      ExploreErrorType.unknown => l10n.exploreErrorUnknownTitle,
    };
  }

  String _errorSubtitle(
    ExploreErrorType type,
    AppLocalizations l10n,
    String? details,
  ) {
    return switch (type) {
      ExploreErrorType.network => l10n.exploreErrorSubtitle,
      ExploreErrorType.permission => l10n.exploreErrorPermissionSubtitle,
      ExploreErrorType.unknown => details ?? l10n.exploreErrorUnknownSubtitle,
    };
  }
}

class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.only(top: 112), // Below header
        child: Material(
          color: Colors.transparent,
          child: const SizedBox(height: 3, child: LinearProgressIndicator()),
        ),
      ),
    );
  }
}
