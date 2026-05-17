import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'notification_entry.dart';
import 'notification_history_repository.dart';
import 'notification_payload.dart';
import 'notification_preferences_store.dart';
import 'notification_service.dart';
import 'notification_type.dart';

typedef NavigateCallback = void Function(NotificationPayload payload);

class NotificationController extends ChangeNotifier {
  NotificationController({
    required NotificationHistoryRepository historyRepository,
    required NotificationPreferencesStore preferencesStore,
  }) : _historyRepository = historyRepository,
       _preferencesStore = preferencesStore;

  final NotificationHistoryRepository _historyRepository;
  final NotificationPreferencesStore _preferencesStore;

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  List<NotificationEntry> _history = [];
  List<NotificationEntry> get history => List.unmodifiable(_history);

  int _unreadCount = 0;
  int get unreadCount => _unreadCount;

  bool _isHistoryLoaded = false;
  bool get isHistoryLoaded => _isHistoryLoaded;

  bool _hasMoreHistoryPages = false;
  bool get hasMoreHistoryPages => _hasMoreHistoryPages;

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  NavigateCallback? onNavigate;

  int _testCounter = 0;

  Map<NotificationType, bool> _preferences = {};
  bool isEnabled(NotificationType type) =>
      _preferences[type] ?? _defaultEnabled(type);

  Set<String> _scheduledJoinReminderIds = {};

  // ---------------------------------------------------------------------------
  // Pagination
  // ---------------------------------------------------------------------------

  static const _pageSize = 20;
  int _currentPage = 0;

  Future<void> loadHistory() async {
    _currentPage = 0;
    final page = await _historyRepository.loadPage(
      page: _currentPage,
      pageSize: _pageSize,
    );
    _history = page.entries;
    _hasMoreHistoryPages = page.hasMore;
    _unreadCount = await _historyRepository.getUnreadCount();
    _isHistoryLoaded = true;
    notifyListeners();
  }

  Future<void> loadMoreHistory() async {
    if (!_hasMoreHistoryPages) return;
    _currentPage++;
    final page = await _historyRepository.loadPage(
      page: _currentPage,
      pageSize: _pageSize,
    );
    _history.addAll(page.entries);
    _hasMoreHistoryPages = page.hasMore;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Receive notification
  // ---------------------------------------------------------------------------

  Future<void> onNotificationReceived(
    RemoteMessage message, {
    bool isForegroundTap = false,
  }) async {
    final data = message.data;
    final typeStr = data['type'] as String? ?? '';
    final type = NotificationTypeX.fromPayloadString(typeStr);

    if (!isEnabled(type)) return;

    final entry = NotificationEntry(
      id: message.messageId ?? DateTime.now().toIso8601String(),
      type: type,
      title: message.notification?.title ?? '',
      body: message.notification?.body ?? '',
      route:
          data['screen'] as String? ??
          (data['event_id'] != null ? '/events/${data['event_id']}' : null),
      rawPayload: Map<String, dynamic>.from(data),
      timestamp: DateTime.now(),
      isRead: isForegroundTap,
    );

    await _historyRepository.insertEntry(entry);
    _history.insert(0, entry);
    if (!isForegroundTap) {
      _unreadCount++;
    }
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Mark read / unread
  // ---------------------------------------------------------------------------

  Future<void> markAsRead(String id) async {
    await _historyRepository.markAsRead(id);
    final index = _history.indexWhere((e) => e.id == id);
    if (index != -1 && !_history[index].isRead) {
      _history[index] = _history[index].copyWith(isRead: true);
      _unreadCount = (_unreadCount - 1).clamp(0, _history.length);
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    await _historyRepository.markAllAsRead();
    for (var i = 0; i < _history.length; i++) {
      _history[i] = _history[i].copyWith(isRead: true);
    }
    _unreadCount = 0;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Preferences
  // ---------------------------------------------------------------------------

  Future<void> loadPreferences() async {
    _preferences = await _preferencesStore.loadAll();
    notifyListeners();
  }

  Future<void> setEnabled(NotificationType type, bool enabled) async {
    await _preferencesStore.setEnabled(type, enabled);
    _preferences[type] = enabled;
    notifyListeners();

    if (enabled) {
      await NotificationService.subscribeToTopic(type.topicName);
    } else {
      await NotificationService.unsubscribeFromTopic(type.topicName);
    }
  }

  // ---------------------------------------------------------------------------
  // Token
  // ---------------------------------------------------------------------------

  void setFcmToken(String? token) {
    _fcmToken = token;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Event reminders (for saved / favorited events)
  // ---------------------------------------------------------------------------

  void scheduleRemindersForSavedEvents(
    List<({String id, String title, DateTime startsAt})> events, {
    Set<String>? excludeEventIds,
  }) {
    for (final event in events) {
      if (excludeEventIds?.contains(event.id) == true) continue;

      const type = NotificationType.upcomingEvent;
      if (!isEnabled(type)) continue;

      NotificationService.scheduleEventReminder(
        eventId: event.id,
        title: event.title,
        startsAt: event.startsAt,
      );
    }
  }

  void scheduleRemindersForJoinedEvents(
    List<({String id, String title, DateTime startsAt})> events,
  ) {
    final currentIds = events.map((event) => event.id).toSet();
    final removedJoinIds = _scheduledJoinReminderIds.difference(currentIds);

    for (final eventId in removedJoinIds) {
      unawaited(NotificationService.cancelEventReminder(eventId));
    }

    _scheduledJoinReminderIds = currentIds;

    for (final event in events) {
      if (isEnabled(NotificationType.upcomingEvent)) {
        NotificationService.scheduleEventReminder(
          eventId: event.id,
          title: event.title,
          startsAt: event.startsAt,
        );
      }
    }
  }

  void cancelReminderForEvent(String eventId) {
    NotificationService.cancelEventReminder(eventId);
  }

  // ---------------------------------------------------------------------------
  // Test notifications
  // ---------------------------------------------------------------------------

  bool sendTestNotification() {
    _testCounter++;
    final counter = _testCounter;
    final type =
        NotificationType.values[counter % NotificationType.values.length];

    if (!isEnabled(type)) return false;

    Future.delayed(const Duration(seconds: 3), () {
      final entry = NotificationEntry(
        id: 'test_${DateTime.now().millisecondsSinceEpoch}',
        type: type,
        title: 'Test #$counter',
        body: 'Type: ${type.topicName}',
        route: '/explore',
        rawPayload: {'test': 'true'},
        timestamp: DateTime.now(),
      );

      _history.insert(0, entry);
      _unreadCount++;
      notifyListeners();

      _historyRepository.insertEntry(entry);

      NotificationService.showTestNotification(
        title: 'Test #$counter',
        body: 'Type: ${type.topicName}',
      );
    });

    return true;
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  static bool _defaultEnabled(NotificationType type) {
    return switch (type) {
      NotificationType.upcomingEvent => true,
      NotificationType.expiredEvent => true,
      NotificationType.eventPublished => true,
      NotificationType.systemMessage => true,
    };
  }
}
