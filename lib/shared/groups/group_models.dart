enum GroupVisibility {
  public,
  private;

  static GroupVisibility fromString(String? value) {
    return switch (value?.trim().toUpperCase()) {
      'PRIVATE' => GroupVisibility.private,
      _ => GroupVisibility.public,
    };
  }

  String toJson() => name.toUpperCase();
}

enum GroupMembershipStatus {
  active,
  pending,
  rejected,
  removed,
  banned;

  static GroupMembershipStatus? fromString(String? value) {
    return switch (value?.trim().toLowerCase()) {
      'active' => GroupMembershipStatus.active,
      'pending' => GroupMembershipStatus.pending,
      'rejected' => GroupMembershipStatus.rejected,
      'removed' => GroupMembershipStatus.removed,
      'banned' => GroupMembershipStatus.banned,
      _ => null,
    };
  }

  String toJson() => name;
}

enum GroupRole {
  admin,
  member;

  static GroupRole? fromString(String? value) {
    return switch (value?.trim().toLowerCase()) {
      'admin' => GroupRole.admin,
      'member' => GroupRole.member,
      _ => null,
    };
  }

  String toJson() => name;
}

enum GroupFeedItemType {
  post,
  event;

  static GroupFeedItemType fromString(String? value) {
    return switch (value?.trim().toUpperCase()) {
      'EVENT' => GroupFeedItemType.event,
      _ => GroupFeedItemType.post,
    };
  }
}

class GroupCreateRequest {
  const GroupCreateRequest({
    required this.name,
    this.description,
    this.categoryId,
    this.visibility = GroupVisibility.public,
    this.avatarUrl,
    this.iconUrl,
    this.mapPinIconUrl,
    this.mapPinStyle,
  });

  final String name;
  final String? description;
  final String? categoryId;
  final GroupVisibility visibility;
  final String? avatarUrl;
  final String? iconUrl;
  final String? mapPinIconUrl;
  final String? mapPinStyle;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (description != null) 'description': description,
      if (categoryId != null) 'categoryId': categoryId,
      'visibility': visibility.toJson(),
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      if (iconUrl != null) 'iconUrl': iconUrl,
      if (mapPinIconUrl != null) 'mapPinIconUrl': mapPinIconUrl,
      if (mapPinStyle != null) 'mapPinStyle': mapPinStyle,
    };
  }
}

class GroupUpdateRequest {
  const GroupUpdateRequest({
    this.name,
    this.description,
    this.categoryId,
    this.visibility,
    this.avatarUrl,
    this.iconUrl,
    this.mapPinIconUrl,
    this.mapPinStyle,
  });

  final String? name;
  final String? description;
  final String? categoryId;
  final GroupVisibility? visibility;
  final String? avatarUrl;
  final String? iconUrl;
  final String? mapPinIconUrl;
  final String? mapPinStyle;

  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (categoryId != null) 'categoryId': categoryId,
      if (visibility != null) 'visibility': visibility!.toJson(),
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      if (iconUrl != null) 'iconUrl': iconUrl,
      if (mapPinIconUrl != null) 'mapPinIconUrl': mapPinIconUrl,
      if (mapPinStyle != null) 'mapPinStyle': mapPinStyle,
    };
  }
}

class Group {
  const Group({
    required this.id,
    required this.name,
    this.description,
    this.categoryId,
    this.categoryName,
    this.visibility = GroupVisibility.public,
    this.avatarUrl,
    this.iconUrl,
    this.mapPinIconUrl,
    this.mapPinStyle,
    this.ownerUserId,
    this.createdByUserId,
    this.status,
    this.memberCount = 0,
    this.createdAt,
    this.updatedAt,
    this.currentUserMembership,
    this.currentUserRole,
    this.latitude,
    this.longitude,
  });

  final String id;
  final String name;
  final String? description;
  final String? categoryId;
  final String? categoryName;
  final GroupVisibility visibility;
  final String? avatarUrl;
  final String? iconUrl;
  final String? mapPinIconUrl;
  final String? mapPinStyle;
  final String? ownerUserId;
  final String? createdByUserId;
  final String? status;
  final int memberCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final GroupMembershipStatus? currentUserMembership;
  final GroupRole? currentUserRole;
  final double? latitude;
  final double? longitude;

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: (json['id'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      description: json['description'] as String?,
      categoryId: json['categoryId'] as String?,
      categoryName: json['categoryName'] as String?,
      visibility: GroupVisibility.fromString(json['visibility'] as String?),
      avatarUrl: json['avatarUrl'] as String?,
      iconUrl: json['iconUrl'] as String?,
      mapPinIconUrl: json['mapPinIconUrl'] as String?,
      mapPinStyle: json['mapPinStyle'] as String?,
      ownerUserId: json['ownerUserId'] as String?,
      createdByUserId: json['createdByUserId'] as String?,
      status: json['status'] as String?,
      memberCount: json['memberCount'] as int? ?? 0,
      createdAt: _parseDate(json['createdAt'] as String?),
      updatedAt: _parseDate(json['updatedAt'] as String?),
      currentUserMembership: GroupMembershipStatus.fromString(
        json['currentUserMembership'] as String?,
      ),
      currentUserRole: GroupRole.fromString(json['currentUserRole'] as String?),
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
    );
  }

