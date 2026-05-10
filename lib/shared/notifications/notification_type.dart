import 'package:flutter/material.dart';

enum NotificationType {
  upcomingEvent,
  expiredEvent,
  eventPublished,
  systemMessage,
}

extension NotificationTypeX on NotificationType {
  IconData get icon {
    return switch (this) {
      NotificationType.upcomingEvent => Icons.alarm_rounded,
      NotificationType.expiredEvent => Icons.history_rounded,
      NotificationType.eventPublished => Icons.auto_awesome_rounded,
      NotificationType.systemMessage => Icons.info_outline_rounded,
    };
  }

  String get arbNameKey {
    return switch (this) {
      NotificationType.upcomingEvent => 'notificationTypeUpcomingEvent',
      NotificationType.expiredEvent => 'notificationTypeExpiredEvent',
      NotificationType.eventPublished => 'notificationTypeEventPublished',
      NotificationType.systemMessage => 'notificationTypeSystemMessage',
    };
  }

  String get arbDescKey {
    return switch (this) {
      NotificationType.upcomingEvent => 'notificationTypeUpcomingEventDesc',
      NotificationType.expiredEvent => 'notificationTypeExpiredEventDesc',
      NotificationType.eventPublished => 'notificationTypeEventPublishedDesc',
      NotificationType.systemMessage => 'notificationTypeSystemMessageDesc',
    };
  }

  String get topicName {
    return switch (this) {
      NotificationType.upcomingEvent => 'upcoming_event',
      NotificationType.expiredEvent => 'expired_event',
      NotificationType.eventPublished => 'event_published',
      NotificationType.systemMessage => 'system_message',
    };
  }

  static NotificationType fromPayloadString(String value) {
    return switch (value) {
      'upcoming_event' => NotificationType.upcomingEvent,
      'expired_event' => NotificationType.expiredEvent,
      'event_published' => NotificationType.eventPublished,
      _ => NotificationType.systemMessage,
    };
  }
}
