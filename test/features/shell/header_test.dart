import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:locario/features/explore/models.dart';
import 'package:locario/features/shell/header/header.dart';
import 'package:locario/shared/notifications/notification_controller.dart';
import 'package:locario/shared/notifications/notification_entry.dart';
import 'package:locario/shared/notifications/notification_history_repository.dart';
import 'package:locario/shared/notifications/notification_preferences_store.dart';
import 'package:locario/shared/notifications/notification_scope.dart';
import 'package:locario/shared/notifications/notification_type.dart';

import '../../test_helpers/test_app.dart';

class _FakeNotificationHistoryRepository
    implements NotificationHistoryRepository {
  _FakeNotificationHistoryRepository({required this.unreadCount});

  final int unreadCount;

  @override
  Future<void> clear() async {}

  @override
  Future<void> deleteEntry(String id) async {}

  @override
  Future<int> getUnreadCount() async => unreadCount;

  @override
  Future<NotificationHistoryPage> loadPage({
    int page = 0,
    int pageSize = 20,
  }) async {
    return const NotificationHistoryPage(
      entries: [],
      hasMore: false,
      totalCount: 0,
    );
  }

  @override
  Future<void> insertEntry(NotificationEntry entry) async {}

  @override
  Future<void> markAllAsRead() async {}

  @override
  Future<void> markAsRead(String id) async {}
}

class _FakeNotificationPreferencesStore
    implements NotificationPreferencesStore {
  @override
  Future<Map<NotificationType, bool>> loadAll() async => {};

  @override
  Future<bool> isEnabled(NotificationType type) async => true;

  @override
  Future<void> setEnabled(NotificationType type, bool enabled) async {}
}

void main() {
  testWidgets('shows inbox action when view toggle is hidden', (tester) async {
    await tester.pumpWidget(
      buildLocalizedTestApp(
        locale: const Locale('en'),
        home: Scaffold(
          body: ShellHeader(
            selectedView: ExploreContentView.map,
            onViewChanged: (_) {},
            showViewToggle: false,
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);
    expect(find.byIcon(Icons.settings_rounded), findsOneWidget);
    expect(find.byIcon(Icons.map_outlined), findsNothing);
  });

  testWidgets('shows ringing inbox icon when unread notifications exist', (
    tester,
  ) async {
    final notificationController = NotificationController(
      historyRepository: _FakeNotificationHistoryRepository(unreadCount: 2),
      preferencesStore: _FakeNotificationPreferencesStore(),
    );
    await notificationController.loadHistory();

    await tester.pumpWidget(
      buildLocalizedTestApp(
        locale: const Locale('en'),
        home: NotificationScope(
          controller: notificationController,
          child: Scaffold(
            body: ShellHeader(
              selectedView: ExploreContentView.map,
              onViewChanged: (_) {},
              showViewToggle: false,
            ),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.notifications_active_rounded), findsOneWidget);
    expect(find.byIcon(Icons.notifications_none_rounded), findsNothing);
    expect(find.byIcon(Icons.settings_rounded), findsOneWidget);
  });

  testWidgets('shows view toggle instead of inbox action on explore', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildLocalizedTestApp(
        locale: const Locale('en'),
        home: Scaffold(
          body: ShellHeader(
            selectedView: ExploreContentView.map,
            onViewChanged: (_) {},
            showViewToggle: true,
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.notifications_none_rounded), findsNothing);
    expect(find.byIcon(Icons.settings_rounded), findsNothing);
    expect(find.byIcon(Icons.map_outlined), findsOneWidget);
  });
}
