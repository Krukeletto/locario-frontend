import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:go_router/go_router.dart';

class NotificationPayload {
  final String? route;
  final String type;
  final String? eventId;
  final Map<String, dynamic> raw;

  const NotificationPayload({
    this.route,
    required this.type,
    this.eventId,
    required this.raw,
  });

  factory NotificationPayload.fromRemoteMessage(RemoteMessage message) {
    final data = message.data;
    return NotificationPayload(
      type: data['type'] as String? ?? '',
      eventId: data['event_id'] as String?,
      route:
          data['screen'] as String? ??
          (data['event_id'] != null ? '/events/${data['event_id']}' : null),
      raw: Map<String, dynamic>.from(data),
    );
  }

  factory NotificationPayload.fromJson(Map<String, dynamic> json) {
    return NotificationPayload(
      type: json['type'] as String? ?? '',
      eventId: json['event_id'] as String?,
      route: json['screen'] as String?,
      raw: Map<String, dynamic>.from(json),
    );
  }

  Map<String, dynamic> toJson() => raw;

  void navigate(GoRouter router) {
    if (route != null && route!.isNotEmpty) {
      router.go(route!);
    }
  }
}
