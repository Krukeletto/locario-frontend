import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:locario/features/explore/models.dart';
import 'package:locario/shared/config/api_config.dart';

import 'group_models.dart';

class GroupRepositoryException implements Exception {
  const GroupRepositoryException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'GroupRepositoryException($statusCode): $message';
}

abstract class GroupRepository {
  Future<String> getPresignedUploadUrl({
    required String entityType,
    required String entityId,
    required String fileName,
    required String contentType,
    required int fileSize,
    required String accessToken,
    String tokenType = 'Bearer',
  });
  Future<void> uploadToPresignedUrl(
    String uploadUrl,
    List<int> bytes,
    String contentType,
  );
  Future<void> deletePostMedia(
    String groupId,
    String postId,
    String mediaId, {
    required String accessToken,
    String tokenType = 'Bearer',
  });
  Future<Group> confirmAvatar(
    String groupId,
    String objectKey,
    String contentType, {
    required String accessToken,
    String tokenType = 'Bearer',
  });
  Future<void> deleteAvatar(
    String groupId, {
    required String accessToken,
    String tokenType = 'Bearer',
  });
  Future<Group> confirmIcon(
    String groupId,
    String objectKey,
    String contentType, {
    required String accessToken,
    String tokenType = 'Bearer',
  });
  Future<void> deleteIcon(
    String groupId, {
    required String accessToken,
    String tokenType = 'Bearer',
  });
  Future<Group> confirmMapPin(
    String groupId,
    String objectKey,
    String contentType, {
    required String accessToken,
    String tokenType = 'Bearer',
  });
  Future<void> deleteMapPin(
    String groupId, {
    required String accessToken,
    String tokenType = 'Bearer',
  });
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
  });
  Future<List<Group>> fetchMyGroups({
    required String accessToken,
    String tokenType = 'Bearer',
  });
  Future<Group> fetchGroup(
    String groupId, {
    String? accessToken,
    String tokenType = 'Bearer',
  });
  Future<Group> createGroup(
    GroupCreateRequest request, {
    required String accessToken,
    String tokenType = 'Bearer',
  });
  Future<Group> updateGroup(
    String groupId,
    GroupUpdateRequest request, {
    required String accessToken,
    String tokenType = 'Bearer',
  });
  Future<void> deleteGroup(
    String groupId, {
    required String accessToken,
    String tokenType = 'Bearer',
  });
  Future<Group> transferOwnership(
    String groupId,
    String userId, {
    required String accessToken,
    String tokenType = 'Bearer',
  });
  Future<GroupMember> joinGroup(
    String groupId, {
    required String accessToken,
    String tokenType = 'Bearer',
  });
  Future<void> leaveGroup(
    String groupId, {
    required String accessToken,
    String tokenType = 'Bearer',
  });
  Future<List<GroupMember>> fetchMembers(
    String groupId, {
    String? accessToken,
    String tokenType = 'Bearer',
  });
  Future<List<GroupMember>> fetchJoinRequests(
    String groupId, {
    required String accessToken,
    String tokenType = 'Bearer',
  });
  Future<GroupMember> approveJoinRequest(
    String groupId,
    String userId, {
    required String accessToken,
    String tokenType = 'Bearer',
  });
  Future<GroupMember> rejectJoinRequest(
    String groupId,
    String userId, {
    required String accessToken,
    String tokenType = 'Bearer',
  });
  Future<GroupMember> changeRole(
    String groupId,
    String userId,
    GroupRole role, {
    required String accessToken,
    String tokenType = 'Bearer',
  });
  Future<GroupMember> banMember(
    String groupId,
    String userId, {
    String? reason,
    required String accessToken,
    String tokenType = 'Bearer',
  });
  Future<GroupMember> unbanMember(
    String groupId,
    String userId, {
    required String accessToken,
    String tokenType = 'Bearer',
  });
  Future<void> removeMember(
    String groupId,
    String userId, {
    required String accessToken,
    String tokenType = 'Bearer',
  });
  Future<List<GroupFeedItem>> fetchFeed(
    String groupId, {
    String? accessToken,
    String tokenType = 'Bearer',
    int page = 0,
    int size = 20,
  });
  Future<GroupPost> createPost(
    String groupId,
    GroupPostRequest request, {
    required String accessToken,
    String tokenType = 'Bearer',
  });
  Future<GroupPost> updatePost(
    String groupId,
    String postId,
    GroupPostRequest request, {
    required String accessToken,
    String tokenType = 'Bearer',
  });
  Future<void> deletePost(
    String groupId,
    String postId, {
    required String accessToken,
    String tokenType = 'Bearer',
  });
  Future<GroupPost> hidePost(
    String groupId,
    String postId, {
    required String accessToken,
    String tokenType = 'Bearer',
  });
  Future<List<ExploreEvent>> fetchGroupEvents(
    String groupId, {
    String? accessToken,
    String tokenType = 'Bearer',
  });
  Future<void> linkEvent(
    String groupId,
    String eventId, {
    required String accessToken,
    String tokenType = 'Bearer',
  });
  Future<void> unlinkEvent(
    String groupId,
    String eventId, {
    required String accessToken,
    String tokenType = 'Bearer',
  });
  Future<GroupReport> reportGroup(
    String groupId,
    GroupReportRequest request, {
    required String accessToken,
    String tokenType = 'Bearer',
  });
  Future<GroupReport> reportPost(
    String groupId,
    String postId,
    GroupReportRequest request, {
    required String accessToken,
    String tokenType = 'Bearer',
  });
  Future<GroupReport> reportEvent(
    String groupId,
    String eventId,
    GroupReportRequest request, {
    required String accessToken,
    String tokenType = 'Bearer',
  });
  Future<List<GroupReport>> fetchReports(
    String groupId, {
    required String accessToken,
    String tokenType = 'Bearer',
  });
  Future<GroupReport> resolveReport(
    String groupId,
    String reportId, {
    required String accessToken,
    String tokenType = 'Bearer',
  });
  Future<GroupReport> rejectReport(
    String groupId,
    String reportId, {
    required String accessToken,
    String tokenType = 'Bearer',
  });

  // ── Post interactions: comments ──────────────────────────────────────

  Future<List<GroupPostComment>> fetchComments(
    String groupId,
    String postId, {
    String? accessToken,
    String tokenType = 'Bearer',
    int page = 0,
    int size = 20,
  });

  Future<GroupPostComment> createComment(
    String groupId,
    String postId,
    GroupPostCommentRequest request, {
    required String accessToken,
    String tokenType = 'Bearer',
  });

  Future<GroupPostComment> updateComment(
    String groupId,
    String postId,
    String commentId,
    GroupPostCommentRequest request, {
    required String accessToken,
    String tokenType = 'Bearer',
  });

  Future<void> deleteComment(
    String groupId,
    String postId,
    String commentId, {
    required String accessToken,
    String tokenType = 'Bearer',
  });

  // ── Post interactions: likes ─────────────────────────────────────────

  Future<GroupPost> likePost(
    String groupId,
    String postId, {
    required String accessToken,
    String tokenType = 'Bearer',
  });

  Future<GroupPost> unlikePost(
    String groupId,
    String postId, {
    required String accessToken,
    String tokenType = 'Bearer',
  });

  // ── Post media upload ────────────────────────────────────────────────

  Future<String> uploadGroupPostMedia(
    String groupId,
    List<int> bytes,
    String fileName, {
    required String accessToken,
    String tokenType = 'Bearer',
  });
}

