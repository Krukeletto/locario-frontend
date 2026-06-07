import 'package:flutter_test/flutter_test.dart';
import 'package:locario/features/explore/models.dart';
import 'package:locario/features/groups/group_discover_screen.dart';
import 'package:locario/shared/auth/auth_api.dart';
import 'package:locario/shared/auth/auth_models.dart';
import 'package:locario/shared/auth/auth_repository.dart';
import 'package:locario/shared/auth/auth_scope.dart';
import 'package:locario/shared/auth/session_controller.dart';
import 'package:locario/shared/cache/cache_service.dart';
import 'package:locario/shared/events/category_controller.dart';
import 'package:locario/shared/events/category_scope.dart';
import 'package:locario/shared/groups/group_controller.dart';
import 'package:locario/shared/groups/group_models.dart';
import 'package:locario/shared/groups/group_repository.dart';
import 'package:locario/shared/groups/group_scope.dart';

import '../../test_helpers/fake_event_repository.dart';
import '../../test_helpers/test_app.dart';

void main() {
  testWidgets('renders discover and my groups for organizer', (tester) async {
    final categoryController = CategoryController(
      eventRepository: FakeEventRepository(
        categories: const [Category(id: 'music', name: 'Music', slug: 'music')],
      ),
    );
    await categoryController.loadCategories();

    final sessionController = await _createSessionController();
    final groupController = GroupController(
      groupRepository: const _FakeGroupRepository(
        discoverGroups: [
          Group(
            id: 'group-1',
            name: 'Jazz Crew',
            categoryName: 'Music',
            memberCount: 12,
          ),
        ],
        myGroups: [
          Group(
            id: 'group-2',
            name: 'Workshop Squad',
            categoryName: 'Art',
            memberCount: 4,
            currentUserMembership: GroupMembershipStatus.active,
          ),
        ],
      ),
      eventRepository: FakeEventRepository(),
      cacheService: _StubCacheService(),
      sessionController: sessionController,
    );

    await tester.pumpWidget(
      buildLocalizedTestApp(
        home: AuthScope(
          controller: sessionController,
          child: CategoryScope(
            controller: categoryController,
            child: GroupScope(
              controller: groupController,
              child: const GroupDiscoverScreen(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Create group'), findsOneWidget);
    expect(find.text('Workshop Squad'), findsOneWidget);

    await tester.tap(find.text('Discover'));
    await tester.pumpAndSettle();
    expect(find.text('Jazz Crew'), findsOneWidget);
  });
}

class _StubCacheService extends CacheService {
  @override
  Future<void> init() async {}

  @override
  Future<int?> getHash(String key) async => null;

  @override
  Future<List<T>?> getList<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) async => null;

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

class _FakeGroupRepository implements GroupRepository {
  const _FakeGroupRepository({
    this.discoverGroups = const [],
    this.myGroups = const [],
  });

  final List<Group> discoverGroups;
  final List<Group> myGroups;

  @override
  Future<List<Group>> fetchDiscoverGroups({
    String? query,
    String? categoryId,
    int page = 0,
    int size = 20,
    String? accessToken,
    String tokenType = 'Bearer',
  }) async => discoverGroups;

  @override
  Future<List<Group>> fetchMyGroups({
    required String accessToken,
    String tokenType = 'Bearer',
  }) async => myGroups;

  @override
  Future<Group> fetchGroup(
    String groupId, {
    String? accessToken,
    String tokenType = 'Bearer',
  }) => throw UnimplementedError();

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
  }) => throw UnimplementedError();

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
  }) => throw UnimplementedError();

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
  }) => throw UnimplementedError();

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

class _MemoryAuthStorage implements AuthTokenStorage {
  AuthTokens? stored;

  @override
  Future<void> clear() async {
    stored = null;
  }

  @override
  Future<AuthTokens?> readTokens() async => stored;

  @override
  Future<void> saveTokens(AuthTokens tokens) async {
    stored = tokens;
  }
}

class _FakeAuthApi extends AuthApi {
  _FakeAuthApi({required this.profile}) : super();

  final UserProfile profile;

  @override
  Future<UserProfile> fetchProfile({
    required String accessToken,
    String tokenType = 'Bearer',
  }) {
    return Future.value(profile);
  }
}

Future<SessionController> _createSessionController() async {
  final storage = _MemoryAuthStorage();
  storage.stored = AuthTokens(
    accessToken: 'access-token',
    refreshToken: 'refresh-token',
    tokenType: 'Bearer',
    expiresAt: DateTime.now().add(const Duration(hours: 1)),
  );

  final controller = SessionController(
    authRepository: AuthRepository(
      api: _FakeAuthApi(
        profile: UserProfile(
          id: 'organizer-id',
          username: 'organizer',
          email: 'organizer@example.com',
          hasPassword: true,
          avatarUrl: null,
          bio: null,
          websiteUrl: null,
          instagramUrl: null,
          facebookUrl: null,
          createdAt: DateTime.utc(2026, 5, 1),
          eventRegistrations: const [],
          role: 'organizer',
          organizer: true,
        ),
      ),
      storage: storage,
    ),
  );

  await controller.load();
  return controller;
}
