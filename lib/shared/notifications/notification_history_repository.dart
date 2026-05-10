import 'notification_entry.dart';

const _defaultPageSize = 20;

class NotificationHistoryPage {
  final List<NotificationEntry> entries;
  final bool hasMore;
  final int totalCount;

  const NotificationHistoryPage({
    required this.entries,
    required this.hasMore,
    required this.totalCount,
  });
}

abstract class NotificationHistoryRepository {
  Future<NotificationHistoryPage> loadPage({
    int page = 0,
    int pageSize = _defaultPageSize,
  });

  Future<void> insertEntry(NotificationEntry entry);

  Future<void> markAsRead(String id);

  Future<void> markAllAsRead();

  Future<void> deleteEntry(String id);

  Future<void> clear();

  Future<int> getUnreadCount();
}
