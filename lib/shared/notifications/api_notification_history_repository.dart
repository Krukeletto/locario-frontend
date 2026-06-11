import 'notification_entry.dart';
import 'notification_history_repository.dart';
import 'notification_type.dart';
import 'notifications_api.dart';
import 'shared_prefs_notification_history_repository.dart';

class ApiNotificationHistoryRepository
    implements NotificationHistoryRepository {
  ApiNotificationHistoryRepository({
    required NotificationsApi api,
    String? Function()? tokenProvider,
    SharedPrefsNotificationHistoryRepository? localCache,
  }) : _api = api,
       _tokenProvider = tokenProvider ?? (() => null),
       _localCache =
           localCache ?? const SharedPrefsNotificationHistoryRepository();

  final NotificationsApi _api;
  final String? Function() _tokenProvider;
  final SharedPrefsNotificationHistoryRepository _localCache;

  String? get _token => _tokenProvider();

  @override
  Future<NotificationHistoryPage> loadPage({
    int page = 0,
    int pageSize = 20,
  }) async {
    final token = _token;
    if (token != null) {
      try {
        final json = await _api.fetchHistory(
          accessToken: token,
          page: page,
          size: pageSize,
        );

        final itemsJson = json['items'] as List? ?? [];
        final items = itemsJson
            .map((e) => _mapApiItem(e as Map<String, dynamic>))
            .toList();

        final totalCount = json['total_count'] as int? ?? items.length;
        final hasMore = json['has_more'] as bool? ?? false;

        for (final entry in items) {
          await _localCache.insertEntry(entry);
        }

        return NotificationHistoryPage(
          entries: items,
          hasMore: hasMore,
          totalCount: totalCount,
        );
      } catch (_) {
        // Fall through to local cache
      }
    }

    return _localCache.loadPage(page: page, pageSize: pageSize);
  }

  @override
  Future<void> insertEntry(NotificationEntry entry) async {
    await _localCache.insertEntry(entry);
  }

  @override
  Future<void> markAsRead(String id) async {
    final token = _token;
    if (token != null) {
      try {
        await _api.markAsRead(accessToken: token, notificationId: id);
      } catch (_) {
        // Local fallback
      }
    }
    await _localCache.markAsRead(id);
  }

  @override
  Future<void> markAllAsRead() async {
    final token = _token;
    if (token != null) {
      try {
        await _api.markAllAsRead(accessToken: token);
      } catch (_) {
        // Local fallback
      }
    }
    await _localCache.markAllAsRead();
  }

  @override
  Future<void> deleteEntry(String id) async {
    final token = _token;
    if (token != null) {
      try {
        await _api.deleteNotification(accessToken: token, notificationId: id);
      } catch (_) {
        // Local fallback
      }
    }
    await _localCache.deleteEntry(id);
  }

  @override
  Future<void> clear() async {
    await _localCache.clear();
  }

  @override
  Future<int> getUnreadCount() async {
    return _localCache.getUnreadCount();
  }

  NotificationEntry _mapApiItem(Map<String, dynamic> item) {
    final id = item['id'] as String;
    final typeStr = item['type'] as String? ?? '';
    final payloadRaw = item['payload_data'];
    final payloadData = payloadRaw is Map
        ? Map<String, dynamic>.from(payloadRaw)
        : <String, dynamic>{};
    final createdAtStr = item['created_at'] as String?;
    final title = (item['title'] as String?) ?? '';
    final body = (item['body'] as String?) ?? '';

    String? route;
    final chatId = payloadData['chat_id'] as String?;
    final eventId = payloadData['event_id'] as String?;
    final screen = payloadData['screen'] as String?;
    if (screen != null) {
      route = screen;
    } else if (chatId != null) {
      route = '/chat/$chatId';
    } else if (eventId != null) {
      route = '/events/$eventId';
    }

    return NotificationEntry(
      id: id,
      type: NotificationTypeX.fromPayloadString(typeStr),
      title: title,
      body: body,
      route: route,
      rawPayload: payloadData.isNotEmpty ? payloadData : null,
      timestamp: createdAtStr != null
          ? DateTime.tryParse(createdAtStr) ?? DateTime.now()
          : DateTime.now(),
      isRead: item['read'] as bool? ?? false,
    );
  }
}
