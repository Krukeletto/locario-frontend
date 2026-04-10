import 'package:flutter/material.dart';

import '../../shared/location/location_service.dart';
import 'explore_map_style_repository.dart';
import 'explore_map_view_model.dart';
import 'explore_ui_models.dart';
import '../shell/app_header/app_header.dart';
import '../shell/app_header/app_header_controller.dart';
import '../shell/app_header/app_header_scope.dart';
import 'widgets/explore_header.dart';
import 'widgets/explore_list_view.dart';
import 'widgets/explore_map_view.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({
    super.key,
    ExploreMapViewModel? controller,
    ExploreMapStyleRepository? styleRepository,
  }) : _controller = controller,
       _styleRepository = styleRepository;

  final ExploreMapViewModel? _controller;
  final ExploreMapStyleRepository? _styleRepository;

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  late final ExploreMapViewModel _controller;
  late final ExploreMapStyleRepository _styleRepository;
  late final bool _ownsController;
  late final AppHeaderController _localHeaderController;

  ExploreSortOption _selectedSort = ExploreSortOption.distance;
  int _selectedAreaIndex = 0;

  @override
  void initState() {
    super.initState();
    _ownsController = widget._controller == null;
    _controller =
        widget._controller ??
        ExploreMapViewModel(locationService: GeolocatorLocationService());
    _styleRepository =
        widget._styleRepository ?? const ExploreMapStyleRepository();
    _localHeaderController = AppHeaderController();
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

  ExploreAreaOption get _selectedArea => exploreAreaOptions[_selectedAreaIndex];

  AppHeaderController get _headerController {
    final scopedController = AppHeaderScope.maybeOf(context);
    if (scopedController != null) {
      return scopedController;
    }
    return _localHeaderController;
  }

  List<ExploreFilter> get _selectedFilters {
    final selected = _headerController.selectedFilterIndices.toList()..sort();
    return selected.map((index) => exploreFilters[index]).toList();
  }

  String get _selectedFilterSummary {
    final filters = _selectedFilters;
    if (filters.isEmpty ||
        (filters.length == 1 && filters.first.label == 'Wszystkie')) {
      return 'Wszystkie';
    }

    return filters.map((filter) => filter.label).join(' + ');
  }

  void _toggleFilter(int index) {
    _headerController.toggleFilter(index);
  }

  void _applyAreaSelection(int nextIndex) {
    if (nextIndex < 0 || nextIndex >= exploreAreaOptions.length) {
      return;
    }

    setState(() {
      _selectedAreaIndex = nextIndex;
    });

    final selectedArea = exploreAreaOptions[nextIndex];
    if (selectedArea.usesCurrentLocation) {
      _controller.setPreferredMapCenter(_controller.currentLocation);
      return;
    }

    _controller.setPreferredMapCenter(selectedArea.center);
  }

  List<ExploreEvent> get _visibleEvents {
    final selectedCategories = _selectedFilters
        .where((filter) => filter.label != 'Wszystkie')
        .map((filter) => filter.label)
        .toSet();
    Iterable<ExploreEvent> events = exploreEvents;

    if (selectedCategories.isNotEmpty) {
      events = events.where(
        (event) => selectedCategories.contains(event.category),
      );
    }

    final sorted = events.toList();
    if (_selectedSort == ExploreSortOption.distance) {
      sorted.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
    } else if (_selectedSort == ExploreSortOption.soonest) {
      sorted.sort((a, b) => a.timeLabel.compareTo(b.timeLabel));
    } else {
      sorted.sort((a, b) => b.distanceMeters.compareTo(a.distanceMeters));
    }

    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final headerController = _headerController;

    return AnimatedBuilder(
      animation: headerController,
      builder: (context, _) {
        final visibleEvents = _visibleEvents;
        final showShellHeader = AppHeaderScope.maybeOf(context) == null;

        return Scaffold(
          body: ColoredBox(
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              children: [
                if (showShellHeader)
                  AppHeader(
                    selectedView: headerController.selectedView,
                    onViewChanged: headerController.setSelectedView,
                  ),
                ExploreHeader(
                  selectedFilterIndices: headerController.selectedFilterIndices,
                  filters: exploreFilters,
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
                        ? ExploreMapView(
                            key: const ValueKey('explore-map-view'),
                            controller: _controller,
                            styleRepository: _styleRepository,
                          )
                        : ExploreListView(
                            key: const ValueKey('explore-list-view'),
                            events: visibleEvents,
                            selectedFilterSummary: _selectedFilterSummary,
                            areaOptions: exploreAreaOptions,
                            selectedAreaIndex: _selectedAreaIndex,
                            selectedArea: _selectedArea,
                            selectedSort: _selectedSort,
                            onAreaSelected: _applyAreaSelection,
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
}