  bool get isPublic => visibility == GroupVisibility.public;
  bool get isPrivate => visibility == GroupVisibility.private;
  bool get isMember => currentUserMembership == GroupMembershipStatus.active;
  bool get isPending => currentUserMembership == GroupMembershipStatus.pending;
  bool get isBanned => currentUserMembership == GroupMembershipStatus.banned;
  bool get isAdmin => currentUserRole == GroupRole.admin;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (description != null) 'description': description,
      if (categoryId != null) 'categoryId': categoryId,
      if (categoryName != null) 'categoryName': categoryName,
      'visibility': visibility.toJson(),
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      if (iconUrl != null) 'iconUrl': iconUrl,
      if (mapPinIconUrl != null) 'mapPinIconUrl': mapPinIconUrl,
      if (mapPinStyle != null) 'mapPinStyle': mapPinStyle,
      if (ownerUserId != null) 'ownerUserId': ownerUserId,
      if (createdByUserId != null) 'createdByUserId': createdByUserId,
      if (status != null) 'status': status,
      'memberCount': memberCount,
      if (createdAt != null) 'createdAt': createdAt!.toUtc().toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toUtc().toIso8601String(),
      if (currentUserMembership != null)
        'currentUserMembership': currentUserMembership!.toJson(),
      if (currentUserRole != null) 'currentUserRole': currentUserRole!.toJson(),
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    };
  }
}

class GroupMember {
  const GroupMember({
    required this.userId,
    required this.username,
    this.avatarUrl,
    this.role,
    this.status,
    this.joinedAt,
    this.approvedAt,
    this.approvedByUserId,
    this.bannedAt,
    this.bannedByUserId,
    this.banReason,
  });

  final String userId;
  final String username;
  final String? avatarUrl;
  final GroupRole? role;
  final GroupMembershipStatus? status;
  final DateTime? joinedAt;
  final DateTime? approvedAt;
  final String? approvedByUserId;
  final DateTime? bannedAt;
  final String? bannedByUserId;
  final String? banReason;

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      userId: (json['userId'] as String?) ?? '',
      username: (json['username'] as String?) ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      role: GroupRole.fromString(json['role'] as String?),
      status: GroupMembershipStatus.fromString(json['status'] as String?),
      joinedAt: _parseDate(json['joinedAt'] as String?),
      approvedAt: _parseDate(json['approvedAt'] as String?),
      approvedByUserId: json['approvedByUserId'] as String?,
      bannedAt: _parseDate(json['bannedAt'] as String?),
      bannedByUserId: json['bannedByUserId'] as String?,
      banReason: json['banReason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      if (role != null) 'role': role!.toJson(),
      if (status != null) 'status': status!.toJson(),
      if (joinedAt != null) 'joinedAt': joinedAt!.toUtc().toIso8601String(),
      if (approvedAt != null)
        'approvedAt': approvedAt!.toUtc().toIso8601String(),
      if (approvedByUserId != null) 'approvedByUserId': approvedByUserId,
      if (bannedAt != null) 'bannedAt': bannedAt!.toUtc().toIso8601String(),
      if (bannedByUserId != null) 'bannedByUserId': bannedByUserId,
      if (banReason != null) 'banReason': banReason,
    };
  }
}

class GroupFeedItem {
  const GroupFeedItem({
    required this.type,
    required this.id,
    this.authorId,
    this.authorUsername,
    this.authorAvatarUrl,
    this.title,
    this.content,
    this.mediaUrls = const [],
    this.commentCount = 0,
    this.likeCount = 0,
    this.likedByMe = false,
    this.createdAt,
    this.eventId,
    this.eventName,
    this.eventStartAt,
    this.canModerate = false,
  });

  final GroupFeedItemType type;
  final String id;
  final String? authorId;
  final String? authorUsername;
  final String? authorAvatarUrl;
  final String? title;
  final String? content;
  final List<String> mediaUrls;
  final int commentCount;
  final int likeCount;
  final bool likedByMe;
  final DateTime? createdAt;
  final String? eventId;
  final String? eventName;
  final DateTime? eventStartAt;
  final bool canModerate;