class HttpGroupRepository implements GroupRepository {
  HttpGroupRepository({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = baseUrl ?? ApiConfig.baseUrl;

  final http.Client _client;
  final String _baseUrl;

  Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  Map<String, String> _authHeaders(
    String accessToken,
    String tokenType, {
    bool includeJson = false,
  }) {
    return {
      'Authorization': '$tokenType $accessToken',
      if (includeJson) 'Content-Type': 'application/json',
    };
  }

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
  }) async {
    final response = await _client.get(
      _uri('/api/groups/discover').replace(
        queryParameters: {
          if (query != null && query.isNotEmpty) 'q': query,
          if (categoryId != null && categoryId.isNotEmpty)
            'categoryId': categoryId,
          if (visibility != null && visibility.isNotEmpty)
            'visibility': visibility,
          if (latitude != null) 'lat': latitude.toString(),
          if (longitude != null) 'lng': longitude.toString(),
          if (radiusKm != null) 'radiusKm': radiusKm.toString(),
          'page': '$page',
          'size': '$size',
        },
      ),
      headers: accessToken == null
          ? null
          : _authHeaders(accessToken, tokenType),
    );

    if (response.statusCode != 200) {
      throw GroupRepositoryException(
        'Unable to fetch discover groups',
        statusCode: response.statusCode,
      );
    }

    return _decodeGroupList(response.body);
  }

