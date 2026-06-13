import 'package:shared_preferences/shared_preferences.dart';

import 'notification_type.dart';
import 'notification_preferences_store.dart';

class SharedPrefsNotificationPreferencesStore
    implements NotificationPreferencesStore {
  static const _prefix = 'notifications.enabled.';

  const SharedPrefsNotificationPreferencesStore();

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  @override
  Future<bool> isEnabled(NotificationType type) async {
    final defaultValue = _defaultEnabled(type);
    return (await _prefs).getBool(_prefix + type.topicName) ?? defaultValue;
  }

  @override
  Future<void> setEnabled(NotificationType type, bool enabled) async {
    await (await _prefs).setBool(_prefix + type.topicName, enabled);
  }

  @override
  Future<Map<NotificationType, bool>> loadAll() async {
    final prefs = await _prefs;
    final result = <NotificationType, bool>{};
    for (final type in NotificationType.values) {
      result[type] =
          prefs.getBool(_prefix + type.topicName) ?? _defaultEnabled(type);
    }
    return result;
  }

  static bool _defaultEnabled(NotificationType type) {
    return switch (type) {
      NotificationType.upcomingEvent => true,
      NotificationType.expiredEvent => true,
      NotificationType.eventPublished => true,
      NotificationType.systemMessage => true,
      NotificationType.chatMessage => true,
    };
  }
}
