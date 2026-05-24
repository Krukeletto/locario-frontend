import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:locario/features/explore/models.dart';
import 'package:locario/features/profile/organizer_events_screen.dart';
import 'package:locario/shared/auth/auth_api.dart';
import 'package:locario/shared/auth/auth_models.dart';
import 'package:locario/shared/auth/auth_repository.dart';
import 'package:locario/shared/auth/auth_scope.dart';
import 'package:locario/shared/auth/session_controller.dart';

import '../../test_helpers/fake_event_repository.dart';
import '../../test_helpers/test_app.dart';

void main() {
  group('OrganizerEventsScreen', () {
    testWidgets('shows only current organizer events', (tester) async {
      final now = DateTime.now();
      final pastEvent = _buildEvent(
        id: 'past-1',
        title: 'Past event',
        startsAt: now.subtract(const Duration(days: 1)),
        endsAt: now.subtract(const Duration(hours: 6)),
      );
      final futureEvent = _buildEvent(
        id: 'future-1',
        title: 'Future event',
        startsAt: now.add(const Duration(days: 1)),
        endsAt: now.add(const Duration(days: 1, hours: 2)),
      );
      final repository = FakeEventRepository(
        organizerEvents: [pastEvent, futureEvent],
      );
      final sessionController = await _createSessionController(
        authenticated: true,
        organizer: true,
      );

      await tester.pumpWidget(
        buildLocalizedTestApp(
          home: AuthScope(
            controller: sessionController,
            child: OrganizerEventsScreen(eventRepository: repository),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Future event'), findsOneWidget);
      expect(find.text('Past event'), findsNothing);
    });

    testWidgets('does not load events for non-organizers', (tester) async {
      final repository = FakeEventRepository();
      final sessionController = await _createSessionController(
        authenticated: true,
        organizer: false,
      );

      await tester.pumpWidget(
        buildLocalizedTestApp(
          home: AuthScope(
            controller: sessionController,
            child: OrganizerEventsScreen(eventRepository: repository),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(repository.lastOrganizerAccessToken, isNull);
      expect(find.text(repository.eventDetails.title), findsNothing);
    });
  });
}

ExploreEvent _buildEvent({
  required String id,
  required String title,
  required DateTime startsAt,
  required DateTime endsAt,
}) {
  return ExploreEvent(
    id: id,
    title: title,
    categories: const [Category(id: 'music', name: 'Music', slug: 'music')],
    startsAt: startsAt,
    endsAt: endsAt,
    trendingScore: 1,
    venue: 'Main Hall',
    location: const LatLng(51.7592, 19.4550),
    description: 'Description',
    address: 'Piotrkowska 10, Lodz',
  );
}

class _MemoryAuthStorage implements AuthTokenStorage {
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
  Future<AuthResponse> login(LoginRequest request) {
    throw StateError('login not configured');
  }

  @override
  Future<UserProfile> fetchProfile({
    required String accessToken,
    String tokenType = 'Bearer',
  }) {
    return Future.value(profile);
  }

  @override
  Future<AuthResponse> register(RegisterRequest request) {
    throw StateError('register not configured');
  }

  @override
  Future<AuthResponse> refresh(String refreshToken) {
    throw StateError('refresh not configured');
  }

  @override
  Future<AuthResponse> loginWithGoogle(String idToken) {
    throw StateError('loginWithGoogle not configured');
  }

  @override
  Future<void> logout({
    required String accessToken,
    String tokenType = 'Bearer',
  }) {
    throw StateError('logout not configured');
  }
}

Future<SessionController> _createSessionController({
  required bool authenticated,
  required bool organizer,
}) async {
  final storage = _MemoryAuthStorage();
  if (authenticated) {
    storage.stored = AuthTokens(
      accessToken: 'access-token',
      refreshToken: 'refresh-token',
      tokenType: 'Bearer',
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
    );
  }

  final controller = SessionController(
    authRepository: AuthRepository(
      api: _FakeAuthApi(
        profile: UserProfile(
          id: 'user-id',
          username: 'user',
          email: 'user@example.com',
          hasPassword: true,
          avatarUrl: null,
          bio: null,
          websiteUrl: null,
          instagramUrl: null,
          facebookUrl: null,
          createdAt: DateTime.utc(2026, 5, 1),
          eventRegistrations: const [],
          organizer: organizer,
        ),
      ),
      storage: storage,
    ),
  );

  await controller.load();
  return controller;
}
