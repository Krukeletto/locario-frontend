import 'dart:async';
import 'package:flutter/foundation.dart' hide Category;
import 'package:latlong2/latlong.dart';
import '../../shared/events/event_repository.dart';
import 'explore_event_query.dart';
import 'explore_state.dart';
import 'models.dart';

class ExploreController extends ChangeNotifier {
  ExploreController({
    required EventRepository eventRepository,
    ExploreEventQuery eventQuery = const ExploreEventQuery(),
  }) : _eventRepository = eventRepository,
       _eventQuery = eventQuery;

  final EventRepository _eventRepository;
  final ExploreEventQuery _eventQuery;

  ExploreState _state = const ExploreLoading();
  ExploreState get state => _state;

  List<ExploreEvent> _allEvents = const [];
  int _activeRequestId = 0;
  Timer? _debounceTimer;

  // Query parameters
  String _searchQuery = '';
  ExploreSortOption _selectedSort = ExploreSortOption.distance;
  bool _sortAscending = true;
  ExploreAdvancedFilters _advancedFilters = const ExploreAdvancedFilters();
  Iterable<Category> _selectedCategories = const [];
  LatLng? _referenceLocation;
  int? _distanceOverrideMeters;

  Iterable<Category> get selectedCategories => _selectedCategories;
  String get searchQuery => _searchQuery;
  ExploreSortOption get selectedSort => _selectedSort;
  bool get sortAscending => _sortAscending;
  ExploreAdvancedFilters get advancedFilters => _advancedFilters;
  LatLng? get referenceLocation => _referenceLocation;
  int? get distanceOverrideMeters => _distanceOverrideMeters;

  List<ExploreEvent> get searchResults => _eventQuery.searchResults(
    events: _allEvents,
    selectedCategories: _selectedCategories,
    query: _searchQuery,
    sort: _selectedSort,
    isAscending: _sortAscending,
    referenceLocation: _referenceLocation ?? const LatLng(0, 0),
    maxDistanceMeters: _distanceOverrideMeters,
    advancedFilters: _advancedFilters,
  );

  void updateSearchQuery(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    _onQueryChanged(debounced: true);
  }

  void updateSort(ExploreSortOption sort) {
    if (_selectedSort == sort) return;
    _selectedSort = sort;
    _sortAscending = true;
    _onQueryChanged(debounced: false);
  }

  void toggleSortOrder() {
    _sortAscending = !_sortAscending;
    _onQueryChanged(debounced: false);
  }

  void updateAdvancedFilters(ExploreAdvancedFilters filters) {
    if (_advancedFilters == filters) return;
    _advancedFilters = filters;
    _onQueryChanged(debounced: false);
  }

  void updateCategories(Iterable<Category> categories) {
    _selectedCategories = categories;
    _onQueryChanged(debounced: false);
  }

  void updateReferenceLocation(LatLng? location) {
    if (_referenceLocation == location) return;
    _referenceLocation = location;

    if (location != null) {
      loadEvents();
    }
  }

  void updateDistanceOverride(int? distanceMeters) {
    if (_distanceOverrideMeters == distanceMeters) return;
    _distanceOverrideMeters = distanceMeters;

    // Auto-refetch when distance changes as it affects nearby radius
    loadEvents();
  }

  Future<void> loadEvents({bool forceRefresh = false}) async {
    final location = _referenceLocation;
    if (location == null) {
      // We can't fetch nearby events without a location.
      // If we don't have location yet, we might be waiting for it.
      return;
    }

    final requestId = ++_activeRequestId;
    final hasData = _allEvents.isNotEmpty;

    if (!hasData || forceRefresh) {
      if (hasData) {
        _state = ExploreDataLoading(previous: _filterAndSort());
      } else {
        _state = const ExploreLoading();
      }
      notifyListeners();
    }

    try {
      final events = await _eventRepository.fetchNearbyEvents(
        latitude: location.latitude,
        longitude: location.longitude,
        radiusKm:
            (_distanceOverrideMeters ??
                _advancedFilters.distanceFilter.maxDistanceMeters) /
            1000.0,
      );

      if (requestId != _activeRequestId) return;

      _allEvents = events;
      _updateResults();
    } on EventRepositoryException catch (e) {
      if (requestId != _activeRequestId) return;

      final type = _mapErrorType(e.message);
      _state = ExploreError(type: type, details: e.message);
      notifyListeners();
    } catch (e) {
      if (requestId != _activeRequestId) return;
      _state = const ExploreError(type: ExploreErrorType.unknown);
      notifyListeners();
    }
  }

  void _onQueryChanged({required bool debounced}) {
    _debounceTimer?.cancel();
    if (debounced) {
      _debounceTimer = Timer(const Duration(milliseconds: 300), () {
        _updateResults();
      });
    } else {
      _updateResults();
    }
  }

  void _updateResults() {
    if (_allEvents.isEmpty && _state is! ExploreLoading) {
      // If we already have an empty list and just changed a filter, it stays empty.
      // But if we have no events because we haven't loaded them, we keep the loading state.
      return;
    }

    debugPrint(
      'ExploreController updating results. allEvents: ${_allEvents.length}, state: $_state',
    );
    final results = _filterAndSort();
    if (results.isEmpty) {
      _state = const ExploreEmpty();
    } else {
      _state = ExploreData(events: results);
    }
    notifyListeners();
  }

  List<ExploreEvent> _filterAndSort() {
    return _eventQuery.visibleEvents(
      events: _allEvents,
      selectedCategories: _selectedCategories,
      query: _searchQuery,
      sort: _selectedSort,
      isAscending: _sortAscending,
      referenceLocation: _referenceLocation ?? const LatLng(0, 0),
      maxDistanceMeters: _distanceOverrideMeters,
      advancedFilters: _advancedFilters,
    );
  }

  ExploreErrorType _mapErrorType(String? message) {
    if (message == null) return ExploreErrorType.unknown;
    final msg = message.toLowerCase();
    if (msg.contains('network') || msg.contains('connection')) {
      return ExploreErrorType.network;
    }
    if (msg.contains('permission') || msg.contains('denied')) {
      return ExploreErrorType.permission;
    }
    return ExploreErrorType.unknown;
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
