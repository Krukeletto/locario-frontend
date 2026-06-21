import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:locario/features/profile/edit_profile_screen.dart';
import 'package:locario/shared/auth/auth_api.dart';
import 'package:locario/shared/auth/auth_models.dart';
import 'package:locario/shared/auth/auth_repository.dart';
import 'package:locario/shared/auth/session_controller.dart';
import 'package:locario/shared/auth/auth_scope.dart';
import 'package:locario/shared/auth/auth_repository.dart' as repo;

import '../../test_helpers/test_app.dart';

class _MemoryAuthStorage implements repo.AuthTokenStorage {
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
  _FakeAuthApi({this.onFetchProfile, this.onUpdateProfile}) : super();

  final Future<UserProfile> Function(String accessToken, String tokenType)?
  onFetchProfile;
  final Future<UserProfile> Function(
    String accessToken,
    UpdateProfileRequest request,
    String tokenType,
  )?
  onUpdateProfile;

  @override
  Future<UserProfile> fetchProfile({
    required String accessToken,
    String tokenType = 'Bearer',
  }) {
    if (onFetchProfile != null) return onFetchProfile!(accessToken, tokenType);
    throw StateError('fetchProfile not configured');
  }

  @override
  Future<UserProfile> updateProfile({
    required String accessToken,
    required UpdateProfileRequest request,
    String tokenType = 'Bearer',
  }) {
    if (onUpdateProfile != null) {
      return onUpdateProfile!(accessToken, request, tokenType);
    }
    throw StateError('updateProfile not configured');
  }
}

UserProfile _sampleProfile() {
  return UserProfile(
    id: 'u1',
    username: 'tester',
    email: 'tester@example.com',
    hasPassword: true,
    avatarUrl: null,
    bio: null,
    websiteUrl: null,
    instagramUrl: null,
    facebookUrl: null,
    createdAt: DateTime.utc(2026, 5, 1),
    eventRegistrations: const [],
  );
}

UserProfile _sampleProfileWithLinks() {
  return UserProfile(
    id: 'u1',
    username: 'tester',
    email: 'tester@example.com',
    hasPassword: true,
    avatarUrl: null,
    bio: 'Existing bio',
    websiteUrl: 'https://example.com',
    instagramUrl: 'https://instagram.com/tester',
    facebookUrl: 'https://facebook.com/tester',
    createdAt: DateTime.utc(2026, 5, 1),
    eventRegistrations: const [],
  );
}

Future<SessionController> _createSessionController({
  required AuthApi api,
  AuthTokens? tokens,
}) async {
  final storage = _MemoryAuthStorage();
  storage.stored = tokens;
  final controller = SessionController(
    authRepository: AuthRepository(api: api, storage: storage),
  );
  await controller.load();
  return controller;
}

