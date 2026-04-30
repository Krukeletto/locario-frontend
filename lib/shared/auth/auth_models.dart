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
    return {
      'email': email,
      'username': username,
      'password': password,
    };
  }
}

class LoginRequest {
  const LoginRequest({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  Map<String, String> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class RefreshTokenRequest {
  const RefreshTokenRequest({required this.refreshToken});

  final String refreshToken;

  Map<String, String> toJson() {
    return {'refreshToken': refreshToken};
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
  });

  final String id;
  final String username;
  final String email;
  final bool hasPassword;
  final String? avatarUrl;
  final String? bio;
  final String? websiteUrl;
  final String? instagramUrl;
  final String? facebookUrl;
  final DateTime createdAt;
  final List<dynamic> eventRegistrations;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final registrations = json['eventRegistrations'];
    return UserProfile(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      hasPassword: json['hasPassword'] as bool? ?? false,
      avatarUrl: json['avatarUrl'] as String?,
      bio: json['bio'] as String?,
      websiteUrl: json['websiteUrl'] as String?,
      instagramUrl: json['instagramUrl'] as String?,
      facebookUrl: json['facebookUrl'] as String?,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      eventRegistrations: registrations is List
          ? List<dynamic>.from(registrations)
          : const [],
    );
  }
}