  @override
  Future<List<Group>> fetchMyGroups({
    required String accessToken,
    String tokenType = 'Bearer',
  }) async {
    final response = await _client.get(
      _uri('/api/groups/my'),
      headers: _authHeaders(accessToken, tokenType),
    );

    if (response.statusCode != 200) {
      throw GroupRepositoryException(
        'Unable to fetch my groups',
        statusCode: response.statusCode,
      );
    }

    return _decodeGroupList(response.body);
  }

  @override
  Future<Group> fetchGroup(
    String groupId, {
    String? accessToken,
    String tokenType = 'Bearer',
  }) async {
    final response = await _client.get(
      _uri('/api/groups/$groupId'),
      headers: accessToken == null
          ? null
          : _authHeaders(accessToken, tokenType),
    );

    if (response.statusCode != 200) {
      throw GroupRepositoryException(
        'Unable to fetch group',
        statusCode: response.statusCode,
      );
    }

    return _decodeGroup(response.body);
  }

  @override
  Future<Group> createGroup(
    GroupCreateRequest request, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) async {
    final response = await _client.post(
      _uri('/api/groups'),
      headers: _authHeaders(accessToken, tokenType, includeJson: true),
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw GroupRepositoryException(
        'Unable to create group',
        statusCode: response.statusCode,
      );
    }

    return _decodeGroup(response.body);
  }

  @override
  Future<Group> updateGroup(
    String groupId,
    GroupUpdateRequest request, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) async {
    final response = await _client.patch(
      _uri('/api/groups/$groupId'),
      headers: _authHeaders(accessToken, tokenType, includeJson: true),
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 200) {
      throw GroupRepositoryException(
        'Unable to update group',
        statusCode: response.statusCode,
      );
    }

    return _decodeGroup(response.body);
  }

  @override
  Future<void> deleteGroup(
    String groupId, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) async {
    final response = await _client.delete(
      _uri('/api/groups/$groupId'),
      headers: _authHeaders(accessToken, tokenType),
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw GroupRepositoryException(
        'Unable to delete group',
        statusCode: response.statusCode,
      );
    }
  }

  @override
  Future<Group> transferOwnership(
    String groupId,
    String userId, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) async {
    final response = await _client.post(
      _uri('/api/groups/$groupId/transfer-ownership/$userId'),
      headers: _authHeaders(accessToken, tokenType),
    );

    if (response.statusCode != 200) {
      throw GroupRepositoryException(
        'Unable to transfer ownership',
        statusCode: response.statusCode,
      );
    }

    return _decodeGroup(response.body);
  }

  @override
  Future<GroupMember> joinGroup(
    String groupId, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) async {
    final response = await _client.post(
      _uri('/api/groups/$groupId/join'),
      headers: _authHeaders(accessToken, tokenType),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw GroupRepositoryException(
        'Unable to join group',
        statusCode: response.statusCode,
      );
    }

    return _decodeMember(response.body);
  }

  @override
  Future<void> leaveGroup(
    String groupId, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) async {
    final response = await _client.post(
      _uri('/api/groups/$groupId/leave'),
      headers: _authHeaders(accessToken, tokenType),
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw GroupRepositoryException(
        'Unable to leave group',
        statusCode: response.statusCode,
      );
    }
  }

  @override
  Future<List<GroupMember>> fetchMembers(
    String groupId, {
    String? accessToken,
    String tokenType = 'Bearer',
  }) async {
    final response = await _client.get(
      _uri('/api/groups/$groupId/members'),
      headers: accessToken == null
          ? null
          : _authHeaders(accessToken, tokenType),
    );

    if (response.statusCode != 200) {
      throw GroupRepositoryException(
        'Unable to fetch members',
        statusCode: response.statusCode,
      );
    }

    return _decodeMemberList(response.body);
  }