void main() {
  testWidgets('shows validation errors for links', (tester) async {
    final api = _FakeAuthApi(onFetchProfile: (_, _) async => _sampleProfile());

    final tokens = AuthTokens(
      accessToken: 'access',
      refreshToken: 'refresh',
      tokenType: 'Bearer',
      expiresAt: DateTime.utc(2099),
    );

    final controller = await _createSessionController(api: api, tokens: tokens);

    await tester.pumpWidget(
      AuthScope(
        controller: controller,
        child: buildLocalizedTestApp(home: const EditProfileScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // Find the inner EditableText for each keyed TextFormField so
    // `tester.enterText` can focus and type into the correct element.
    find.descendant(
      of: find.byKey(const Key('edit-profile-website')),
      matching: find.byType(EditableText),
    );
    find.descendant(
      of: find.byKey(const Key('edit-profile-instagram')),
      matching: find.byType(EditableText),
    );
    find.descendant(
      of: find.byKey(const Key('edit-profile-facebook')),
      matching: find.byType(EditableText),
    );

    await tester.ensureVisible(find.byKey(const Key('edit-profile-website')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('edit-profile-website')));
    await tester.pump();
    tester.testTextInput.enterText('http://example.com');
    await tester.pump();

    await tester.ensureVisible(find.byKey(const Key('edit-profile-instagram')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('edit-profile-instagram')));
    await tester.pump();
    tester.testTextInput.enterText('https://example.com');
    await tester.pump();

    await tester.ensureVisible(find.byKey(const Key('edit-profile-facebook')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('edit-profile-facebook')));
    await tester.pump();
    tester.testTextInput.enterText('https://example.com');
    await tester.pump();

    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();

    expect(find.text('Link must start with https://'), findsOneWidget);
    expect(find.text('Instagram link must contain instagram'), findsOneWidget);
    expect(find.text('Facebook link must contain facebook'), findsOneWidget);
  });

  testWidgets('submits valid profile and shows success', (tester) async {
    late UpdateProfileRequest capturedRequest;
    final api = _FakeAuthApi(
      onFetchProfile: (_, _) async => _sampleProfile(),
      onUpdateProfile: (accessToken, request, tokenType) async {
        capturedRequest = request;
        return UserProfile(
          id: 'u1',
          username: request.username,
          email: request.email,
          hasPassword: true,
          avatarUrl: request.avatarUrl.isEmpty ? null : request.avatarUrl,
          bio: request.bio.isEmpty ? null : request.bio,
          websiteUrl: request.websiteUrl.isEmpty ? null : request.websiteUrl,
          instagramUrl: request.instagramUrl.isEmpty
              ? null
              : request.instagramUrl,
          facebookUrl: request.facebookUrl.isEmpty ? null : request.facebookUrl,
          createdAt: DateTime.utc(2026, 5, 1),
          eventRegistrations: const [],
        );
      },
    );

    final tokens = AuthTokens(
      accessToken: 'access',
      refreshToken: 'refresh',
      tokenType: 'Bearer',
      expiresAt: DateTime.utc(2099),
    );

    final controller = await _createSessionController(api: api, tokens: tokens);

    await tester.pumpWidget(
      AuthScope(
        controller: controller,
        child: buildLocalizedTestApp(home: const EditProfileScreen()),
      ),
    );
    await tester.pumpAndSettle();

    find.descendant(
      of: find.byKey(const Key('edit-profile-website')),
      matching: find.byType(EditableText),
    );
    find.descendant(
      of: find.byKey(const Key('edit-profile-instagram')),
      matching: find.byType(EditableText),
    );
    find.descendant(
      of: find.byKey(const Key('edit-profile-facebook')),
      matching: find.byType(EditableText),
    );

    await tester.ensureVisible(find.byKey(const Key('edit-profile-website')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('edit-profile-website')));
    await tester.pump();
    tester.testTextInput.enterText('https://example.com');
    await tester.pump();

    await tester.ensureVisible(find.byKey(const Key('edit-profile-instagram')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('edit-profile-instagram')));
    await tester.pump();
    tester.testTextInput.enterText('https://instagram.com/tester');
    await tester.pump();

    await tester.ensureVisible(find.byKey(const Key('edit-profile-facebook')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('edit-profile-facebook')));
    await tester.pump();
    tester.testTextInput.enterText('https://facebook.com/tester');
    await tester.pump();

    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();

    // Ensure API received the request
    expect(capturedRequest.websiteUrl, 'https://example.com');
    expect(capturedRequest.instagramUrl, 'https://instagram.com/tester');
    expect(capturedRequest.facebookUrl, 'https://facebook.com/tester');

    // SnackBar success message
    expect(find.text('Profile updated.'), findsOneWidget);
  });

  testWidgets('allows clearing optional profile fields', (tester) async {
    late UpdateProfileRequest capturedRequest;
    final api = _FakeAuthApi(
      onFetchProfile: (_, _) async => _sampleProfileWithLinks(),
      onUpdateProfile: (accessToken, request, tokenType) async {
        capturedRequest = request;
        return UserProfile(
          id: 'u1',
          username: request.username,
          email: request.email,
          hasPassword: true,
          avatarUrl: null,
          bio: request.bio.isEmpty ? null : request.bio,
          websiteUrl: request.websiteUrl.isEmpty ? null : request.websiteUrl,
          instagramUrl: request.instagramUrl.isEmpty
              ? null
              : request.instagramUrl,
          facebookUrl: request.facebookUrl.isEmpty ? null : request.facebookUrl,
          createdAt: DateTime.utc(2026, 5, 1),
          eventRegistrations: const [],
        );
      },
    );

    final tokens = AuthTokens(
      accessToken: 'access',
      refreshToken: 'refresh',
      tokenType: 'Bearer',
      expiresAt: DateTime.utc(2099),
    );

    final controller = await _createSessionController(api: api, tokens: tokens);

    await tester.pumpWidget(
      AuthScope(
        controller: controller,
        child: buildLocalizedTestApp(home: const EditProfileScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Existing bio'), findsOneWidget);
    expect(find.text('https://example.com'), findsWidgets);

    await tester.enterText(find.byType(TextFormField).at(1), '');
    await tester.ensureVisible(find.byKey(const Key('edit-profile-website')));
    await tester.pump();
    await tester.enterText(find.byKey(const Key('edit-profile-website')), '');
    await tester.ensureVisible(
      find.byKey(const Key('edit-profile-instagram')),
    );
    await tester.pump();
    await tester.enterText(find.byKey(const Key('edit-profile-instagram')), '');
    await tester.ensureVisible(find.byKey(const Key('edit-profile-facebook')));
    await tester.pump();
    await tester.enterText(find.byKey(const Key('edit-profile-facebook')), '');

    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();

    expect(capturedRequest.username, 'tester');
    expect(capturedRequest.bio, isEmpty);
    expect(capturedRequest.websiteUrl, isEmpty);
    expect(capturedRequest.instagramUrl, isEmpty);
    expect(capturedRequest.facebookUrl, isEmpty);
  });
}
