import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'saved_filter_model.dart';

abstract class SavedFiltersRepository {
  Future<List<SavedFilter>> loadAll();
  Future<void> save(SavedFilter filter);
  Future<void> delete(String id);
  Future<void> update(SavedFilter filter);
  Future<void> clear();
}

class SharedPreferencesSavedFiltersRepository
    implements SavedFiltersRepository {
  static const _storageKey = 'saved.filters.v1';

  const SharedPreferencesSavedFiltersRepository();

  Future<SharedPreferences> get _preferences async =>
      SharedPreferences.getInstance();

  @override
  Future<List<SavedFilter>> loadAll() async {
    final raw = (await _preferences).getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return const [];
    }

    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return const [];
    }

    return decoded
        .map((item) {
          if (item is Map) {
            return SavedFilter.fromJson(Map<String, dynamic>.from(item));
          }
          return null;
        })
        .whereType<SavedFilter>()
        .toList(growable: false)
      ..sort(_compareByCreatedAtDescending);
  }

  @override
  Future<void> save(SavedFilter filter) async {
    final filters = await loadAll();
    final updated = <SavedFilter>[
      filter,
      ...filters.where((item) => item.id != filter.id),
    ]..sort(_compareByCreatedAtDescending);
    await _writeFilters(updated);
  }

  @override
  Future<void> delete(String id) async {
    final filters = await loadAll();
    final updated = filters.where((item) => item.id != id).toList();
    await _writeFilters(updated);
  }

  @override
  Future<void> update(SavedFilter filter) async {
    final filters = await loadAll();
    final updated = filters.map((item) {
      return item.id == filter.id ? filter : item;
    }).toList()..sort(_compareByCreatedAtDescending);
    await _writeFilters(updated);
  }

  @override
  Future<void> clear() async {
    await (await _preferences).remove(_storageKey);
  }

  Future<void> _writeFilters(List<SavedFilter> filters) async {
    final payload = jsonEncode(filters.map((f) => f.toJson()).toList());
    await (await _preferences).setString(_storageKey, payload);
  }

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
