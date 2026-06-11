import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' hide Category;
import 'package:latlong2/latlong.dart';
import '../../shared/cache/cache_service.dart';
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
  bool _isRefreshing = false;

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

  void applyFilters(
    ExploreAdvancedFilters filters, {
    LatLng? referenceLocation,
  }) {
    _advancedFilters = filters;
    if (referenceLocation != null) {
      _referenceLocation = referenceLocation;
    }
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

  Future<void> loadEvents({
    bool forceRefresh = false,
    String? accessToken,
    String tokenType = 'Bearer',
    CacheService? cache,
  }) async {
    final location = _referenceLocation;
    if (location == null) {
      return;
    }

    final requestId = ++_activeRequestId;
    final previousResults = _visiblePreviousResults();

    final radiusKm =
        (_distanceOverrideMeters ??
            _advancedFilters.distanceFilter.maxDistanceMeters) /
        1000.0;

    final groupSuffix =
        _advancedFilters.groupIds.isNotEmpty
            ? '_g${_advancedFilters.groupIds.join(',')}'
            : '';
    final cacheKey =
        'map_events_${location.latitude.toStringAsFixed(1)}_${location.longitude.toStringAsFixed(1)}_${radiusKm.toStringAsFixed(1)}$groupSuffix';

    if (!forceRefresh && cache != null) {
      final cached = await cache.getList<ExploreEvent>(
        cacheKey,
        ExploreEvent.fromJson,
      );
      if (cached != null && cached.isNotEmpty) {
        _allEvents = cached;
        _updateResults();
      }
    }

    if ((_allEvents.isEmpty || forceRefresh) && !_isRefreshing) {
      _isRefreshing = true;
      if (previousResults != null) {
        _state = ExploreDataLoading(previous: previousResults);
      } else {
        _state = const ExploreLoading();
      }
      notifyListeners();
    }

    try {
      final events = await _eventRepository.fetchMapEvents(
        latitude: location.latitude,
        longitude: location.longitude,
        radiusKm: radiusKm,
        includeCommunityEvents: true,
        groupIds:
            _advancedFilters.groupIds.isNotEmpty
                ? _advancedFilters.groupIds
                : null,
        accessToken: accessToken,
        tokenType: tokenType,
      );

      if (requestId != _activeRequestId) return;

      final freshHash = jsonEncode(
        events.map((e) => e.toJson()).toList(),
      ).hashCode;
      final cachedHash = cache != null ? await cache.getHash(cacheKey) : null;

      if (freshHash != cachedHash) {
        _allEvents = events;
        _updateResults();
        if (cache != null) {
          await cache.setList(
            cacheKey,
            events.map((e) => e.toJson()).toList(),
            hash: freshHash,
          );
        }
      }
    } on EventRepositoryException catch (e) {
      if (requestId != _activeRequestId) return;

      final type = _mapErrorType(e.message);
      _state = ExploreError(type: type, details: e.message);
      notifyListeners();
    } catch (e) {
      if (requestId != _activeRequestId) return;
      _state = const ExploreError(
        type: ExploreErrorType.unknown,
        details: null,
      );
      notifyListeners();
    } finally {
      _isRefreshing = false;
    }
  }

  List<ExploreEvent>? _visiblePreviousResults() {
    final state = _state;
    return switch (state) {
      ExploreData(events: final events) => events,
      ExploreDataLoading(previous: final previous) => previous,
      ExploreEmpty() => const [],
      _ => _allEvents.isEmpty ? null : _filterAndSort(),
    };
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
    if (_allEvents.isEmpty &&
        _state is! ExploreLoading &&
        _state is! ExploreDataLoading) {
      // If we already have an empty list and just changed a filter, it stays empty.
      // But if we have no events because we haven't loaded them, we keep the loading state.
      return;
    }

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