  factory GroupFeedItem.fromJson(Map<String, dynamic> json) {
    final author = _asMap(json['author']) ?? _asMap(json['organizer']);
    return GroupFeedItem(
      type: GroupFeedItemType.fromString(json['type'] as String?),
      id: (json['id'] as String?) ?? '',
      authorId:
          json['authorId'] as String? ??
          json['organizerId'] as String? ??
          author?['userId'] as String? ??
          author?['id'] as String?,
      authorUsername:
          json['authorUsername'] as String? ??
          json['organizerUsername'] as String? ??
          author?['username'] as String?,
      authorAvatarUrl:
          json['authorAvatarUrl'] as String? ?? author?['avatarUrl'] as String?,
      title: json['title'] as String?,
      content: json['content'] as String?,
      mediaUrls: (json['mediaUrls'] as List?)?.cast<String>() ?? const [],
      commentCount: json['commentCount'] as int? ?? 0,
      likeCount: json['likeCount'] as int? ?? 0,
      likedByMe: json['likedByMe'] as bool? ?? false,
      createdAt: _parseDate(json['createdAt'] as String?),
      eventId: json['eventId'] as String?,
      eventName: json['eventName'] as String?,
      eventStartAt: _parseDate(json['eventStartAt'] as String?),
      canModerate: json['canModerate'] as bool? ?? false,
    );
  }

  GroupFeedItem copyWith({
    int? commentCount,
    int? likeCount,
    bool? likedByMe,
    String? title,
    String? content,
    List<String>? mediaUrls,
  }) {
    return GroupFeedItem(
      type: type,
      id: id,
      authorId: authorId,
      authorUsername: authorUsername,
      authorAvatarUrl: authorAvatarUrl,
      title: title ?? this.title,
      content: content ?? this.content,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      commentCount: commentCount ?? this.commentCount,
      likeCount: likeCount ?? this.likeCount,
      likedByMe: likedByMe ?? this.likedByMe,
      createdAt: createdAt,
      eventId: eventId,
      eventName: eventName,
      eventStartAt: eventStartAt,
      canModerate: canModerate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'id': id,
      if (authorId != null) 'authorId': authorId,
      if (authorUsername != null) 'authorUsername': authorUsername,
      if (authorAvatarUrl != null) 'authorAvatarUrl': authorAvatarUrl,
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      'mediaUrls': mediaUrls,
      'commentCount': commentCount,
      'likeCount': likeCount,
      'likedByMe': likedByMe,
      if (createdAt != null) 'createdAt': createdAt!.toUtc().toIso8601String(),
      if (eventId != null) 'eventId': eventId,
      if (eventName != null) 'eventName': eventName,
      if (eventStartAt != null)
        'eventStartAt': eventStartAt!.toUtc().toIso8601String(),
      'canModerate': canModerate,
    };
  }
}

class GroupPostRequest {
  const GroupPostRequest({
    required this.content,
    this.title,
    this.mediaObjectKeys = const [],
  });

  final String content;
  final String? title;
  final List<String> mediaObjectKeys;

  Map<String, dynamic> toJson() => {
    'content': content,
    if (title != null) 'title': title,
    if (mediaObjectKeys.isNotEmpty) 'mediaObjectKeys': mediaObjectKeys,
  };
}

