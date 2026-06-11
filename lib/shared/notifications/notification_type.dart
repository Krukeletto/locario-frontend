import 'package:flutter/material.dart';

enum NotificationType {
  upcomingEvent,
  expiredEvent,
  eventPublished,
  systemMessage,
  chatMessage,
}

extension NotificationTypeX on NotificationType {
  IconData get icon {
    return switch (this) {
      NotificationType.upcomingEvent => Icons.alarm_rounded,
      NotificationType.expiredEvent => Icons.history_rounded,
      NotificationType.eventPublished => Icons.auto_awesome_rounded,
      NotificationType.systemMessage => Icons.info_outline_rounded,
      NotificationType.chatMessage => Icons.chat_rounded,
    };
  }

  String get arbNameKey {
    return switch (this) {
      NotificationType.upcomingEvent => 'notificationTypeUpcomingEvent',
      NotificationType.expiredEvent => 'notificationTypeExpiredEvent',
      NotificationType.eventPublished => 'notificationTypeEventPublished',
      NotificationType.systemMessage => 'notificationTypeSystemMessage',
      NotificationType.chatMessage => 'notificationTypeChatMessage',
    };
  }

  String get arbDescKey {
    return switch (this) {
      NotificationType.upcomingEvent => 'notificationTypeUpcomingEventDesc',
      NotificationType.expiredEvent => 'notificationTypeExpiredEventDesc',
      NotificationType.eventPublished => 'notificationTypeEventPublishedDesc',
      NotificationType.systemMessage => 'notificationTypeSystemMessageDesc',
      NotificationType.chatMessage => 'notificationTypeChatMessageDesc',
    };
  }

  String get topicName {
    return switch (this) {
      NotificationType.upcomingEvent => 'upcoming_event',
      NotificationType.expiredEvent => 'expired_event',
      NotificationType.eventPublished => 'event_published',
      NotificationType.systemMessage => 'system_message',
      NotificationType.chatMessage => 'chat_message',
    };
  }

  static NotificationType fromPayloadString(String value) {
    return switch (value) {
      'upcoming_event' => NotificationType.upcomingEvent,
      'expired_event' => NotificationType.expiredEvent,
      'event_published' => NotificationType.eventPublished,
      'group_join_request' ||
      'group_join_approved' ||
      'group_join_rejected' ||
      'group_post_comment' => NotificationType.systemMessage,
      'message' || 'chat_message' => NotificationType.chatMessage,
      _ => NotificationType.systemMessage,
    };
  }
}
