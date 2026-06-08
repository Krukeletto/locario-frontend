import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:locario/features/explore/models.dart';
import 'package:locario/shared/auth/auth_api.dart';
import 'package:locario/shared/auth/auth_models.dart';
import 'package:locario/shared/auth/auth_repository.dart';
import 'package:locario/shared/auth/session_controller.dart';
import 'package:locario/shared/cache/cache_service.dart';
import 'package:locario/shared/groups/group_controller.dart';
import 'package:locario/shared/groups/group_models.dart';
import 'package:locario/shared/groups/group_repository.dart';

import '../../test_helpers/fake_event_repository.dart';

void main() {
  test(
    'filters discover groups already in my groups and falls back for detail',
    () async {
      final sessionController = _TestSessionController(
        tokens: AuthTokens(
          accessToken: 'access-token',
          refreshToken: 'refresh-token',
          tokenType: 'Bearer',
          expiresAt: DateTime.utc(2099, 1, 1),
        ),
        profile: _profile,
      );
      const repository = _FakeGroupRepository(
        discoverGroups: [
          Group(
            id: 'discover-1',
            name: 'Open Group',
            description: 'Visible in discover',
            visibility: GroupVisibility.public,
            memberCount: 12,
          ),
          Group(
            id: 'my-1',
            name: 'My Group',
            description: 'Should be hidden from discover',
            visibility: GroupVisibility.public,
            memberCount: 4,
            currentUserMembership: GroupMembershipStatus.active,
          ),
        ],
        myGroups: [
          Group(
            id: 'my-1',
            name: 'My Group',
            description: 'Should be hidden from discover',
            visibility: GroupVisibility.public,
            memberCount: 4,
            currentUserMembership: GroupMembershipStatus.active,
          ),
        ],
        detailGroups: {
          'discover-1': Group(
            id: 'discover-1',
            name: 'Open Group',
            description: 'Visible in discover',
            visibility: GroupVisibility.public,
            memberCount: 12,
          ),
        },
      );
      final controller = GroupController(
        groupRepository: repository,
        eventRepository: FakeEventRepository(),
        cacheService: _MemoryCacheService(),
        sessionController: sessionController,
      );

      await controller.loadDiscoverGroups();
      await controller.loadMyGroups();

      expect(controller.discoverGroups, hasLength(1));
      expect(controller.discoverGroups.single.id, 'discover-1');
      expect(controller.discoverGroups.single.name, 'Open Group');

      await controller.loadGroupDetail('discover-1');

      expect(controller.detailError, isNull);
      expect(controller.detailGroup, isNotNull);
      expect(controller.detailGroup!.id, 'discover-1');
      expect(controller.detailGroup!.name, 'Open Group');
    },
  );
}

final _profile = UserProfile(
  id: 'user-1',
  username: 'tester',
  email: 'tester@example.com',
  hasPassword: true,
  avatarUrl: null,
  bio: null,
  websiteUrl: null,
  instagramUrl: null,
  facebookUrl: null,
  createdAt: DateTime.utc(2026),
  eventRegistrations: const [],
  organizer: false,
  admin: false,
);

class _TestSessionController extends SessionController {
  _TestSessionController({required this.tokens, required this.profile})
    : super(
        authRepository: AuthRepository(
          api: AuthApi(client: http.Client(), baseUrl: 'http://localhost'),
          storage: _MemoryAuthStorage(),
        ),
      );

  @override
  final AuthTokens? tokens;

  @override
  final UserProfile? profile;

  @override
  bool get isAuthenticated => tokens != null;

  @override
  bool get isLoading => false;
}

class _MemoryAuthStorage implements AuthTokenStorage {
  AuthTokens? _tokens;

  @override
  Future<void> clear() async {
    _tokens = null;
  }

  @override
  Future<AuthTokens?> readTokens() async => _tokens;

  @override
  Future<void> saveTokens(AuthTokens tokens) async {
    _tokens = tokens;
  }
}

class _MemoryCacheService extends CacheService {
  final Map<String, String> _raw = {};
  final Map<String, int> _hashes = {};

  @override
  Future<void> init() async {}

  @override
  Future<String?> getRaw(String key) async => _raw[key];

  @override
  Future<void> setRaw(String key, String data, {int? hash}) async {
    _raw[key] = data;
    _hashes[key] = hash ?? data.hashCode;
  }

  @override
  Future<void> invalidate(String key) async {
    _raw.remove(key);
    _hashes.remove(key);
  }

  @override
  Future<void> invalidateByPrefix(String prefix) async {
    final keys = _raw.keys.where((key) => key.startsWith(prefix)).toList();
    for (final key in keys) {
      await invalidate(key);
    }
  }

  @override
  Future<void> clear() async {
    _raw.clear();
    _hashes.clear();
  }

  @override
  Future<void> dispose() async {}

  @override
  Future<int?> getHash(String key) async => _hashes[key];
}

class _FakeGroupRepository implements GroupRepository {
  const _FakeGroupRepository({
    this.discoverGroups = const [],
    this.myGroups = const [],
    this.detailGroups = const {},
  });

  final List<Group> discoverGroups;
  final List<Group> myGroups;
  final Map<String, Group> detailGroups;

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
  }) async {
    final group = detailGroups[groupId];
    if (group == null) {
      throw const GroupRepositoryException(
        'Unable to fetch group',
        statusCode: 404,
      );
    }
    if (accessToken != null) {
      throw const GroupRepositoryException(
        'Unable to fetch group',
        statusCode: 403,
      );
    }
    return group;
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
  }) => throw const GroupRepositoryException('Unable to fetch members');

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
  }) => throw const GroupRepositoryException('Unable to fetch feed');

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
  }) => throw const GroupRepositoryException('Unable to fetch events');

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
