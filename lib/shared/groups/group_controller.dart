import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../features/explore/models.dart';
import '../auth/session_controller.dart';
import '../cache/cache_service.dart';
import '../events/event_repository.dart';
import 'group_models.dart';
import 'group_repository.dart';

class GroupController extends ChangeNotifier {
  GroupController({
    required GroupRepository groupRepository,
    required EventRepository eventRepository,
    required CacheService cacheService,
    required SessionController sessionController,
  }) : _groupRepository = groupRepository,
       _eventRepository = eventRepository,
       _cache = cacheService,
       _sessionController = sessionController;

  final GroupRepository _groupRepository;
  final EventRepository _eventRepository;
  final CacheService _cache;
  final SessionController _sessionController;

  String? get _accessToken => _sessionController.tokens?.accessToken;
  String get _tokenType => _sessionController.tokens?.tokenType ?? 'Bearer';

  List<Group> _discoverGroups = [];
  bool _isDiscoverLoading = false;
  bool _isDiscoverRefreshing = false;
  String? _discoverError;
  String _discoverSearch = '';
  String? _discoverCategoryId;

  List<Group> _myGroups = [];
  bool _isMyGroupsLoading = false;
  bool _isMyGroupsRefreshing = false;

  Group? _detailGroup;
  List<GroupMember> _detailMembers = [];
  List<GroupFeedItem> _detailFeed = [];
  List<ExploreEvent> _detailEvents = [];
  List<GroupMember> _detailJoinRequests = [];
  List<GroupReport> _detailReports = [];
  bool _isDetailLoading = false;
  bool _isDetailRefreshing = false;
  String? _detailError;
  int _detailFeedPage = 0;
  bool _hasMoreFeed = true;
  bool _isLoadingMoreFeed = false;

  List<Group> get discoverGroups => List.unmodifiable(_discoverGroups);
  bool get isDiscoverLoading => _isDiscoverLoading;
  bool get isDiscoverRefreshing => _isDiscoverRefreshing;
  String? get discoverError => _discoverError;
  String get discoverSearch => _discoverSearch;
  String? get discoverCategoryId => _discoverCategoryId;

  List<Group> get myGroups => List.unmodifiable(_myGroups);
  bool get isMyGroupsLoading => _isMyGroupsLoading;
  bool get isMyGroupsRefreshing => _isMyGroupsRefreshing;

  Group? get detailGroup => _detailGroup;
  List<GroupMember> get detailMembers => List.unmodifiable(_detailMembers);
  List<GroupFeedItem> get detailFeed => List.unmodifiable(_detailFeed);
  List<ExploreEvent> get detailEvents => List.unmodifiable(_detailEvents);
  List<GroupMember> get detailJoinRequests =>
      List.unmodifiable(_detailJoinRequests);
  List<GroupReport> get detailReports => List.unmodifiable(_detailReports);
  bool get isDetailLoading => _isDetailLoading;
  bool get isDetailRefreshing => _isDetailRefreshing;
  String? get detailError => _detailError;
  bool get hasMoreFeed => _hasMoreFeed;
  bool get isLoadingMoreFeed => _isLoadingMoreFeed;

  int _computeListHash(List<Object?> items) =>
      jsonEncode(items.map((e) => (e as dynamic).toJson()).toList()).hashCode;

  // ── Discover ──────────────────────────────────────────────────────────

  Future<void> loadDiscoverGroups({
    String? search,
    String? categoryId,
    bool forceRefresh = false,
  }) async {
    _discoverSearch = search ?? '';
    _discoverCategoryId = categoryId;
    final cacheKey =
        'discover_groups_${_discoverSearch}_${_discoverCategoryId ?? 'all'}';

    if (!forceRefresh) {
      final cached = await _cache.getList<Group>(cacheKey, Group.fromJson);
      if (cached != null) {
        _discoverGroups = cached;
        _isDiscoverLoading = false;
        _isDiscoverRefreshing = true;
        notifyListeners();
      }
    }

    if (_discoverGroups.isEmpty && !forceRefresh) {
      _isDiscoverLoading = true;
      _discoverError = null;
      notifyListeners();
    }

    try {
      final fresh = await _groupRepository.fetchDiscoverGroups(
        query: _discoverSearch.isNotEmpty ? _discoverSearch : null,
        categoryId: _discoverCategoryId,
        accessToken: _accessToken,
        tokenType: _tokenType,
      );

      final freshHash = _computeListHash(fresh);
      final cachedHash = await _cache.getHash(cacheKey);

      if (freshHash != cachedHash) {
        _discoverGroups = fresh;
        await _cache.setList(
          cacheKey,
          fresh.map((g) => g.toJson()).toList(),
          hash: freshHash,
        );
        notifyListeners();
      }
    } catch (e) {
      if (_discoverGroups.isEmpty) {
        _discoverError = e.toString();
        notifyListeners();
      }
    } finally {
      _isDiscoverLoading = false;
      _isDiscoverRefreshing = false;
      notifyListeners();
    }
  }