  @override
  Future<List<GroupMember>> fetchJoinRequests(
    String groupId, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) async {
    final response = await _client.get(
      _uri('/api/groups/$groupId/join-requests'),
      headers: _authHeaders(accessToken, tokenType),
    );

    if (response.statusCode != 200) {
      throw GroupRepositoryException(
        'Unable to fetch join requests',
        statusCode: response.statusCode,
      );
    }

    return _decodeMemberList(response.body);
  }

  @override
  Future<GroupMember> approveJoinRequest(
    String groupId,
    String userId, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) async {
    final response = await _client.post(
      _uri('/api/groups/$groupId/join-requests/$userId/approve'),
      headers: _authHeaders(accessToken, tokenType),
    );

    if (response.statusCode != 200) {
      throw GroupRepositoryException(
        'Unable to approve join request',
        statusCode: response.statusCode,
      );
    }

    return _decodeMember(response.body);
  }

  @override
  Future<GroupMember> rejectJoinRequest(
    String groupId,
    String userId, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) async {
    final response = await _client.post(
      _uri('/api/groups/$groupId/join-requests/$userId/reject'),
      headers: _authHeaders(accessToken, tokenType),
    );

    if (response.statusCode != 200) {
      throw GroupRepositoryException(
        'Unable to reject join request',
        statusCode: response.statusCode,
      );
    }

    return _decodeMember(response.body);
  }

  @override
  Future<GroupMember> changeRole(
    String groupId,
    String userId,
    GroupRole role, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) async {
    final response = await _client.patch(
      _uri('/api/groups/$groupId/members/$userId/role'),
      headers: _authHeaders(accessToken, tokenType, includeJson: true),
      body: jsonEncode({'role': role.toJson()}),
    );

    if (response.statusCode != 200) {
      throw GroupRepositoryException(
        'Unable to change role',
        statusCode: response.statusCode,
      );
    }

    return _decodeMember(response.body);
  }

  @override
  Future<GroupMember> banMember(
    String groupId,
    String userId, {
    String? reason,
    required String accessToken,
    String tokenType = 'Bearer',
  }) async {
    final response = await _client.post(
      _uri('/api/groups/$groupId/members/$userId/ban'),
      headers: _authHeaders(accessToken, tokenType, includeJson: true),
      body: jsonEncode({'reason': reason}),
    );

    if (response.statusCode != 200) {
      throw GroupRepositoryException(
        'Unable to ban member',
        statusCode: response.statusCode,
      );
    }

    return _decodeMember(response.body);
  }

  @override
  Future<GroupMember> unbanMember(
    String groupId,
    String userId, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) async {
    final response = await _client.post(
      _uri('/api/groups/$groupId/members/$userId/unban'),
      headers: _authHeaders(accessToken, tokenType),
    );

    if (response.statusCode != 200) {
      throw GroupRepositoryException(
        'Unable to unban member',
        statusCode: response.statusCode,
      );
    }

    return _decodeMember(response.body);
  }

  @override
  Future<void> removeMember(
    String groupId,
    String userId, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) async {
    final response = await _client.delete(
      _uri('/api/groups/$groupId/members/$userId'),
      headers: _authHeaders(accessToken, tokenType),
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw GroupRepositoryException(
        'Unable to remove member',
        statusCode: response.statusCode,
      );
    }
  }

