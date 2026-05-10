import 'dart:convert';

import 'notification_type.dart';

class NotificationEntry {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final String? route;
  final Map<String, dynamic>? rawPayload;
  final DateTime timestamp;
  final bool isRead;

  const NotificationEntry({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.route,
    this.rawPayload,
    required this.timestamp,
    this.isRead = false,
  });

  NotificationEntry copyWith({bool? isRead}) {
    return NotificationEntry(
      id: id,
      type: type,
      title: title,
      body: body,
      route: route,
      rawPayload: rawPayload,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.topicName,
    'title': title,
    'body': body,
    'route': route,
    'rawPayload': rawPayload,
    'timestamp': timestamp.toIso8601String(),
    'isRead': isRead,
  };

  factory NotificationEntry.fromJson(Map<String, dynamic> json) {
    return NotificationEntry(
      id: json['id'] as String,
      type: NotificationTypeX.fromPayloadString(json['type'] as String),
      title: json['title'] as String,
      body: json['body'] as String,
      route: json['route'] as String?,
      rawPayload: json['rawPayload'] != null
          ? jsonDecode(jsonEncode(json['rawPayload'])) as Map<String, dynamic>
          : null,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationEntry &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
