import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:locario/features/explore/models.dart';
import 'package:locario/features/hub/create_event/create_event_controller.dart';
import 'package:locario/l10n/app_localizations_en.dart';
import 'package:locario/shared/auth/auth_api.dart';
import 'package:locario/shared/auth/auth_models.dart';
import 'package:locario/shared/auth/auth_repository.dart';
import 'package:locario/shared/auth/session_controller.dart';
import 'package:locario/shared/groups/group_models.dart';
import 'package:locario/shared/services/l10n_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../test_helpers/fake_event_repository.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    L10nService.init(AppLocalizationsEn());
  });

  test('submit uses updateEvent in edit mode', () async {
    final repository = FakeEventRepository();
    final controller = CreateEventController(
      eventRepository: repository,
      sessionController: _AuthenticatedSessionController(),
      canCreatePublicEvents: true,
    );

    controller.setEditingEventId('event-1');
    controller.initializeFromEvent(
      event: ExploreEvent(
        id: 'event-1',
        title: 'Updated title',
        startsAt: DateTime.utc(2026, 6, 12, 19),
        venue: 'Venue',
        location: const LatLng(51.7592, 19.4550),
        description: 'Updated description',
        address: 'Venue',
        categories: const [Category(id: 'music', name: 'Music', slug: 'music')],
        ticketUrl: 'https://example.com/tickets',
        slotLimit: 120,
      ),
      selectedGroups: const [
        Group(
          id: 'group-1',
          name: 'Group 1',
          currentUserMembership: GroupMembershipStatus.active,
        ),
      ],
    );

    await controller.submit();

    expect(repository.lastUpdateEventId, 'event-1');
    expect(repository.lastCreateInput, isNull);
    expect(repository.lastUpdateInput?.name, 'Updated title');
    expect(repository.lastUpdateInput?.description, 'Updated description');
    expect(repository.lastUpdateInput?.groupIds, ['group-1']);
    expect(
      repository.lastUpdateInput?.ticketUrl,
      'https://example.com/tickets',
    );
    expect(repository.lastUpdateInput?.slotLimit, 120);
  });
}

class _AuthenticatedSessionController extends SessionController {
  _AuthenticatedSessionController()
    : super(
        authRepository: AuthRepository(
          api: AuthApi(),
          storage: _NoopTokenStorage(),
        ),
      );

  final AuthTokens _tokens = AuthTokens(
    accessToken: 'access-token',
    refreshToken: 'refresh-token',
    tokenType: 'Bearer',
    expiresAt: DateTime.utc(2030, 1, 1),
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
    eventRegistrations: const [],
  );

  @override
  bool get isAuthenticated => true;

  @override
  AuthTokens? get tokens => _tokens;

  @override
  UserProfile? get profile => _profile;
}

class _NoopTokenStorage implements AuthTokenStorage {
  @override
  Future<void> clear() async {}

  @override
  Future<AuthTokens?> readTokens() async => null;

  @override
  Future<void> saveTokens(AuthTokens tokens) async {}
}
