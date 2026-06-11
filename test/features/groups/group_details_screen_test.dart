import 'dart:async';

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

class MemoryAuthStorage implements AuthTokenStorage {
  AuthTokens? stored;

  @override
  Future<void> saveTokens(AuthTokens tokens) async {
    stored = tokens;
  }

  @override
  Future<AuthTokens?> readTokens() async => stored;

  @override
  Future<void> clear() async {
    stored = null;
  }
}

class _FakeAuthApi extends AuthApi {
  _FakeAuthApi({required this.profile}) : super();

  final UserProfile profile;

  @override
  Future<AuthResponse> login(LoginRequest request) =>
      throw StateError('login not configured');

  @override
  Future<AuthResponse> register(RegisterRequest request) =>
      throw StateError('register not configured');

  @override
  Future<AuthResponse> refresh(String refreshToken) =>
      throw StateError('refresh not configured');

  @override
  Future<AuthResponse> loginWithGoogle(String idToken) =>
      throw StateError('loginWithGoogle not configured');

  @override
  Future<UserProfile> fetchProfile({
    required String accessToken,
    String tokenType = 'Bearer',
  }) async {
    return profile;
  }

  @override
  Future<void> logout({
    required String accessToken,
    String tokenType = 'Bearer',
  }) async {}
}

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

  testWidgets('publishes a post without errors', (tester) async {
    final sessionController = await _createAuthenticatedSessionController();
    final groupRepository = _FakeGroupRepository(
      detailGroup: const Group(
        id: 'group-1',
        name: 'Climbing Club',
        description: 'Member details',
        categoryName: 'Sport',
        memberCount: 12,
        currentUserMembership: GroupMembershipStatus.active,
      ),
    );
    final groupController = GroupController(
      groupRepository: groupRepository,
      eventRepository: FakeEventRepository(),
      cacheService: _StubCacheService(),
      sessionController: sessionController,
    );

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
      sessionController: sessionController,
      groupController: groupController,
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Write post'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Hello from the wall');
    await tester.tap(find.text('Publish'));
    await tester.pumpAndSettle();

    expect(groupRepository.createdPostContents, ['Hello from the wall']);
    expect(tester.takeException(), isNull);
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

  testWidgets('removes a post immediately on delete', (tester) async {
    final sessionController = await _createAuthenticatedSessionController();
    final deleteCompleter = Completer<void>();
    final groupRepository = _FakeGroupRepository(
      detailGroup: const Group(
        id: 'group-1',
        name: 'Climbing Club',
        description: 'Member details',
        categoryName: 'Sport',
        memberCount: 12,
        currentUserMembership: GroupMembershipStatus.active,
      ),
      feedItems: [
        GroupFeedItem(
          type: GroupFeedItemType.post,
          id: 'post-1',
          authorId: 'user-1',
          authorUsername: 'tester',
          content: 'Delete me',
          createdAt: DateTime(2026, 6, 8, 12, 0),
        ),
      ],
      deletePostCompleter: deleteCompleter,
    );
    final groupController = GroupController(
      groupRepository: groupRepository,
      eventRepository: FakeEventRepository(),
      cacheService: _StubCacheService(),
      sessionController: sessionController,
    );

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
      sessionController: sessionController,
      groupController: groupController,
    );

    await tester.pumpAndSettle();

    expect(find.text('Delete me'), findsOneWidget);

    await tester.tap(
      find
          .descendant(
            of: find.byType(TabBarView),
            matching: find.byType(PopupMenuButton<String>),
          )
          .first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await tester.pump();

    expect(find.text('Delete me'), findsNothing);
    expect(find.text('Post deleted.'), findsOneWidget);

    deleteCompleter.complete();
    await tester.pumpAndSettle();

    expect(groupRepository.deletedPostIds, ['post-1']);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpGroupDetails(
  WidgetTester tester, {
  required Group group,
  List<GroupFeedItem> feedItems = const [],
  List<ExploreEvent> events = const [],
  SessionController? sessionController,
  GroupController? groupController,
}) async {
  final resolvedSessionController =
      sessionController ??
      SessionController(
        authRepository: AuthRepository(
          api: AuthApi(),
          storage: _FakeTokenStorage(),
        ),
      );

  final resolvedGroupController =
      groupController ??
      GroupController(
        groupRepository: _FakeGroupRepository(
          detailGroup: group,
          feedItems: feedItems,
          events: events,
        ),
        eventRepository: FakeEventRepository(),
        cacheService: _StubCacheService(),
        sessionController: resolvedSessionController,
      );

  await tester.pumpWidget(
    buildLocalizedTestApp(
      home: AuthScope(
        controller: resolvedSessionController,
        child: GroupScope(
          controller: resolvedGroupController,
          child: const GroupDetailsScreen(groupId: 'group-1'),
        ),
      ),
    ),
  );
}

Future<SessionController> _createAuthenticatedSessionController() async {
  final storage = MemoryAuthStorage()
    ..stored = AuthTokens(
      accessToken: 'access-token',
      refreshToken: 'refresh-token',
      tokenType: 'Bearer',
      expiresAt: DateTime.now().add(const Duration(days: 1)),
    );
  final controller = SessionController(
    authRepository: AuthRepository(
      api: _FakeAuthApi(profile: _profile()),
      storage: storage,
    ),
  );
  await controller.load();
  return controller;
}

UserProfile _profile() {
  return UserProfile(
    id: 'user-1',
    username: 'tester',
    email: 'tester@example.com',
    hasPassword: true,
    avatarUrl: null,
    bio: null,
    websiteUrl: null,
    instagramUrl: null,
    facebookUrl: null,
    createdAt: DateTime.utc(2026, 6, 1),
    eventRegistrations: const [],
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
  _FakeGroupRepository({
    required this.detailGroup,
    this.feedItems = const [],
    this.events = const [],
    this.deletePostCompleter,
  });

  final Group detailGroup;
  final List<GroupFeedItem> feedItems;
  final List<ExploreEvent> events;
  final Completer<void>? deletePostCompleter;
  final List<String> createdPostContents = [];
  final List<String> deletedPostIds = [];

  @override
  Future<List<Group>> fetchDiscoverGroups({
    String? query,
    String? categoryId,
    String? visibility,
    int page = 0,
    int size = 20,
    double? latitude,
    double? longitude,
    double? radiusKm,
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
  }) async {
    createdPostContents.add(request.content);
    return GroupPost(
      id: 'post-created',
      groupId: groupId,
      authorId: 'user-1',
      authorUsername: 'tester',
      content: request.content,
      status: 'published',
      createdAt: DateTime.utc(2026, 6, 8),
    );
  }

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
  }) async {
    deletedPostIds.add(postId);
    if (deletePostCompleter != null) {
      await deletePostCompleter!.future;
    }
  }

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

  @override
  Future<String> getPresignedUploadUrl({
    required String entityType,
    required String entityId,
    required String fileName,
    required String contentType,
    required int fileSize,
    required String accessToken,
    String tokenType = 'Bearer',
  }) => throw UnimplementedError();

  @override
  Future<void> uploadToPresignedUrl(
    String uploadUrl,
    List<int> bytes,
    String contentType,
  ) => throw UnimplementedError();

  @override
  Future<void> deletePostMedia(
    String groupId,
    String postId,
    String mediaId, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) => throw UnimplementedError();

  @override
  Future<Group> confirmAvatar(
    String groupId,
    String objectKey,
    String contentType, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) => throw UnimplementedError();

  @override
  Future<void> deleteAvatar(
    String groupId, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) => throw UnimplementedError();

  @override
  Future<Group> confirmIcon(
    String groupId,
    String objectKey,
    String contentType, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) => throw UnimplementedError();

  @override
  Future<void> deleteIcon(
    String groupId, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) => throw UnimplementedError();

  @override
  Future<Group> confirmMapPin(
    String groupId,
    String objectKey,
    String contentType, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) => throw UnimplementedError();

  @override
  Future<void> deleteMapPin(
    String groupId, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) => throw UnimplementedError();

  @override
  Future<List<GroupPostComment>> fetchComments(
    String groupId,
    String postId, {
    String? accessToken,
    String tokenType = 'Bearer',
    int page = 0,
    int size = 20,
  }) => throw UnimplementedError();

  @override
  Future<GroupPostComment> createComment(
    String groupId,
    String postId,
    GroupPostCommentRequest request, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) => throw UnimplementedError();

  @override
  Future<GroupPostComment> updateComment(
    String groupId,
    String postId,
    String commentId,
    GroupPostCommentRequest request, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) => throw UnimplementedError();

  @override
  Future<void> deleteComment(
    String groupId,
    String postId,
    String commentId, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) => throw UnimplementedError();

  @override
  Future<GroupPost> likePost(
    String groupId,
    String postId, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) => throw UnimplementedError();

  @override
  Future<GroupPost> unlikePost(
    String groupId,
    String postId, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) => throw UnimplementedError();

  @override
  Future<String> uploadGroupPostMedia(
    String groupId,
    List<int> bytes,
    String fileName, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) => throw UnimplementedError();
}
