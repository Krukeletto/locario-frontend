import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:locario/features/explore/models.dart';
import 'package:locario/features/groups/group_details_screen.dart';
import 'package:locario/shared/auth/auth_api.dart';
import 'package:locario/shared/auth/auth_models.dart';
import 'package:locario/shared/auth/auth_repository.dart';
import 'package:locario/shared/auth/auth_scope.dart';
import 'package:locario/shared/auth/session_controller.dart';
import 'package:locario/shared/cache/cache_service.dart';
import 'package:locario/shared/groups/group_controller.dart';
import 'package:locario/shared/groups/group_models.dart';
import 'package:locario/shared/groups/group_repository.dart';
import 'package:locario/shared/groups/group_scope.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../test_helpers/fake_event_repository.dart';
import '../../test_helpers/test_app.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('defaults to info for non-members', (tester) async {
    await _pumpGroupDetails(
      tester,
      group: const Group(
        id: 'group-1',
        name: 'Climbing Club',
        description: 'Non-member details',
        categoryName: 'Sport',
        memberCount: 12,
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Non-member details'), findsOneWidget);
    expect(find.text('No feed yet'), findsNothing);
  });

  testWidgets('keeps feed as default for members', (tester) async {
    await _pumpGroupDetails(
      tester,
      group: const Group(
        id: 'group-1',
        name: 'Climbing Club',
        description: 'Member details',
        categoryName: 'Sport',
        memberCount: 12,
        currentUserMembership: GroupMembershipStatus.active,
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('No feed yet'), findsOneWidget);
    expect(find.text('Member details'), findsNothing);
  });

  testWidgets('shows feed timestamps and event authors', (tester) async {
    await _pumpGroupDetails(
      tester,
      group: const Group(
        id: 'group-1',
        name: 'Climbing Club',
        description: 'Feed details',
        categoryName: 'Sport',
        memberCount: 12,
        currentUserMembership: GroupMembershipStatus.active,
      ),
      feedItems: [
        GroupFeedItem(
          type: GroupFeedItemType.post,
          id: 'post-1',
          authorId: 'user-1',
          authorUsername: 'Anna',
          content: 'Hello from the trail',
          createdAt: DateTime(2026, 6, 12, 9, 30),
        ),
        GroupFeedItem(
          type: GroupFeedItemType.event,
          id: 'event-1',
          eventId: 'event-1',
          eventName: 'Mountain walk',
          createdAt: DateTime(2026, 6, 12, 12, 45),
          eventStartAt: DateTime(2026, 6, 18, 18, 0),
        ),
      ],
      events: [
        ExploreEvent(
          id: 'event-1',
          title: 'Mountain walk',
          startsAt: DateTime.utc(2026, 6, 18, 18),
          venue: 'Trailhead',
          location: const LatLng(51.7592, 19.4550),
          organizerUsername: 'Piotr',
        ),
      ],
    );

    await tester.pumpAndSettle();

    expect(find.text('12.06.2026, 09:30'), findsOneWidget);
    expect(find.text('Piotr'), findsOneWidget);
    expect(find.text('12.06.2026, 12:45'), findsOneWidget);
    expect(find.byIcon(Icons.person_outline_rounded), findsNWidgets(2));
    expect(find.byIcon(Icons.schedule_rounded), findsNWidgets(2));
  });
}

Future<void> _pumpGroupDetails(
  WidgetTester tester, {
  required Group group,
  List<GroupFeedItem> feedItems = const [],
  List<ExploreEvent> events = const [],
}) async {
  final sessionController = SessionController(
    authRepository: AuthRepository(
      api: AuthApi(),
      storage: _FakeTokenStorage(),
    ),
  );

  final groupController = GroupController(
    groupRepository: _FakeGroupRepository(
      detailGroup: group,
      feedItems: feedItems,
      events: events,
    ),
    eventRepository: FakeEventRepository(),
    cacheService: _StubCacheService(),
    sessionController: sessionController,
  );

  await tester.pumpWidget(
    buildLocalizedTestApp(
      home: AuthScope(
        controller: sessionController,
        child: GroupScope(
          controller: groupController,
          child: const GroupDetailsScreen(groupId: 'group-1'),
        ),
      ),
    ),
  );
}

class _StubCacheService extends CacheService {
  @override
  Future<void> init() async {}

  @override
  Future<T?> get<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) async => null;

  @override
  Future<int?> getHash(String key) async => null;

  @override
  Future<List<T>?> getList<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) async => null;

  @override
  Future<void> set(String key, Map<String, dynamic> data, {int? hash}) async {}

  @override
  Future<void> setList(
    String key,
    List<Map<String, dynamic>> data, {
    int? hash,
  }) async {}

  @override
  Future<void> invalidateByPrefix(String prefix) async {}

  @override
  Future<void> clear() async {}

  @override
  Future<void> dispose() async {}

  @override
  int computeHash(Object data) => 0;
}

