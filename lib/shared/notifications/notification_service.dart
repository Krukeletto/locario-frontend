import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

import 'notification_controller.dart';
import 'notification_payload.dart';

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static NotificationController? _controller;
  static bool _firebaseAvailable = false;

  /// Initialize [FlutterLocalNotificationsPlugin] before runApp.
  static Future<void> initLocalNotifications() async {
    try {
      tz.initializeTimeZones();

      const androidSettings = AndroidInitializationSettings('ic_notification');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onLocalNotificationTap,
      );
    } catch (_) {
      // Platform channels not available (e.g. tests)
    }
  }

  /// Full initialisation — call once [NotificationController] and
  /// [GoRouter] are available (inside your app's initState).
  static Future<void> init({
    required NotificationController controller,
    required GoRouter router,
  }) async {
    _controller = controller;
    _controller!.onNavigate = (payload) => payload.navigate(router);

    try {
      Firebase.app();
      _firebaseAvailable = true;
    } catch (_) {
      // Firebase not initialised (e.g. in tests)
      return;
    }

    final messaging = FirebaseMessaging.instance;

    await messaging.getToken().then((token) {
      _controller!.setFcmToken(token);
    });
    messaging.onTokenRefresh.listen((token) {
      _controller!.setFcmToken(token);
    });

    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }

    _requestPermissionsAfterDelay();
  }

  // ---------------------------------------------------------------------------
  // Topics
  // ---------------------------------------------------------------------------

  static Future<void> subscribeToTopic(String topic) async {
    if (!_firebaseAvailable) return;
    await FirebaseMessaging.instance.subscribeToTopic(topic);
  }

  static Future<void> unsubscribeFromTopic(String topic) async {
    if (!_firebaseAvailable) return;
    await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
  }

  // ---------------------------------------------------------------------------
  // Permissions
  // ---------------------------------------------------------------------------

  static void _requestPermissionsAfterDelay() {
    Future.delayed(const Duration(seconds: 2), () async {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final messaging = FirebaseMessaging.instance;
        await messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
      }
      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidImplementation = _localNotifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
        await androidImplementation?.requestNotificationsPermission();
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Event reminders
  // ---------------------------------------------------------------------------

  static const _reminderIdBase = 1_000_000;

  static int _reminderNotificationId(String eventId) =>
      _reminderIdBase + eventId.hashCode.abs();

  static Future<void> scheduleEventReminder({
    required String eventId,
    required String title,
    required DateTime startsAt,
  }) async {
    final fireAt = startsAt.subtract(const Duration(days: 1));
    if (fireAt.isBefore(DateTime.now())) return;

    final hour = startsAt.hour.toString().padLeft(2, '0');
    final minute = startsAt.minute.toString().padLeft(2, '0');
    final body = '$title starts tomorrow at $hour:$minute';

    final tzScheduled = tz.TZDateTime.from(fireAt, tz.local);
    final payload = jsonEncode({
      'screen': '/events/$eventId',
      'event_id': eventId,
    });

    await _localNotifications.zonedSchedule(
      _reminderNotificationId(eventId),
      'Event reminder',
      body,
      tzScheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          channelDescription:
              'This channel is used for important notifications.',
          importance: Importance.high,
          priority: Priority.high,
          icon: 'ic_notification',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: payload,
    );
  }

  static Future<void> cancelEventReminder(String eventId) async {
    await _localNotifications.cancel(_reminderNotificationId(eventId));
  }

  static Future<void> cancelAllEventReminders() async {
    await _localNotifications.cancelAll();
  }

  // ---------------------------------------------------------------------------
  // Test notifications
  // ---------------------------------------------------------------------------

  static Future<void> showTestNotification({
    required String title,
    required String body,
  }) async {
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch & 0x7FFFFFFF,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          channelDescription:
              'This channel is used for important notifications.',
          importance: Importance.high,
          priority: Priority.high,
          icon: 'ic_notification',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: '{"screen":"/explore"}',
    );
  }

  // ---------------------------------------------------------------------------
  // Internal message handlers
  // ---------------------------------------------------------------------------

  static void _onForegroundMessage(RemoteMessage message) {
    _controller?.onNotificationReceived(message, isForegroundTap: false);
    _showLocalNotification(message);
  }

  static void _onMessageOpenedApp(RemoteMessage message) {
    _controller?.onNotificationReceived(message, isForegroundTap: true);
    _handleNotificationTap(message);
  }

  static void _handleNotificationTap(RemoteMessage message) {
    final payload = NotificationPayload.fromRemoteMessage(message);
    if (payload.route != null) {
      _controller?.onNavigate?.call(payload);
    }
  }

  static void _onLocalNotificationTap(NotificationResponse response) {
    if (response.payload == null) return;
    final json = jsonDecode(response.payload!) as Map<String, dynamic>;
    final payload = NotificationPayload.fromJson(json);
    if (payload.route != null) {
      _controller?.onNavigate?.call(payload);
    }
  }

  static void _showLocalNotification(RemoteMessage message) {
    final title = message.notification?.title;
    final body = message.notification?.body;
    if (title == null || body == null) return;

    final payload = NotificationPayload.fromRemoteMessage(message);

    _localNotifications.show(
      message.hashCode,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          channelDescription:
              'This channel is used for important notifications.',
          importance: Importance.high,
          priority: Priority.high,
          icon: 'ic_notification',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode(payload.toJson()),
    );
  }
}
