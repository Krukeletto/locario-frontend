import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:locario/features/explore/models.dart';
import 'package:locario/features/profile/event_history_screen.dart';
import 'package:locario/shared/auth/auth_api.dart';
import 'package:locario/shared/auth/auth_models.dart';
import 'package:locario/shared/auth/auth_repository.dart';
import 'package:locario/shared/auth/auth_scope.dart';
import 'package:locario/shared/auth/session_controller.dart';

import '../../test_helpers/fake_event_repository.dart';
import '../../test_helpers/test_app.dart';

void main() {
  testWidgets('does not show add-to-calendar action in the archive', (
    tester,
  ) async {
    final authController = _AuthenticatedSessionController();
    final event = _event();

    await tester.pumpWidget(
      buildLocalizedTestApp(
        home: AuthScope(
          controller: authController,
          child: EventHistoryScreen(
            eventRepository: FakeEventRepository(eventDetails: event),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Event archive'), findsOneWidget);
    expect(find.text('Add to calendar'), findsNothing);
  });
}

class _AuthenticatedSessionController extends SessionController {
  _AuthenticatedSessionController()
    : super(
        authRepository: AuthRepository(
          api: AuthApi(client: http.Client(), baseUrl: 'http://localhost'),
          storage: _NoopAuthTokenStorage(),
        ),
      );

  final UserProfile _profile = UserProfile(
    id: 'user-1',
    username: 'tester',
    email: 'tester@example.com',
    hasPassword: true,
    avatarUrl: null,
    bio: null,
    websiteUrl: null,
    instagramUrl: null,
    facebookUrl: null,
    createdAt: DateTime.utc(2026, 1, 1),
    eventRegistrations: [
      ProfileEventSummary(
        eventId: '11111111-1111-1111-1111-111111111111',
        name: 'Jazz Evening',
        startAt: DateTime.utc(2026, 6, 12, 19),
      ),
    ],
  );

  final AuthTokens _tokens = AuthTokens(
    accessToken: 'access-token',
    refreshToken: 'refresh-token',
    tokenType: 'Bearer',
    expiresAt: DateTime.utc(2030, 1, 1),
  );

  @override
  bool get isAuthenticated => true;

  @override
  bool get isLoading => false;

  @override
  SessionStatus get status => SessionStatus.authenticated;

  @override
  AuthTokens? get tokens => _tokens;

  @override
  UserProfile? get profile => _profile;

  @override
  Future<void> refreshProfile() async {}
}

class _NoopAuthTokenStorage implements AuthTokenStorage {
  @override
  Future<void> clear() async {}

  @override
  Future<AuthTokens?> readTokens() async => null;

  @override
  Future<void> saveTokens(AuthTokens tokens) async {}
}

ExploreEvent _event() {
  return ExploreEvent(
    id: '11111111-1111-1111-1111-111111111111',
    title: 'Jazz Evening',
    startsAt: DateTime.utc(2026, 6, 12, 19),
    endsAt: DateTime.utc(2026, 6, 12, 21, 30),
    venue: 'Piotrkowska 10, Lodz',
    location: const LatLng(51.7592, 19.4550),
    description: 'Live music and open-air atmosphere.',
    address: 'Piotrkowska 10, Lodz',
  );
}
