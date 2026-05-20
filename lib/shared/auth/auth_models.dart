class AuthTokens {
  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresAt,
  });

  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final DateTime expiresAt;

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  String get authorizationHeader => '$tokenType $accessToken';
}

class AuthResponse {
  const AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
    required this.userId,
    required this.username,
    required this.role,
  });

  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;
  final String userId;
  final String username;
  final String role;

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      tokenType: json['tokenType'] as String? ?? 'Bearer',
      expiresIn: json['expiresIn'] as int? ?? 0,
      userId: json['userId'] as String,
      username: json['username'] as String,
      role: json['role'] as String? ?? 'user',
    );
  }
}

class RegisterRequest {
  const RegisterRequest({
    required this.email,
    required this.username,
    required this.password,
  });

  final String email;
  final String username;
  final String password;

  Map<String, String> toJson() {
    return {'email': email, 'username': username, 'password': password};
  }
}

class LoginRequest {
  const LoginRequest({required this.email, required this.password});

  final String email;
  final String password;

  Map<String, String> toJson() {
    return {'email': email, 'password': password};
  }
}

class RefreshTokenRequest {
  const RefreshTokenRequest({required this.refreshToken});

  final String refreshToken;

  Map<String, String> toJson() {
    return {'refreshToken': refreshToken};
  }
}

class ChangePasswordRequest {
  const ChangePasswordRequest({
    required this.oldPassword,
    required this.newPassword,
  });

  final String oldPassword;
  final String newPassword;

  Map<String, String> toJson() {
    return {'oldPassword': oldPassword, 'newPassword': newPassword};
  }
}

class UpdateProfileRequest {
  const UpdateProfileRequest({
    required this.username,
    required this.email,
    required this.avatarUrl,
    required this.bio,
    required this.websiteUrl,
    required this.instagramUrl,
    required this.facebookUrl,
  });

  final String username;
  final String email;
  final String avatarUrl;
  final String bio;
  final String websiteUrl;
  final String instagramUrl;
  final String facebookUrl;

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'websiteUrl': websiteUrl,
      'instagramUrl': instagramUrl,
      'facebookUrl': facebookUrl,
    };
  }
}

class GoogleOAuthRequest {
  const GoogleOAuthRequest({required this.idToken});

  final String idToken;

  Map<String, String> toJson() {
    return {'idToken': idToken};
  }
}

class FavoriteEventSummary {
  const FavoriteEventSummary({
    required this.eventId,
    required this.name,
    required this.startAt,
    this.endAt,
    this.categoryNames = const [],
  });

  final String eventId;
  final String name;
  final DateTime startAt;
  final DateTime? endAt;
  final List<String> categoryNames;

  factory FavoriteEventSummary.fromJson(Map<String, dynamic> json) {
    return FavoriteEventSummary(
      eventId: json['eventId'] as String,
      name: json['name'] as String? ?? '',
      startAt:
          DateTime.tryParse(json['startAt'] as String? ?? '') ??
          DateTime.now().toUtc(),
      endAt: json['endAt'] != null
          ? DateTime.tryParse(json['endAt'] as String)
          : null,
      categoryNames:
          (json['categoryNames'] as List?)?.cast<String>() ?? const [],
    );
  }
}

class ProfileEventSummary {
  const ProfileEventSummary({
    required this.eventId,
    required this.name,
    required this.startAt,
    this.endAt,
    this.categoryNames = const [],
    this.registeredAt,
  });

  final String eventId;
  final String name;
  final DateTime startAt;
  final DateTime? endAt;
  final List<String> categoryNames;
  final DateTime? registeredAt;

  factory ProfileEventSummary.fromJson(Map<String, dynamic> json) {
    return ProfileEventSummary(
      eventId: json['eventId'] as String,
      name: json['name'] as String? ?? '',
      startAt:
          DateTime.tryParse(json['startAt'] as String? ?? '') ??
          DateTime.now().toUtc(),
      endAt: json['endAt'] != null
          ? DateTime.tryParse(json['endAt'] as String)
          : null,
      categoryNames:
          (json['categoryNames'] as List?)?.cast<String>() ?? const [],
      registeredAt: json['registeredAt'] != null
          ? DateTime.tryParse(json['registeredAt'] as String)
          : null,
    );
  }
}

class UserProfile {
  const UserProfile({
    required this.id,
    required this.username,
    required this.email,
    required this.hasPassword,
    required this.avatarUrl,
    required this.bio,
    required this.websiteUrl,
    required this.instagramUrl,
    required this.facebookUrl,
    required this.createdAt,
    required this.eventRegistrations,
    this.role,
    this.favorites = const [],
    this.organizer = false,
    this.admin = false,
    this.organizerVerificationStatus,
    this.organizerVerificationNotes,
  });

  final String id;
  final String username;
  final String email;
  final bool hasPassword;
  final String? role;
  final String? avatarUrl;
  final String? bio;
  final String? websiteUrl;
  final String? instagramUrl;
  final String? facebookUrl;
  final DateTime createdAt;
  final List<ProfileEventSummary> eventRegistrations;
  final List<FavoriteEventSummary> favorites;
  final bool organizer;
  final bool admin;
  final String? organizerVerificationStatus;
  final String? organizerVerificationNotes;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final registrations = json['eventRegistrations'];
    final rawFavorites = json['favorites'];
    return UserProfile(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      hasPassword: json['hasPassword'] as bool? ?? false,
      role: json['role'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      bio: json['bio'] as String?,
      websiteUrl: json['websiteUrl'] as String?,
      instagramUrl: json['instagramUrl'] as String?,
      facebookUrl: json['facebookUrl'] as String?,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      eventRegistrations: registrations is List
          ? registrations
                .map(
                  (item) => ProfileEventSummary.fromJson(
                    Map<String, dynamic>.from(item as Map),
                  ),
                )
                .toList()
          : const [],
      favorites: rawFavorites is List
          ? rawFavorites
                .map(
                  (item) => FavoriteEventSummary.fromJson(
                    Map<String, dynamic>.from(item as Map),
                  ),
                )
                .toList()
          : const [],
      organizer: json['organizer'] as bool? ?? false,
      admin: json['admin'] as bool? ?? false,
      organizerVerificationStatus:
          json['organizerVerificationStatus'] as String?,
      organizerVerificationNotes: json['organizerVerificationNotes'] as String?,
    );
  }
}

extension UserProfileRoleX on UserProfile {
  String get normalizedRole => role?.trim().toLowerCase() ?? '';

  bool get hasOrganizerReviewAccess {
    final value = normalizedRole;
    return value.contains('admin') || value.contains('organizer');
  }
}
