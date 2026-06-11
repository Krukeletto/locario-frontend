import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'notification_entry.dart';
import 'notification_history_repository.dart';

class SharedPrefsNotificationHistoryRepository
    implements NotificationHistoryRepository {
  static const _historyKey = 'notifications.history';
  static const _maxEntries = 100;

  const SharedPrefsNotificationHistoryRepository();

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  @override
  Future<NotificationHistoryPage> loadPage({
    int page = 0,
    int pageSize = 20,
  }) async {
    final all = await _loadAll();
    final totalCount = all.length;
    final start = page * pageSize;
    final end = (start + pageSize).clamp(0, totalCount);
    final entries = all.sublist(start, end);
    final hasMore = end < totalCount;

    return NotificationHistoryPage(
      entries: entries,
      hasMore: hasMore,
      totalCount: totalCount,
    );
  }

  Future<List<NotificationEntry>> _loadAll() async {
    final json = (await _prefs).getString(_historyKey);
    if (json == null || json.isEmpty) return [];
    final list = jsonDecode(json) as List;
    return list
        .map((e) => NotificationEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveAll(List<NotificationEntry> entries) async {
    final json = jsonEncode(entries.map((e) => e.toJson()).toList());
    await (await _prefs).setString(_historyKey, json);
  }

  @override
  Future<void> insertEntry(NotificationEntry entry) async {
    final all = await _loadAll();
    all.removeWhere((e) => e.id == entry.id);
    all.insert(0, entry);
    if (all.length > _maxEntries) {
      all.removeRange(_maxEntries, all.length);
    }
    await _saveAll(all);
  }

  @override
  Future<void> markAsRead(String id) async {
    final all = await _loadAll();
    final index = all.indexWhere((e) => e.id == id);
    if (index == -1) return;
    all[index] = all[index].copyWith(isRead: true);
    await _saveAll(all);
  }

  @override
  Future<void> markAllAsRead() async {
    final all = await _loadAll();
    for (var i = 0; i < all.length; i++) {
      all[i] = all[i].copyWith(isRead: true);
    }
    await _saveAll(all);
  }

  @override
  Future<void> deleteEntry(String id) async {
    final all = await _loadAll();
    all.removeWhere((e) => e.id == id);
    await _saveAll(all);
  }

  @override
  Future<void> clear() async {
    await (await _prefs).remove(_historyKey);
  }

  @override
  Future<int> getUnreadCount() async {
    final all = await _loadAll();
    return all.where((e) => !e.isRead).length;
  }
}
