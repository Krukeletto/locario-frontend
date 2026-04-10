import 'package:flutter/material.dart';
import 'package:locario/l10n/app_localizations.dart';

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

  AppHeaderController get _headerController {
    final scopedController = AppHeaderScope.maybeOf(context);
    if (scopedController != null) {
      return scopedController;
    }
    return _localHeaderController;
  }

  void _toggleFilter(int index) {
    _headerController.toggleFilter(index);
  }

  void _applyAreaSelection(int nextIndex, List<ExploreAreaOption> areaOptions) {
    if (nextIndex < 0 || nextIndex >= areaOptions.length) {
      return;
    }

    setState(() {
      _selectedAreaIndex = nextIndex;
    });

    final selectedArea = areaOptions[nextIndex];
    if (selectedArea.usesCurrentLocation) {
      _controller.setPreferredMapCenter(_controller.currentLocation);
      return;
    }

    _controller.setPreferredMapCenter(selectedArea.center);
  }

  @override
  Widget build(BuildContext context) {
    final headerController = _headerController;
    final l10n = AppLocalizations.of(context)!;
    final filters = buildExploreFilters(l10n);
    final areaOptions = buildExploreAreaOptions(l10n);
    final allFilter = filters.firstWhere(
      (filter) => filter.category == ExploreCategory.all,
    );

    return AnimatedBuilder(
      animation: headerController,
      builder: (context, _) {
        final selectedFilters = _selectedFilters(filters);
        final selectedFilterSummary = _selectedFilterSummary(
          selectedFilters,
          allFilter,
        );
        final visibleEvents = _visibleEvents(selectedFilters, l10n);
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
                        ? ExploreMapView(
                            key: const ValueKey('explore-map-view'),
                            controller: _controller,
                            styleRepository: _styleRepository,
                          )
                        : ExploreListView(
                            key: const ValueKey('explore-list-view'),
                            events: visibleEvents,
                            selectedFilterSummary: selectedFilterSummary,
                            areaOptions: areaOptions,
                            selectedAreaIndex: _selectedAreaIndex,
                            selectedArea: _selectedArea(areaOptions),
                            selectedSort: _selectedSort,
                            onAreaSelected: (nextIndex) {
                              _applyAreaSelection(nextIndex, areaOptions);
                            },
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

  ExploreAreaOption _selectedArea(List<ExploreAreaOption> areaOptions) =>
      areaOptions[_selectedAreaIndex];

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
    if (_selectedSort == ExploreSortOption.distance) {
      sorted.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
    } else if (_selectedSort == ExploreSortOption.soonest) {
      sorted.sort((a, b) => a.timeLabel.compareTo(b.timeLabel));
    } else {
      sorted.sort((a, b) => b.distanceMeters.compareTo(a.distanceMeters));
    }

    return sorted;
  }
}
