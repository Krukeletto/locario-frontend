import 'notification_type.dart';

abstract class NotificationPreferencesStore {
  Future<bool> isEnabled(NotificationType type);

  Future<void> setEnabled(NotificationType type, bool enabled);

  Future<Map<NotificationType, bool>> loadAll();
}
