import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:go_router/go_router.dart';

class NotificationPayload {
  final String? route;
  final String type;
  final String? eventId;
  final String? chatId;
  final String? senderId;
  final String? messageId;
  final String? imageUrl;
  final bool isGroup;
  final String? chatName;
  final String? senderName;
  final Map<String, dynamic> raw;

  const NotificationPayload({
    this.route,
    required this.type,
    this.eventId,
    this.chatId,
    this.senderId,
    this.messageId,
    this.imageUrl,
    this.isGroup = false,
    this.chatName,
    this.senderName,
    required this.raw,
  });

  factory NotificationPayload.fromRemoteMessage(RemoteMessage message) {
    final data = message.data;
    final chatId = data['chatId'] as String?;
    final eventId = data['event_id'] as String?;
    final screen = data['screen'] as String?;

    String? route;
    if (screen != null) {
      route = screen;
    } else if (chatId != null) {
      route = '/chat/$chatId';
    } else if (eventId != null) {
      route = '/events/$eventId';
    }

    return NotificationPayload(
      type: data['type'] as String? ?? '',
      eventId: eventId,
      chatId: chatId,
      senderId: data['senderId'] as String?,
      messageId: data['messageId'] as String?,
      imageUrl: data['imageUrl'] as String?,
      isGroup: data['isGroup'] == 'true',
      chatName: data['chatName'] as String?,
      senderName: data['senderName'] as String?,
      route: route,
      raw: Map<String, dynamic>.from(data),
    );
  }

  factory NotificationPayload.fromJson(Map<String, dynamic> json) {
    final chatId = json['chatId'] as String? ?? json['chat_id'] as String?;
    final eventId = json['event_id'] as String?;

    String? route;
    final screen = json['screen'] as String?;
    if (screen != null) {
      route = screen;
    } else if (chatId != null) {
      route = '/chat/$chatId';
    } else if (eventId != null) {
      route = '/events/$eventId';
    }

    return NotificationPayload(
      type: json['type'] as String? ?? '',
      eventId: eventId,
      chatId: chatId,
      senderId: json['senderId'] as String?,
      messageId: json['messageId'] as String?,
      imageUrl: json['imageUrl'] as String?,
      isGroup: json['isGroup'] == 'true',
      chatName: json['chatName'] as String?,
      senderName: json['senderName'] as String?,
      route: route,
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
