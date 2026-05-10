import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import '../explore/models.dart';
import 'saved_filter_model.dart';
import 'saved_filters_repository.dart';

class SavedFiltersController extends ChangeNotifier {
  SavedFiltersController({required SavedFiltersRepository repository})
    : _repository = repository;

  final SavedFiltersRepository _repository;
  static final _random = Random();

  static String _generateId() =>
      'filter_${DateTime.now().microsecondsSinceEpoch}_${_random.nextInt(99999)}';

  List<SavedFilter> _filters = const [];
  List<SavedFilter> get filters => List.unmodifiable(_filters);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Pending filter to be consumed by ExploreScreen.
  SavedFilter? _pendingLoadFilter;
  SavedFilter? get pendingLoadFilter => _pendingLoadFilter;

  void consumePendingLoad() {
    _pendingLoadFilter = null;
  }

  Future<void> loadFilters() async {
    _isLoading = true;
    notifyListeners();

    _filters = await _repository.loadAll();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveFilter({
    required String name,
    required ExploreAdvancedFilters filters,
    LatLng? location,
    bool useCurrentLocation = true,
    bool notificationsEnabled = false,
  }) async {
    final filter = SavedFilter(
      id: _generateId(),
      name: name,
      filters: filters,
      location: location,
      useCurrentLocation: useCurrentLocation,
      notificationsEnabled: notificationsEnabled,
      createdAt: DateTime.now().toUtc(),
    );

    await _repository.save(filter);
    _filters = [filter, ..._filters]..sort(_compareByCreatedAtDescending);
    notifyListeners();
  }

  Future<void> deleteFilter(String id) async {
    await _repository.delete(id);
    _filters = _filters.where((f) => f.id != id).toList();
    notifyListeners();
  }

  Future<void> toggleNotifications(String id, bool enabled) async {
    final index = _filters.indexWhere((f) => f.id == id);
    if (index == -1) return;

    final updated = _filters[index].copyWith(notificationsEnabled: enabled);
    await _repository.update(updated);
    _filters = _filters.toList()..[index] = updated;
    notifyListeners();
  }

  Future<void> toggleLocationMode(String id, bool useCurrentLocation) async {
    final index = _filters.indexWhere((f) => f.id == id);
    if (index == -1) return;

    final updated = _filters[index].copyWith(
      useCurrentLocation: useCurrentLocation,
    );
    await _repository.update(updated);
    _filters = _filters.toList()..[index] = updated;
    notifyListeners();
  }

  Future<void> loadFilterToExplore(SavedFilter filter) async {
    _pendingLoadFilter = filter;
    notifyListeners();
  }

  List<SavedFilter> get filtersWithNotificationsEnabled =>
      _filters.where((f) => f.notificationsEnabled).toList();

  static int _compareByCreatedAtDescending(
    SavedFilter left,
    SavedFilter right,
  ) {
    final comparison = right.createdAt.compareTo(left.createdAt);
    if (comparison != 0) {
      return comparison;
    }
    return left.name.compareTo(right.name);
  }
}
