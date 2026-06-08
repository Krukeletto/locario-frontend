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
    this.content,
    this.mediaUrls = const [],
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
  final String? content;
  final List<String> mediaUrls;
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
      content: json['content'] as String?,
      mediaUrls: (json['mediaUrls'] as List?)?.cast<String>() ?? const [],
      createdAt: _parseDate(json['createdAt'] as String?),
      eventId: json['eventId'] as String?,
      eventName: json['eventName'] as String?,
      eventStartAt: _parseDate(json['eventStartAt'] as String?),
      canModerate: json['canModerate'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'id': id,
      if (authorId != null) 'authorId': authorId,
      if (authorUsername != null) 'authorUsername': authorUsername,
      if (authorAvatarUrl != null) 'authorAvatarUrl': authorAvatarUrl,
      if (content != null) 'content': content,
      'mediaUrls': mediaUrls,
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
  const GroupPostRequest({required this.content});

  final String content;

  Map<String, dynamic> toJson() => {'content': content};
}

class GroupPost {
  const GroupPost({
    required this.id,
    this.groupId,
    this.authorId,
    this.authorUsername,
    this.content,
    this.status,
    this.createdAt,
  });

  final String id;
  final String? groupId;
  final String? authorId;
  final String? authorUsername;
  final String? content;
  final String? status;
  final DateTime? createdAt;

  factory GroupPost.fromJson(Map<String, dynamic> json) {
    return GroupPost(
      id: (json['id'] as String?) ?? '',
      groupId: json['groupId'] as String?,
      authorId: json['authorId'] as String?,
      authorUsername: json['authorUsername'] as String?,
      content: json['content'] as String?,
      status: json['status'] as String?,
      createdAt: _parseDate(json['createdAt'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (groupId != null) 'groupId': groupId,
      if (authorId != null) 'authorId': authorId,
      if (authorUsername != null) 'authorUsername': authorUsername,
      if (content != null) 'content': content,
      if (status != null) 'status': status,
      if (createdAt != null) 'createdAt': createdAt!.toUtc().toIso8601String(),
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

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return null;
}