class _FakeTokenStorage implements AuthTokenStorage {
  @override
  Future<void> clear() async {}

  @override
  Future<AuthTokens?> readTokens() async => null;

  @override
  Future<void> saveTokens(AuthTokens tokens) async {}
}

class _FakeGroupRepository implements GroupRepository {
  const _FakeGroupRepository({
    required this.detailGroup,
    this.feedItems = const [],
    this.events = const [],
  });

  final Group detailGroup;
  final List<GroupFeedItem> feedItems;
  final List<ExploreEvent> events;

  @override
  Future<List<Group>> fetchDiscoverGroups({
    String? query,
    String? categoryId,
    int page = 0,
    int size = 20,
    String? accessToken,
    String tokenType = 'Bearer',
  }) async => const [];

  @override
  Future<List<Group>> fetchMyGroups({
    required String accessToken,
    String tokenType = 'Bearer',
  }) async => const [];

  @override
  Future<Group> fetchGroup(
    String groupId, {
    String? accessToken,
    String tokenType = 'Bearer',
  }) async {
    if (groupId != detailGroup.id) {
      throw const GroupRepositoryException('Missing group');
    }
    return detailGroup;
  }

  @override
  Future<Group> createGroup(
    GroupCreateRequest request, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) => throw UnimplementedError();

  @override
  Future<Group> updateGroup(
    String groupId,
    GroupUpdateRequest request, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) => throw UnimplementedError();

  @override
  Future<void> deleteGroup(
    String groupId, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) => throw UnimplementedError();

  @override
  Future<Group> transferOwnership(
    String groupId,
    String userId, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) => throw UnimplementedError();

  @override
  Future<GroupMember> joinGroup(
    String groupId, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) => throw UnimplementedError();

  @override
  Future<void> leaveGroup(
    String groupId, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) => throw UnimplementedError();

  @override
  Future<List<GroupMember>> fetchMembers(
    String groupId, {
    String? accessToken,
    String tokenType = 'Bearer',
  }) async => const [];

  @override
  Future<List<GroupMember>> fetchJoinRequests(
    String groupId, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) => throw UnimplementedError();

  @override
  Future<GroupMember> approveJoinRequest(
    String groupId,
    String userId, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) => throw UnimplementedError();

  @override
  Future<GroupMember> rejectJoinRequest(
    String groupId,
    String userId, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) => throw UnimplementedError();

  @override
  Future<GroupMember> changeRole(
    String groupId,
    String userId,
    GroupRole role, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) => throw UnimplementedError();

  @override
  Future<GroupMember> banMember(
    String groupId,
    String userId, {
    String? reason,
    required String accessToken,
    String tokenType = 'Bearer',
  }) => throw UnimplementedError();

  @override
  Future<GroupMember> unbanMember(
    String groupId,
    String userId, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) => throw UnimplementedError();

  @override
  Future<void> removeMember(
    String groupId,
    String userId, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) => throw UnimplementedError();

  @override
  Future<List<GroupFeedItem>> fetchFeed(
    String groupId, {
    String? accessToken,
    String tokenType = 'Bearer',
    int page = 0,
    int size = 20,
  }) async => feedItems;

  @override
  Future<GroupPost> createPost(
    String groupId,
    GroupPostRequest request, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) => throw UnimplementedError();

  @override
  Future<GroupPost> updatePost(
    String groupId,
    String postId,
    GroupPostRequest request, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) => throw UnimplementedError();

  @override
  Future<void> deletePost(
    String groupId,
    String postId, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) => throw UnimplementedError();

  @override
  Future<GroupPost> hidePost(
    String groupId,
    String postId, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) => throw UnimplementedError();

  @override
  Future<List<ExploreEvent>> fetchGroupEvents(
    String groupId, {
    String? accessToken,
    String tokenType = 'Bearer',
  }) async => events;

  @override
  Future<void> linkEvent(
    String groupId,
    String eventId, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) => throw UnimplementedError();

  @override
  Future<void> unlinkEvent(
    String groupId,
    String eventId, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) => throw UnimplementedError();

  @override
  Future<GroupReport> reportGroup(
    String groupId,
    GroupReportRequest request, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) => throw UnimplementedError();

  @override
  Future<GroupReport> reportPost(
    String groupId,
    String postId,
    GroupReportRequest request, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) => throw UnimplementedError();

  @override
  Future<GroupReport> reportEvent(
    String groupId,
    String eventId,
    GroupReportRequest request, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) => throw UnimplementedError();

  @override
  Future<List<GroupReport>> fetchReports(
    String groupId, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) => throw UnimplementedError();

  @override
  Future<GroupReport> resolveReport(
    String groupId,
    String reportId, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) => throw UnimplementedError();

  @override
  Future<GroupReport> rejectReport(
    String groupId,
    String reportId, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) => throw UnimplementedError();
}