  // ── My groups ─────────────────────────────────────────────────────────

  Future<void> loadMyGroups({bool forceRefresh = false}) async {
    if (_accessToken == null) return;
    const cacheKey = 'my_groups';

    if (!forceRefresh) {
      final cached = await _cache.getList<Group>(cacheKey, Group.fromJson);
      if (cached != null) {
        _myGroups = cached;
        _isMyGroupsLoading = false;
        _isMyGroupsRefreshing = true;
        notifyListeners();
      }
    }

    if (_myGroups.isEmpty && !forceRefresh) {
      _isMyGroupsLoading = true;
      notifyListeners();
    }

    try {
      final fresh = await _groupRepository.fetchMyGroups(
        accessToken: _accessToken!,
        tokenType: _tokenType,
      );

      final freshHash = _computeListHash(fresh);
      final cachedHash = await _cache.getHash(cacheKey);

      if (freshHash != cachedHash) {
        _myGroups = fresh;
        await _cache.setList(
          cacheKey,
          fresh.map((g) => g.toJson()).toList(),
          hash: freshHash,
        );
        notifyListeners();
      }
    } catch (e) {
      // Keep cached data on error
    } finally {
      _isMyGroupsLoading = false;
      _isMyGroupsRefreshing = false;
      notifyListeners();
    }
  }

  // ── Group detail ──────────────────────────────────────────────────────

  Future<void> loadGroupDetail(
    String groupId, {
    bool refreshOnly = false,
  }) async {
    _clearDetail();

    if (!refreshOnly) {
      _isDetailLoading = true;
      _detailError = null;
      notifyListeners();
    } else {
      _isDetailRefreshing = true;
      notifyListeners();
    }

    try {
      final group = await _groupRepository.fetchGroup(
        groupId,
        accessToken: _accessToken,
        tokenType: _tokenType,
      );
      _detailGroup = group;
      notifyListeners();

      unawaited(loadGroupMembers(groupId));
      unawaited(loadGroupFeed(groupId, page: 0));
      unawaited(loadGroupEvents(groupId));

      if (_canModerate(group)) {
        unawaited(loadGroupJoinRequests(groupId));
        unawaited(loadGroupReports(groupId));
      }
    } catch (e) {
      if (!refreshOnly) {
        _detailError = e.toString();
      }
      notifyListeners();
    } finally {
      _isDetailLoading = false;
      _isDetailRefreshing = false;
      notifyListeners();
    }
  }