  @override
  Future<List<GroupFeedItem>> fetchFeed(
    String groupId, {
    String? accessToken,
    String tokenType = 'Bearer',
    int page = 0,
    int size = 20,
  }) async {
    final response = await _client.get(
      _uri(
        '/api/groups/$groupId/feed',
      ).replace(queryParameters: {'page': '$page', 'size': '$size'}),
      headers: accessToken == null
          ? null
          : _authHeaders(accessToken, tokenType),
    );

    if (response.statusCode != 200) {
      throw GroupRepositoryException(
        'Unable to fetch feed',
        statusCode: response.statusCode,
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw const GroupRepositoryException('Unexpected group feed payload');
    }

    return decoded
        .whereType<Map>()
        .map((item) => GroupFeedItem.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  @override
  Future<GroupPost> createPost(
    String groupId,
    GroupPostRequest request, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) async {
    final response = await _client.post(
      _uri('/api/groups/$groupId/posts'),
      headers: _authHeaders(accessToken, tokenType, includeJson: true),
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw GroupRepositoryException(
        'Unable to create post',
        statusCode: response.statusCode,
      );
    }

    return _decodePost(response.body);
  }

  @override
  Future<GroupPost> updatePost(
    String groupId,
    String postId,
    GroupPostRequest request, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) async {
    final response = await _client.patch(
      _uri('/api/groups/$groupId/posts/$postId'),
      headers: _authHeaders(accessToken, tokenType, includeJson: true),
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 200) {
      throw GroupRepositoryException(
        'Unable to update post',
        statusCode: response.statusCode,
      );
    }

    return _decodePost(response.body);
  }

  @override
  Future<void> deletePost(
    String groupId,
    String postId, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) async {
    final response = await _client.delete(
      _uri('/api/groups/$groupId/posts/$postId'),
      headers: _authHeaders(accessToken, tokenType),
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw GroupRepositoryException(
        'Unable to delete post',
        statusCode: response.statusCode,
      );
    }
  }

  @override
  Future<GroupPost> hidePost(
    String groupId,
    String postId, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) async {
    final response = await _client.post(
      _uri('/api/groups/$groupId/posts/$postId/hide'),
      headers: _authHeaders(accessToken, tokenType),
    );

    if (response.statusCode != 200) {
      throw GroupRepositoryException(
        'Unable to hide post',
        statusCode: response.statusCode,
      );
    }

    return _decodePost(response.body);
  }

  @override
  Future<List<ExploreEvent>> fetchGroupEvents(
    String groupId, {
    String? accessToken,
    String tokenType = 'Bearer',
  }) async {
    final response = await _client.get(
      _uri('/api/groups/$groupId/events'),
      headers: accessToken == null
          ? null
          : _authHeaders(accessToken, tokenType),
    );

    if (response.statusCode != 200) {
      throw GroupRepositoryException(
        'Unable to fetch group events',
        statusCode: response.statusCode,
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw const GroupRepositoryException('Unexpected group events payload');
    }

    return decoded
        .whereType<Map>()
        .map((item) => ExploreEvent.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  @override
  Future<void> linkEvent(
    String groupId,
    String eventId, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) async {
    final response = await _client.post(
      _uri('/api/groups/$groupId/events/$eventId'),
      headers: _authHeaders(accessToken, tokenType),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw GroupRepositoryException(
        'Unable to link event',
        statusCode: response.statusCode,
      );
    }
  }

  @override
  Future<void> unlinkEvent(
    String groupId,
    String eventId, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) async {
    final response = await _client.delete(
      _uri('/api/groups/$groupId/events/$eventId'),
      headers: _authHeaders(accessToken, tokenType),
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw GroupRepositoryException(
        'Unable to unlink event',
        statusCode: response.statusCode,
      );
    }
  }

  @override
  Future<GroupReport> reportGroup(
    String groupId,
    GroupReportRequest request, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) {
    return _report(
      _uri('/api/groups/$groupId/reports'),
      request,
      accessToken: accessToken,
      tokenType: tokenType,
    );
  }

  @override
  Future<GroupReport> reportPost(
    String groupId,
    String postId,
    GroupReportRequest request, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) {
    return _report(
      _uri('/api/groups/$groupId/posts/$postId/report'),
      request,
      accessToken: accessToken,
      tokenType: tokenType,
    );
  }

  @override
  Future<GroupReport> reportEvent(
    String groupId,
    String eventId,
    GroupReportRequest request, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) {
    return _report(
      _uri('/api/groups/$groupId/events/$eventId/report'),
      request,
      accessToken: accessToken,
      tokenType: tokenType,
    );
  }

  @override
  Future<List<GroupReport>> fetchReports(
    String groupId, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) async {
    final response = await _client.get(
      _uri('/api/groups/$groupId/reports'),
      headers: _authHeaders(accessToken, tokenType),
    );

    if (response.statusCode != 200) {
      throw GroupRepositoryException(
        'Unable to fetch reports',
        statusCode: response.statusCode,
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw const GroupRepositoryException('Unexpected group reports payload');
    }

    return decoded
        .whereType<Map>()
        .map((item) => GroupReport.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  @override
  Future<GroupReport> resolveReport(
    String groupId,
    String reportId, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) {
    return _updateReportStatus(
      _uri('/api/groups/$groupId/reports/$reportId/resolve'),
      accessToken: accessToken,
      tokenType: tokenType,
      status: 'reviewed',
    );
  }

  @override
  Future<GroupReport> rejectReport(
    String groupId,
    String reportId, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) {
    return _updateReportStatus(
      _uri('/api/groups/$groupId/reports/$reportId/reject'),
      accessToken: accessToken,
      tokenType: tokenType,
      status: 'dismissed',
    );
  }

  Future<GroupReport> _report(
    Uri uri,
    GroupReportRequest request, {
    required String accessToken,
    required String tokenType,
  }) async {
    final response = await _client.post(
      uri,
      headers: _authHeaders(accessToken, tokenType, includeJson: true),
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw GroupRepositoryException(
        'Unable to create report',
        statusCode: response.statusCode,
      );
    }

    return _decodeReport(response.body);
  }

  Future<GroupReport> _updateReportStatus(
    Uri uri, {
    required String accessToken,
    required String tokenType,
    required String status,
  }) async {
    final response = await _client.post(
      uri,
      headers: _authHeaders(accessToken, tokenType, includeJson: true),
      body: jsonEncode({'status': status}),
    );

    if (response.statusCode != 200) {
      throw GroupRepositoryException(
        'Unable to update report',
        statusCode: response.statusCode,
      );
    }

    return _decodeReport(response.body);
  }

  List<Group> _decodeGroupList(String body) {
    final decoded = jsonDecode(body);
    if (decoded is List) {
      return decoded
          .whereType<Map>()
          .map((item) => Group.fromJson(Map<String, dynamic>.from(item)))
          .toList(growable: false);
    }
    if (decoded is Map && decoded['content'] is List) {
      final content = decoded['content'] as List;
      return content
          .whereType<Map>()
          .map((item) => Group.fromJson(Map<String, dynamic>.from(item)))
          .toList(growable: false);
    }
    throw const GroupRepositoryException('Unexpected groups payload');
  }

  Group _decodeGroup(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map) {
      throw const GroupRepositoryException('Unexpected group payload');
    }
    return Group.fromJson(Map<String, dynamic>.from(decoded));
  }

  List<GroupMember> _decodeMemberList(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! List) {
      throw const GroupRepositoryException('Unexpected members payload');
    }
    return decoded
        .whereType<Map>()
        .map((item) => GroupMember.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  GroupMember _decodeMember(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map) {
      throw const GroupRepositoryException('Unexpected member payload');
    }
    return GroupMember.fromJson(Map<String, dynamic>.from(decoded));
  }

  GroupPost _decodePost(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map) {
      throw const GroupRepositoryException('Unexpected post payload');
    }
    return GroupPost.fromJson(Map<String, dynamic>.from(decoded));
  }

  GroupReport _decodeReport(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map) {
      throw const GroupRepositoryException('Unexpected report payload');
    }
    return GroupReport.fromJson(Map<String, dynamic>.from(decoded));
  }

  @override
  Future<String> getPresignedUploadUrl({
    required String entityType,
    required String entityId,
    required String fileName,
    required String contentType,
    required int fileSize,
    required String accessToken,
    String tokenType = 'Bearer',
  }) async {
    final response = await _client.post(
      _uri('/api/media/presigned-upload-url'),
      headers: _authHeaders(accessToken, tokenType, includeJson: true),
      body: jsonEncode({
        'entityType': entityType,
        'entityId': entityId,
        'fileName': fileName,
        'contentType': contentType,
        'fileSize': fileSize,
      }),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw GroupRepositoryException(
        'Unable to get presigned upload URL',
        statusCode: response.statusCode,
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return decoded['uploadUrl'] as String;
  }

  @override
  Future<void> uploadToPresignedUrl(
    String uploadUrl,
    List<int> bytes,
    String contentType,
  ) async {
    final request = http.Request('PUT', Uri.parse(uploadUrl));
    request.headers['Content-Type'] = contentType;
    request.bodyBytes = bytes;

    final streamedResponse = await _client.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw GroupRepositoryException(
        'Upload to storage failed',
        statusCode: response.statusCode,
      );
    }
  }

  @override
  Future<void> deletePostMedia(
    String groupId,
    String postId,
    String mediaId, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) async {
    final response = await _client.delete(
      _uri('/api/groups/$groupId/posts/$postId/media/$mediaId'),
      headers: _authHeaders(accessToken, tokenType),
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw GroupRepositoryException(
        'Unable to delete post media',
        statusCode: response.statusCode,
      );
    }
  }

  @override
  Future<Group> confirmAvatar(
    String groupId,
    String objectKey,
    String contentType, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) async {
    final response = await _client.post(
      _uri('/api/groups/$groupId/avatar'),
      headers: _authHeaders(accessToken, tokenType, includeJson: true),
      body: jsonEncode({'objectKey': objectKey, 'contentType': contentType}),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw GroupRepositoryException(
        'Unable to confirm avatar',
        statusCode: response.statusCode,
      );
    }

    return _decodeGroup(response.body);
  }

  @override
  Future<void> deleteAvatar(
    String groupId, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) async {
    final response = await _client.delete(
      _uri('/api/groups/$groupId/avatar'),
      headers: _authHeaders(accessToken, tokenType),
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw GroupRepositoryException(
        'Unable to delete avatar',
        statusCode: response.statusCode,
      );
    }
  }

  @override
  Future<Group> confirmIcon(
    String groupId,
    String objectKey,
    String contentType, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) async {
    final response = await _client.post(
      _uri('/api/groups/$groupId/icon'),
      headers: _authHeaders(accessToken, tokenType, includeJson: true),
      body: jsonEncode({'objectKey': objectKey, 'contentType': contentType}),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw GroupRepositoryException(
        'Unable to confirm icon',
        statusCode: response.statusCode,
      );
    }

    return _decodeGroup(response.body);
  }

  @override
  Future<void> deleteIcon(
    String groupId, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) async {
    final response = await _client.delete(
      _uri('/api/groups/$groupId/icon'),
      headers: _authHeaders(accessToken, tokenType),
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw GroupRepositoryException(
        'Unable to delete icon',
        statusCode: response.statusCode,
      );
    }
  }

  @override
  Future<Group> confirmMapPin(
    String groupId,
    String objectKey,
    String contentType, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) async {
    final response = await _client.post(
      _uri('/api/groups/$groupId/map-pin'),
      headers: _authHeaders(accessToken, tokenType, includeJson: true),
      body: jsonEncode({'objectKey': objectKey, 'contentType': contentType}),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw GroupRepositoryException(
        'Unable to confirm map pin',
        statusCode: response.statusCode,
      );
    }

    return _decodeGroup(response.body);
  }

  @override
  Future<void> deleteMapPin(
    String groupId, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) async {
    final response = await _client.delete(
      _uri('/api/groups/$groupId/map-pin'),
      headers: _authHeaders(accessToken, tokenType),
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw GroupRepositoryException(
        'Unable to delete map pin',
        statusCode: response.statusCode,
      );
    }
  }

  // ── Comments ───────────────────────────────────────────────────────────

  @override
  Future<List<GroupPostComment>> fetchComments(
    String groupId,
    String postId, {
    String? accessToken,
    String tokenType = 'Bearer',
    int page = 0,
    int size = 20,
  }) async {
    final response = await _client.get(
      _uri(
        '/api/groups/$groupId/posts/$postId/comments',
      ).replace(queryParameters: {'page': '$page', 'size': '$size'}),
      headers: accessToken == null
          ? null
          : _authHeaders(accessToken, tokenType),
    );

    if (response.statusCode != 200) {
      throw GroupRepositoryException(
        'Unable to fetch comments',
        statusCode: response.statusCode,
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is List) {
      return decoded
          .whereType<Map>()
          .map(
            (item) =>
                GroupPostComment.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(growable: false);
    }
    if (decoded is Map && decoded['content'] is List) {
      return (decoded['content'] as List)
          .whereType<Map>()
          .map(
            (item) =>
                GroupPostComment.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(growable: false);
    }
    throw const GroupRepositoryException('Unexpected comments payload');
  }

  @override
  Future<GroupPostComment> createComment(
    String groupId,
    String postId,
    GroupPostCommentRequest request, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) async {
    final response = await _client.post(
      _uri('/api/groups/$groupId/posts/$postId/comments'),
      headers: _authHeaders(accessToken, tokenType, includeJson: true),
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw GroupRepositoryException(
        'Unable to create comment',
        statusCode: response.statusCode,
      );
    }

    return _decodeComment(response.body);
  }

  @override
  Future<GroupPostComment> updateComment(
    String groupId,
    String postId,
    String commentId,
    GroupPostCommentRequest request, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) async {
    final response = await _client.patch(
      _uri('/api/groups/$groupId/posts/$postId/comments/$commentId'),
      headers: _authHeaders(accessToken, tokenType, includeJson: true),
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 200) {
      throw GroupRepositoryException(
        'Unable to update comment',
        statusCode: response.statusCode,
      );
    }

    return _decodeComment(response.body);
  }

  @override
  Future<void> deleteComment(
    String groupId,
    String postId,
    String commentId, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) async {
    final response = await _client.delete(
      _uri('/api/groups/$groupId/posts/$postId/comments/$commentId'),
      headers: _authHeaders(accessToken, tokenType),
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw GroupRepositoryException(
        'Unable to delete comment',
        statusCode: response.statusCode,
      );
    }
  }

  // ── Likes ──────────────────────────────────────────────────────────────

  @override
  Future<GroupPost> likePost(
    String groupId,
    String postId, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) async {
    final response = await _client.put(
      _uri('/api/groups/$groupId/posts/$postId/like'),
      headers: _authHeaders(accessToken, tokenType),
    );

    if (response.statusCode != 200) {
      throw GroupRepositoryException(
        'Unable to like post',
        statusCode: response.statusCode,
      );
    }

    return _decodePost(response.body);
  }

  @override
  Future<GroupPost> unlikePost(
    String groupId,
    String postId, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) async {
    final response = await _client.delete(
      _uri('/api/groups/$groupId/posts/$postId/like'),
      headers: _authHeaders(accessToken, tokenType),
    );

    if (response.statusCode != 200) {
      throw GroupRepositoryException(
        'Unable to unlike post',
        statusCode: response.statusCode,
      );
    }

    return _decodePost(response.body);
  }

  // ── Post media upload ──────────────────────────────────────────────────

  @override
  Future<String> uploadGroupPostMedia(
    String groupId,
    List<int> bytes,
    String fileName, {
    required String accessToken,
    String tokenType = 'Bearer',
  }) async {
    final contentType = _resolveImageMimeType(fileName);

    final response = await _client.post(
      _uri('/api/media/presigned-upload-url'),
      headers: _authHeaders(accessToken, tokenType, includeJson: true),
      body: jsonEncode({
        'entityType': 'GROUP_POST',
        'entityId': groupId,
        'fileName': fileName,
        'contentType': contentType,
        'fileSize': bytes.length,
      }),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw GroupRepositoryException(
        'Unable to get presigned upload URL',
        statusCode: response.statusCode,
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final uploadUrl = decoded['uploadUrl'] as String;
    final objectKey = decoded['objectKey'] as String;

    final uploadResponse = await http.put(
      Uri.parse(uploadUrl),
      headers: {'Content-Type': contentType},
      body: bytes,
    );

    if (uploadResponse.statusCode != 200) {
      throw GroupRepositoryException(
        'Unable to upload group post media',
        statusCode: uploadResponse.statusCode,
      );
    }

    return objectKey;
  }

  String _resolveImageMimeType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    return switch (extension) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      'gif' => 'image/gif',
      'jpg' || 'jpeg' => 'image/jpeg',
      _ => 'image/jpeg',
    };
  }
}

GroupPostComment _decodeComment(String body) {
  final decoded = jsonDecode(body);
  if (decoded is! Map) {
    throw const GroupRepositoryException('Unexpected comment payload');
  }
  return GroupPostComment.fromJson(Map<String, dynamic>.from(decoded));
}
