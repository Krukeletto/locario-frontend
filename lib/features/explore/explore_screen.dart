import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:locario/l10n/app_localizations.dart';

import '../../shared/events/event_repository.dart';
import '../../shared/events/event_refresh_signal.dart';
import '../../shared/location/location_service.dart';
import '../../shared/map/style_repository.dart';
import '../shell/header/header.dart';
import '../shell/header/header_controller.dart';
import '../shell/header/header_scope.dart';
import 'explore_area_controller.dart';
import 'explore_event_query.dart';
import 'map_view_model.dart';
import 'models.dart';
import 'widgets/area_picker.dart';
import 'widgets/header.dart';
import 'widgets/list_view.dart';
import 'widgets/map_view.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({
    super.key,
    ExploreMapViewModel? controller,
    MapStyleRepository? styleRepository,
    EventRepository? eventRepository,
    EventRefreshSignal? eventRefreshSignal,
    Duration? autoRefreshInterval,
  }) : _controller = controller,
       _styleRepository = styleRepository,
       _eventRepository = eventRepository,
       _eventRefreshSignal = eventRefreshSignal,
       _autoRefreshInterval = autoRefreshInterval;

  final ExploreMapViewModel? _controller;
  final MapStyleRepository? _styleRepository;
  final EventRepository? _eventRepository;
  final EventRefreshSignal? _eventRefreshSignal;
  final Duration? _autoRefreshInterval;

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with WidgetsBindingObserver {
  static const _defaultAutoRefreshInterval = Duration(seconds: 60);

  late final ExploreMapViewModel _controller;
  late final MapStyleRepository _styleRepository;
  late final EventRepository _eventRepository;
  late final EventRefreshSignal _eventRefreshSignal;
  late final bool _ownsController;
  late final ShellHeaderController _localHeaderController;
  late final TextEditingController _searchController;
  late final ExploreAreaController _areaController;
  final ExploreEventQuery _eventQuery = const ExploreEventQuery();
  AppLocalizations? _l10n;
  bool _hasRequestedInitialLoad = false;
  Timer? _autoRefreshTimer;
  Future<void>? _activeEventsLoad;

  ExploreSortOption _selectedSort = ExploreSortOption.distance;
  ExploreDistanceFilter _selectedDistanceFilter = ExploreDistanceFilter.any;
  String _searchQuery = '';
  bool _isLoadingEvents = true;
  String? _eventsError;
  List<ExploreEvent> _allEvents = const [];

  @override
  void initState() {
    super.initState();
    _ownsController = widget._controller == null;
    _controller =
        widget._controller ??
        ExploreMapViewModel(locationService: GeolocatorLocationService());
    _styleRepository = widget._styleRepository ?? const MapStyleRepository();
    _eventRepository = widget._eventRepository ?? HttpEventRepository();
    _eventRefreshSignal =
        widget._eventRefreshSignal ?? globalEventRefreshSignal;
    _localHeaderController = ShellHeaderController();
    _searchController = TextEditingController();
    _areaController = ExploreAreaController();
    WidgetsBinding.instance.addObserver(this);
    _controller.loadInitialLocation();
    _eventRefreshSignal.addListener(_handleEventsChanged);
    _startAutoRefreshTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _l10n ??= AppLocalizations.of(context)!;
    if (_hasRequestedInitialLoad) {
      return;
    }

    _hasRequestedInitialLoad = true;
    _loadEvents();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _autoRefreshTimer?.cancel();
    _eventRefreshSignal.removeListener(_handleEventsChanged);
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

  Future<void> _loadEvents() async {
    return _loadEventsWithMode(showLoadingState: _allEvents.isEmpty);
  }

  Future<void> _loadEventsWithMode({required bool showLoadingState}) {
    final currentLoad = _activeEventsLoad;
    if (currentLoad != null) {
      return currentLoad;
    }

    final future = _performEventsLoad(showLoadingState: showLoadingState);
    _activeEventsLoad = future;
    return future.whenComplete(() {
      if (identical(_activeEventsLoad, future)) {
        _activeEventsLoad = null;
      }
    });
  }

  Future<void> _performEventsLoad({required bool showLoadingState}) async {
    final l10n = _l10n ?? AppLocalizations.of(context)!;
    final hasEvents = _allEvents.isNotEmpty;
    final shouldShowLoadingState = showLoadingState || !hasEvents;

    if (shouldShowLoadingState && mounted) {
      setState(() {
        _isLoadingEvents = true;
        _eventsError = null;
      });
    }

    try {
      final events = await _eventRepository.fetchEvents(l10n);
      if (!mounted) {
        return;
      }

      setState(() {
        _allEvents = events;
        _eventsError = null;
        _isLoadingEvents = false;
      });
    } on EventRepositoryException catch (error) {
      if (!mounted) {
        return;
      }

      if (shouldShowLoadingState || !hasEvents) {
        setState(() {
          _eventsError = error.message;
          _isLoadingEvents = false;
        });
      }
    } catch (_) {
      if (!mounted) {
        return;
      }

      if (shouldShowLoadingState || !hasEvents) {
        setState(() {
          _eventsError = 'unknown';
          _isLoadingEvents = false;
        });
      }
    }
  }

  void _handleEventsChanged() {
    if (!_hasRequestedInitialLoad || !mounted) {
      return;
    }

    _loadEventsWithMode(showLoadingState: _allEvents.isEmpty);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshEventsSilently();
    }
  }

  void _startAutoRefreshTimer() {
    final interval = widget._autoRefreshInterval ?? _defaultAutoRefreshInterval;
    if (interval <= Duration.zero) {
      return;
    }

    _autoRefreshTimer = Timer.periodic(interval, (_) {
      _refreshEventsSilently();
    });
  }

  void _refreshEventsSilently() {
    if (!_hasRequestedInitialLoad || !_shouldAutoRefreshNow()) {
      return;
    }

    _loadEventsWithMode(showLoadingState: false);
  }

  bool _shouldAutoRefreshNow() {
    if (!mounted || _areaController.isPickingAreaOnMap) {
      return false;
    }

    final lifecycleState = WidgetsBinding.instance.lifecycleState;
    if (lifecycleState != null && lifecycleState != AppLifecycleState.resumed) {
      return false;
    }

    try {
      final routePath = GoRouterState.of(context).uri.path;
      return routePath.startsWith('/explore');
    } catch (_) {
      return true;
    }
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
        final referenceLocation = _areaController.referenceLocation(
          currentLocation: _controller.currentLocation,
          fallbackCenter: _controller.mapCenter,
        );
        final maxDistanceMeters =
            headerController.selectedView == ExploreContentView.list
            ? _selectedDistanceFilter.maxDistanceMeters
            : null;
        final visibleEvents = _eventQuery.visibleEvents(
          events: _allEvents,
          selectedCategories: selectedFilters.map((filter) => filter.category),
          query: _searchQuery,
          sort: _selectedSort,
          referenceLocation: referenceLocation,
          l10n: l10n,
          maxDistanceMeters: maxDistanceMeters,
        );
        final searchResults = _eventQuery.searchResults(
          events: _allEvents,
          selectedCategories: selectedFilters.map((filter) => filter.category),
          query: _searchQuery,
          sort: _selectedSort,
          referenceLocation: referenceLocation,
          l10n: l10n,
          maxDistanceMeters: maxDistanceMeters,
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
                    child: _buildBody(
                      context: context,
                      l10n: l10n,
                      headerController: headerController,
                      visibleEvents: visibleEvents,
                      referenceLocation: referenceLocation,
                      selectedFilterSummary: selectedFilterSummary,
                      selectedArea: selectedArea,
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

  Widget _buildBody({
    required BuildContext context,
    required AppLocalizations l10n,
    required ShellHeaderController headerController,
    required List<ExploreEvent> visibleEvents,
    required LatLng referenceLocation,
    required String selectedFilterSummary,
    required ExploreAreaSelection selectedArea,
  }) {
    if (_isLoadingEvents) {
      return _ExploreStatePanel(
        key: const ValueKey('explore-loading-state'),
        icon: Icons.hourglass_top_rounded,
        title: l10n.exploreLoadingTitle,
        subtitle: l10n.exploreLoadingSubtitle,
        trailing: const Padding(
          padding: EdgeInsets.only(top: 12),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_eventsError != null) {
      return _ExploreStatePanel(
        key: const ValueKey('explore-error-state'),
        icon: Icons.wifi_tethering_error_rounded,
        title: l10n.exploreErrorTitle,
        subtitle: l10n.exploreErrorSubtitle,
        trailing: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: FilledButton(
            onPressed: _loadEvents,
            child: Text(l10n.exploreRetryButton),
          ),
        ),
      );
    }

    if (visibleEvents.isEmpty &&
        headerController.selectedView != ExploreContentView.map) {
      return _ExploreStatePanel(
        key: const ValueKey('explore-empty-state'),
        icon: Icons.event_busy_rounded,
        title: l10n.exploreEmptyTitle,
        subtitle: l10n.exploreEmptySubtitle,
      );
    }

    if (headerController.selectedView == ExploreContentView.map) {
      return Stack(
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
      );
    }

    return ExploreListView(
      key: const ValueKey('explore-list-view'),
      events: visibleEvents,
      referenceLocation: referenceLocation,
      selectedFilterSummary: selectedFilterSummary,
      selectedArea: selectedArea,
      selectedSort: _selectedSort,
      selectedDistanceFilter: _selectedDistanceFilter,
      isSearchActive: _searchQuery.trim().isNotEmpty,
      onAreaPressed: _handleAreaPressed,
      onEventTap: _openEvent,
      onSortChanged: (sort) {
        setState(() {
          _selectedSort = sort;
        });
      },
      onDistanceFilterChanged: (distanceFilter) {
        setState(() {
          _selectedDistanceFilter = distanceFilter;
        });
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

class _ExploreStatePanel extends StatelessWidget {
  const _ExploreStatePanel({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(icon, size: 34, color: scheme.primary),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.72),
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}