  Future<void> loadGroupMembers(String groupId) async {
    try {
      _detailMembers = await _groupRepository.fetchMembers(
        groupId,
        accessToken: _accessToken,
        tokenType: _tokenType,
      );
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadGroupFeed(String groupId, {int page = 0}) async {
    try {
      final items = await _groupRepository.fetchFeed(
        groupId,
        accessToken: _accessToken,
        tokenType: _tokenType,
        page: page,
      );
      _detailFeedPage = page;
      _hasMoreFeed = items.length >= 20;
      if (page == 0) {
        _detailFeed = items;
      } else {
        _detailFeed = [..._detailFeed, ...items];
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadMoreGroupFeed(String groupId) async {
    if (!_hasMoreFeed || _isLoadingMoreFeed) return;
    _isLoadingMoreFeed = true;
    notifyListeners();
    try {
      await loadGroupFeed(groupId, page: _detailFeedPage + 1);
    } finally {
      _isLoadingMoreFeed = false;
      notifyListeners();
    }
  }

  Future<void> loadGroupEvents(String groupId) async {
    try {
      _detailEvents = await _groupRepository.fetchGroupEvents(
        groupId,
        accessToken: _accessToken,
        tokenType: _tokenType,
      );
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadGroupJoinRequests(String groupId) async {
    if (_accessToken == null) return;
    try {
      _detailJoinRequests = await _groupRepository.fetchJoinRequests(
        groupId,
        accessToken: _accessToken!,
        tokenType: _tokenType,
      );
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadGroupReports(String groupId) async {
    if (_accessToken == null) return;
    try {
      _detailReports = await _groupRepository.fetchReports(
        groupId,
        accessToken: _accessToken!,
        tokenType: _tokenType,
      );
      notifyListeners();
    } catch (_) {}
  }

  // ── Mutations ─────────────────────────────────────────────────────────

  Future<void> joinGroup(String groupId) async {
    if (_accessToken == null) return;
    try {
      await _groupRepository.joinGroup(
        groupId,
        accessToken: _accessToken!,
        tokenType: _tokenType,
      );
      await loadGroupDetail(groupId, refreshOnly: true);
    } catch (_) {}
  }

  Future<void> leaveGroup(String groupId) async {
    if (_accessToken == null) return;
    try {
      await _groupRepository.leaveGroup(
        groupId,
        accessToken: _accessToken!,
        tokenType: _tokenType,
      );
      await loadGroupDetail(groupId, refreshOnly: true);
    } catch (_) {}
  }

  Future<void> createPost(String groupId, String content) async {
    if (_accessToken == null) return;
    try {
      await _groupRepository.createPost(
        groupId,
        GroupPostRequest(content: content),
        accessToken: _accessToken!,
        tokenType: _tokenType,
      );
      unawaited(loadGroupFeed(groupId, page: 0));
    } catch (_) {}
  }

  Future<void> approveJoinRequest(String groupId, String userId) async {
    if (_accessToken == null) return;
    try {
      await _groupRepository.approveJoinRequest(
        groupId,
        userId,
        accessToken: _accessToken!,
        tokenType: _tokenType,
      );
      await loadGroupMembers(groupId);
      await loadGroupJoinRequests(groupId);
    } catch (_) {}
  }

  Future<void> rejectJoinRequest(String groupId, String userId) async {
    if (_accessToken == null) return;
    try {
      await _groupRepository.rejectJoinRequest(
        groupId,
        userId,
        accessToken: _accessToken!,
        tokenType: _tokenType,
      );
      await loadGroupJoinRequests(groupId);
    } catch (_) {}
  }

  Future<void> invalidateGroupDetail(String groupId) async {
    await _cache.invalidateByPrefix('group_detail_$groupId');
    await loadGroupDetail(groupId);
  }

  Future<void> updatePost(String groupId, String postId, String content) async {
    if (_accessToken == null) return;
    try {
      await _groupRepository.updatePost(
        groupId,
        postId,
        GroupPostRequest(content: content),
        accessToken: _accessToken!,
        tokenType: _tokenType,
      );
      await loadGroupFeed(groupId, page: 0);
    } catch (_) {}
  }

  Future<void> deletePost(String groupId, String postId) async {
    if (_accessToken == null) return;
    try {
      await _groupRepository.deletePost(
        groupId,
        postId,
        accessToken: _accessToken!,
        tokenType: _tokenType,
      );
      await loadGroupFeed(groupId, page: 0);
    } catch (_) {}
  }

  Future<void> hidePost(String groupId, String postId) async {
    if (_accessToken == null) return;
    try {
      await _groupRepository.hidePost(
        groupId,
        postId,
        accessToken: _accessToken!,
        tokenType: _tokenType,
      );
      await loadGroupFeed(groupId, page: 0);
    } catch (_) {}
  }

  Future<void> changeRole(String groupId, String userId, GroupRole role) async {
    if (_accessToken == null) return;
    try {
      await _groupRepository.changeRole(
        groupId,
        userId,
        role,
        accessToken: _accessToken!,
        tokenType: _tokenType,
      );
      await loadGroupMembers(groupId);
    } catch (_) {}
  }

  Future<void> banMember(String groupId, String userId) async {
    if (_accessToken == null) return;
    try {
      await _groupRepository.banMember(
        groupId,
        userId,
        accessToken: _accessToken!,
        tokenType: _tokenType,
      );
      await loadGroupMembers(groupId);
    } catch (_) {}
  }

  Future<void> unbanMember(String groupId, String userId) async {
    if (_accessToken == null) return;
    try {
      await _groupRepository.unbanMember(
        groupId,
        userId,
        accessToken: _accessToken!,
        tokenType: _tokenType,
      );
      await loadGroupMembers(groupId);
    } catch (_) {}
  }

  Future<void> removeMember(String groupId, String userId) async {
    if (_accessToken == null) return;
    try {
      await _groupRepository.removeMember(
        groupId,
        userId,
        accessToken: _accessToken!,
        tokenType: _tokenType,
      );
      await loadGroupMembers(groupId);
    } catch (_) {}
  }

  Future<void> transferOwnership(String groupId, String userId) async {
    if (_accessToken == null) return;
    try {
      await _groupRepository.transferOwnership(
        groupId,
        userId,
        accessToken: _accessToken!,
        tokenType: _tokenType,
      );
      await loadGroupMembers(groupId);
    } catch (_) {}
  }

  Future<void> deleteGroup(String groupId) async {
    if (_accessToken == null) return;
    try {
      await _groupRepository.deleteGroup(
        groupId,
        accessToken: _accessToken!,
        tokenType: _tokenType,
      );
    } catch (_) {}
  }

  Future<GroupReport> reportGroup(
    String groupId,
    GroupReportRequest request,
  ) async {
    return _groupRepository.reportGroup(
      groupId,
      request,
      accessToken: _accessToken!,
      tokenType: _tokenType,
    );
  }

  Future<GroupReport> reportPost(
    String groupId,
    String postId,
    GroupReportRequest request,
  ) async {
    return _groupRepository.reportPost(
      groupId,
      postId,
      request,
      accessToken: _accessToken!,
      tokenType: _tokenType,
    );
  }

  Future<GroupReport> reportEvent(
    String groupId,
    String eventId,
    GroupReportRequest request,
  ) async {
    return _groupRepository.reportEvent(
      groupId,
      eventId,
      request,
      accessToken: _accessToken!,
      tokenType: _tokenType,
    );
  }

  Future<void> resolveReport(String groupId, String reportId) async {
    if (_accessToken == null) return;
    try {
      await _groupRepository.resolveReport(
        groupId,
        reportId,
        accessToken: _accessToken!,
        tokenType: _tokenType,
      );
      await loadGroupReports(groupId);
    } catch (_) {}
  }

  Future<void> rejectReport(String groupId, String reportId) async {
    if (_accessToken == null) return;
    try {
      await _groupRepository.rejectReport(
        groupId,
        reportId,
        accessToken: _accessToken!,
        tokenType: _tokenType,
      );
      await loadGroupReports(groupId);
    } catch (_) {}
  }

  Future<void> linkEvent(String groupId, String eventId) async {
    if (_accessToken == null) return;
    try {
      await _groupRepository.linkEvent(
        groupId,
        eventId,
        accessToken: _accessToken!,
        tokenType: _tokenType,
      );
      await loadGroupEvents(groupId);
    } catch (_) {}
  }

  Future<void> unlinkEvent(String groupId, String eventId) async {
    if (_accessToken == null) return;
    try {
      await _groupRepository.unlinkEvent(
        groupId,
        eventId,
        accessToken: _accessToken!,
        tokenType: _tokenType,
      );
      await loadGroupEvents(groupId);
    } catch (_) {}
  }

  Future<List<ExploreEvent>> fetchOrganizerEvents() async {
    if (_accessToken == null) return [];
    try {
      return await _eventRepository.fetchOrganizerEvents(
        accessToken: _accessToken!,
        tokenType: _tokenType,
      );
    } catch (_) {
      return [];
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────

  bool _canModerate(Group? group) {
    if (group == null || _accessToken == null) return false;
    return group.isAdmin ||
        (group.ownerUserId != null &&
            group.ownerUserId == _sessionController.profile?.id);
  }

  void _clearDetail() {
    _detailGroup = null;
    _detailMembers = [];
    _detailFeed = [];
    _detailEvents = [];
    _detailJoinRequests = [];
    _detailReports = [];
    _detailFeedPage = 0;
    _hasMoreFeed = true;
  }
}