class GroupPostComment {
  const GroupPostComment({
    required this.id,
    this.postId,
    this.authorId,
    this.authorUsername,
    required this.content,
    this.mediaUrls = const [],
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String? postId;
  final String? authorId;
  final String? authorUsername;
  final String content;
  final List<String> mediaUrls;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory GroupPostComment.fromJson(Map<String, dynamic> json) {
    return GroupPostComment(
      id: (json['id'] as String?) ?? '',
      postId: json['postId'] as String?,
      authorId: json['authorId'] as String?,
      authorUsername: json['authorUsername'] as String?,
      content: (json['content'] as String?) ?? '',
      mediaUrls: (json['mediaUrls'] as List?)?.cast<String>() ?? const [],
      status: json['status'] as String?,
      createdAt: _parseDate(json['createdAt'] as String?),
      updatedAt: _parseDate(json['updatedAt'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (postId != null) 'postId': postId,
      if (authorId != null) 'authorId': authorId,
      if (authorUsername != null) 'authorUsername': authorUsername,
      'content': content,
      'mediaUrls': mediaUrls,
      if (status != null) 'status': status,
      if (createdAt != null) 'createdAt': createdAt!.toUtc().toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toUtc().toIso8601String(),
    };
  }
}

class GroupPostCommentRequest {
  const GroupPostCommentRequest({
    required this.content,
    this.mediaObjectKey,
  });

  final String content;
  final String? mediaObjectKey;

  Map<String, dynamic> toJson() => {
    'content': content,
    if (mediaObjectKey != null) 'mediaObjectKey': mediaObjectKey,
  };
}

class GroupPost {
  const GroupPost({
    required this.id,
    this.groupId,
    this.authorId,
    this.authorUsername,
    this.title,
    this.content,
    this.mediaUrls = const [],
    this.status,
    this.createdAt,
    this.commentCount = 0,
    this.likeCount = 0,
    this.likedByMe = false,
  });

  final String id;
  final String? groupId;
  final String? authorId;
  final String? authorUsername;
  final String? title;
  final String? content;
  final List<String> mediaUrls;
  final String? status;
  final DateTime? createdAt;
  final int commentCount;
  final int likeCount;
  final bool likedByMe;

  factory GroupPost.fromJson(Map<String, dynamic> json) {
    return GroupPost(
      id: (json['id'] as String?) ?? '',
      groupId: json['groupId'] as String?,
      authorId: json['authorId'] as String?,
      authorUsername: json['authorUsername'] as String?,
      title: json['title'] as String?,
      content: json['content'] as String?,
      mediaUrls: (json['mediaUrls'] as List?)?.cast<String>() ?? const [],
      status: json['status'] as String?,
      createdAt: _parseDate(json['createdAt'] as String?),
      commentCount: json['commentCount'] as int? ?? 0,
      likeCount: json['likeCount'] as int? ?? 0,
      likedByMe: json['likedByMe'] as bool? ?? false,
    );
  }

  GroupPost copyWith({
    int? commentCount,
    int? likeCount,
    bool? likedByMe,
    String? title,
    String? content,
    List<String>? mediaUrls,
    String? status,
  }) {
    return GroupPost(
      id: id,
      groupId: groupId,
      authorId: authorId,
      authorUsername: authorUsername,
      title: title ?? this.title,
      content: content ?? this.content,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      status: status ?? this.status,
      createdAt: createdAt,
      commentCount: commentCount ?? this.commentCount,
      likeCount: likeCount ?? this.likeCount,
      likedByMe: likedByMe ?? this.likedByMe,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (groupId != null) 'groupId': groupId,
      if (authorId != null) 'authorId': authorId,
      if (authorUsername != null) 'authorUsername': authorUsername,
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      'mediaUrls': mediaUrls,
      if (status != null) 'status': status,
      if (createdAt != null) 'createdAt': createdAt!.toUtc().toIso8601String(),
      'commentCount': commentCount,
      'likeCount': likeCount,
      'likedByMe': likedByMe,
    };
  }
}

class GroupReportRequest {
  const GroupReportRequest({
    required this.targetType,
    required this.targetId,
    required this.reason,
    this.description,
    this.groupId,
  });

  final String targetType;
  final String targetId;
  final String reason;
  final String? description;
  final String? groupId;

  Map<String, dynamic> toJson() {
    return {
      'targetType': targetType,
      'targetId': targetId,
      'reason': reason,
      if (description != null) 'description': description,
      if (groupId != null) 'groupId': groupId,
    };
  }
}

class GroupReport {
  const GroupReport({
    required this.id,
    this.reporterId,
    this.targetType,
    this.targetId,
    this.reason,
    this.description,
    this.status,
    this.reviewedById,
    this.reviewedAt,
    this.groupId,
    this.createdAt,
  });

  final String id;
  final String? reporterId;
  final String? targetType;
  final String? targetId;
  final String? reason;
  final String? description;
  final String? status;
  final String? reviewedById;
  final DateTime? reviewedAt;
  final String? groupId;
  final DateTime? createdAt;

  factory GroupReport.fromJson(Map<String, dynamic> json) {
    return GroupReport(
      id: (json['id'] as String?) ?? '',
      reporterId: json['reporterId'] as String?,
      targetType: json['targetType'] as String?,
      targetId: json['targetId'] as String?,
      reason: json['reason'] as String?,
      description: json['description'] as String?,
      status: json['status'] as String?,
      reviewedById: json['reviewedById'] as String?,
      reviewedAt: _parseDate(json['reviewedAt'] as String?),
      groupId: json['groupId'] as String?,
      createdAt: _parseDate(json['createdAt'] as String?),
    );
  }
}

DateTime? _parseDate(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }
  return DateTime.tryParse(value);
}

double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return null;
}
