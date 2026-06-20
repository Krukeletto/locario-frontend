import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/chat/chat_screen.dart';
import '../features/events/event_screen.dart';
import '../features/explore/explore_screen.dart';
import '../features/groups/group_details_screen.dart';
import '../features/groups/group_discover_screen.dart';
import '../features/groups/group_form_screen.dart';
import '../features/hub/create_event/create_event_screen.dart';
import '../features/hub/hub_placeholder_screen.dart';
import '../features/inbox/inbox_screen.dart';
import '../features/onboarding/onboarding_controller.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/profile/edit_profile_screen.dart';
import '../features/profile/event_history_screen.dart';
import '../features/profile/organizer_events_screen.dart';
import '../features/profile/organizer_reviews_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/legals/consents_screen.dart';
import '../features/legals/help_screen.dart';
import '../features/legals/legal_acceptance_screen.dart';
import '../features/legals/legal_controller.dart';
import '../features/legals/policy_screen.dart';
import '../features/profile/settings_screen.dart';
import '../features/reviews/event_review_screen.dart';
import '../features/saved/saved_screen.dart';
import '../features/shell/shell.dart';
import '../features/shell/hub/hub_action_item.dart';
import 'navigation_history.dart';
import '../shared/auth/auth_models.dart';
import '../shared/auth/session_controller.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final RegExp _uuidLikePattern = RegExp(
  r'^[0-9a-fA-F]{8}-'
  r'[0-9a-fA-F]{4}-'
  r'[0-9a-fA-F]{4}-'
  r'[0-9a-fA-F]{4}-'
  r'[0-9a-fA-F]{12}$',
);

String? normalizeIncomingLocation(Uri uri) {
  final pathSegments = uri.pathSegments;

  if (uri.scheme == 'locario' &&
      uri.host == 'events' &&
      pathSegments.length == 1) {
    return '/events/${pathSegments.first}';
  }

  if (uri.scheme == 'https' &&
      uri.host == 'locario-events.web.app' &&
      pathSegments.length == 2 &&
      pathSegments.first == 'events') {
    return '/events/${pathSegments.last}';
  }

  if (uri.scheme.isEmpty &&
      uri.host.isEmpty &&
      pathSegments.length == 1 &&
      pathSegments.first == 'messages') {
    return '/hub/messages';
  }

  if (uri.scheme.isEmpty &&
      uri.host.isEmpty &&
      pathSegments.length == 1 &&
      !const {
        'explore',
        'saved',
        'inbox',
        'profile',
      }.contains(pathSegments.first) &&
      _uuidLikePattern.hasMatch(pathSegments.first)) {
    return '/events/${pathSegments.first}';
  }

  return null;
}

final List<HubActionItem> hubActionItems = [
  const HubActionItem(id: 'messages', icon: 'mail', routePath: '/hub/messages'),
  const HubActionItem(id: 'saved', icon: 'bookmark', routePath: '/hub/saved'),
  const HubActionItem(
    id: 'community',
    icon: 'groups',
    routePath: '/hub/community',
  ),
];

bool _requiresAuth(String location) {
  return location.startsWith('/hub/messages') ||
      location.startsWith('/chat/') ||
      location.startsWith('/hub/create-event') ||
      location.startsWith('/hub/community') ||
      location == '/groups/create' ||
      (location.startsWith('/groups/') && location.endsWith('/edit')) ||
      location.startsWith('/inbox') ||
      location.startsWith('/profile/edit') ||
      location.startsWith('/profile/reviews') ||
      location.startsWith('/profile/history') ||
      location.startsWith('/events/') &&
          (location.contains('/review') || location.endsWith('/edit'));
}

bool _shouldRememberAsSafeLocation(String location) {
  return !_requiresAuth(location) &&
      location != '/auth/login' &&
      location != '/auth/register';
}

String _loginRedirect({String? returnLocation, String? targetLocation}) {
  final queryParameters = <String, String>{};

  if (returnLocation != null && returnLocation.isNotEmpty) {
    queryParameters['from'] = returnLocation;
  }

  if (targetLocation != null && targetLocation.isNotEmpty) {
    queryParameters['target'] = targetLocation;
  }

  return Uri(
    path: '/auth/login',
    queryParameters: queryParameters.isEmpty ? null : queryParameters,
  ).toString();
}

Page<void> _trackedNoTransitionPage({
  required NavigationHistoryController controller,
  required String location,
  required bool rememberAsSafe,
  required Widget child,
}) {
  return NoTransitionPage<void>(
    child: RouteHistoryReporter(
      controller: controller,
      location: location,
      rememberAsSafe: rememberAsSafe,
      child: child,
    ),
  );
}

GoRouter createAppRouter({
  required SessionController sessionController,
  required LegalController legalController,
  required OnboardingController onboardingController,
}) {
  final navigationHistory = NavigationHistoryController();
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/explore',
    refreshListenable: Listenable.merge([
      sessionController,
      legalController,
      onboardingController,
    ]),
    redirect: (context, state) {
      final normalizedLocation = normalizeIncomingLocation(state.uri);

      if (sessionController.isLoading || onboardingController.isLoading) {
        return null;
      }

      final location = normalizedLocation ?? state.uri.path;
      if (!onboardingController.isCompleted && location != '/onboarding') {
        return '/onboarding';
      }
      if (onboardingController.isCompleted && location == '/onboarding') {
        return '/explore';
      }

      if (normalizedLocation != null && normalizedLocation != state.uri.path) {
        if (!sessionController.isAuthenticated && _requiresAuth(location)) {
          return _loginRedirect(
            returnLocation: navigationHistory.lastSafeLocation,
            targetLocation: location,
          );
        }
        return normalizedLocation;
      }

      final isAuthed = sessionController.isAuthenticated;

      if (isAuthed &&
          (location == '/auth/login' || location == '/auth/register')) {
        return state.uri.queryParameters['target'] ??
            state.uri.queryParameters['from'] ??
            '/profile';
      }

      if (!isAuthed && _requiresAuth(location)) {
        return _loginRedirect(
          returnLocation: navigationHistory.lastSafeLocation,
          targetLocation: state.uri.toString(),
        );
      }

      if (isAuthed &&
          location.startsWith('/profile/reviews') &&
          sessionController.profile?.hasOrganizerReviewAccess != true) {
        return '/profile';
      }

      if (isAuthed &&
          location == '/groups/create' &&
          sessionController.profile?.organizer != true &&
          sessionController.profile?.admin != true) {
        return '/hub/community';
      }

      if (!legalController.isLoading) {
        if (isAuthed &&
            legalController.isAcceptanceRequired &&
            location != '/legal/accept') {
          return '/legal/accept?from=${Uri.encodeComponent(state.uri.toString())}';
        }
        if (isAuthed &&
            !legalController.isAcceptanceRequired &&
            location == '/legal/accept') {
          return state.uri.queryParameters['from'] ?? '/profile';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/onboarding',
        pageBuilder: (context, state) =>
            const NoTransitionPage<void>(child: OnboardingScreen()),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          final currentSection = state.uri.pathSegments.isNotEmpty
              ? state.uri.pathSegments.first
              : '';
          final isRootSectionScreen = state.uri.pathSegments.length <= 1;
          final showHeader =
              state.uri.queryParameters['header'] != 'false' &&
              isRootSectionScreen;
          final showViewToggle = showHeader && currentSection == 'explore';

          return RouteHistoryReporter(
            controller: navigationHistory,
            location: state.uri.toString(),
            rememberAsSafe: _shouldRememberAsSafeLocation(state.uri.path),
            child: Shell(
              navigationShell: navigationShell,
              hubItems: hubActionItems,
              showHeader: showHeader,
              showViewToggle: showViewToggle,
            ),
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/explore',
                pageBuilder: (context, state) => _trackedNoTransitionPage(
                  controller: navigationHistory,
                  location: state.uri.toString(),
                  rememberAsSafe: _shouldRememberAsSafeLocation(state.uri.path),
                  child: const ExploreScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                pageBuilder: (context, state) => _trackedNoTransitionPage(
                  controller: navigationHistory,
                  location: state.uri.toString(),
                  rememberAsSafe: _shouldRememberAsSafeLocation(state.uri.path),
                  child: const ProfileScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'settings',
                    pageBuilder: (context, state) => _trackedNoTransitionPage(
                      controller: navigationHistory,
                      location: state.uri.toString(),
                      rememberAsSafe: _shouldRememberAsSafeLocation(
                        state.uri.path,
                      ),
                      child: const SettingsScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'edit',
                    pageBuilder: (context, state) => _trackedNoTransitionPage(
                      controller: navigationHistory,
                      location: state.uri.toString(),
                      rememberAsSafe: _shouldRememberAsSafeLocation(
                        state.uri.path,
                      ),
                      child: const EditProfileScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'reviews',
                    pageBuilder: (context, state) => _trackedNoTransitionPage(
                      controller: navigationHistory,
                      location: state.uri.toString(),
                      rememberAsSafe: _shouldRememberAsSafeLocation(
                        state.uri.path,
                      ),
                      child: const OrganizerReviewsScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'my-events',
                    pageBuilder: (context, state) => _trackedNoTransitionPage(
                      controller: navigationHistory,
                      location: state.uri.toString(),
                      rememberAsSafe: _shouldRememberAsSafeLocation(
                        state.uri.path,
                      ),
                      child: const OrganizerEventsScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'history',
                    pageBuilder: (context, state) => _trackedNoTransitionPage(
                      controller: navigationHistory,
                      location: state.uri.toString(),
                      rememberAsSafe: _shouldRememberAsSafeLocation(
                        state.uri.path,
                      ),
                      child: const EventHistoryScreen(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      ...hubActionItems.map(
        (item) => GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: item.routePath,
          pageBuilder: (context, state) {
            final child = switch (item.id) {
              'messages' => const ChatListScreen(),
              'community' => const GroupDiscoverScreen(),
              'saved' => const SavedScreen(),
              _ => HubPlaceholderScreen(item: item),
            };
            return _trackedNoTransitionPage(
              controller: navigationHistory,
              location: state.uri.toString(),
              rememberAsSafe: _shouldRememberAsSafeLocation(state.uri.path),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/hub/create-event',
        pageBuilder: (context, state) => _trackedNoTransitionPage(
          controller: navigationHistory,
          location: state.uri.toString(),
          rememberAsSafe: _shouldRememberAsSafeLocation(state.uri.path),
          child: CreateEventScreen(
            canSubmit: true,
            initialGroupId: state.uri.queryParameters['groupId'],
          ),
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/groups/create',
        pageBuilder: (context, state) => _trackedNoTransitionPage(
          controller: navigationHistory,
          location: state.uri.toString(),
          rememberAsSafe: _shouldRememberAsSafeLocation(state.uri.path),
          child: const GroupFormScreen(),
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/groups/:groupId',
        pageBuilder: (context, state) => _trackedNoTransitionPage(
          controller: navigationHistory,
          location: state.uri.toString(),
          rememberAsSafe: _shouldRememberAsSafeLocation(state.uri.path),
          child: GroupDetailsScreen(
            groupId: state.pathParameters['groupId'] ?? '',
          ),
        ),
        routes: [
          GoRoute(
            path: 'edit',
            pageBuilder: (context, state) => _trackedNoTransitionPage(
              controller: navigationHistory,
              location: state.uri.toString(),
              rememberAsSafe: _shouldRememberAsSafeLocation(state.uri.path),
              child: GroupFormScreen(groupId: state.pathParameters['groupId']),
            ),
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/chat/:chatId',
        pageBuilder: (context, state) => _trackedNoTransitionPage(
          controller: navigationHistory,
          location: state.uri.toString(),
          rememberAsSafe: _shouldRememberAsSafeLocation(state.uri.path),
          child: ChatThreadScreen(
            chatId: state.pathParameters['chatId'] ?? '',
            recipientId: state.uri.queryParameters['recipientId'],
            recipientName: state.uri.queryParameters['recipientName'],
            groupName: state.uri.queryParameters['groupName'],
            isGroup: state.uri.queryParameters['isGroup'] == 'true',
            participantIds:
                state.uri.queryParameters['participantIds']
                    ?.split(',')
                    .where((id) => id.isNotEmpty)
                    .toList() ??
                const [],
          ),
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/inbox',
        pageBuilder: (context, state) => _trackedNoTransitionPage(
          controller: navigationHistory,
          location: state.uri.toString(),
          rememberAsSafe: _shouldRememberAsSafeLocation(state.uri.path),
          child: const InboxScreen(),
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/events/:eventId',
        pageBuilder: (context, state) => _trackedNoTransitionPage(
          controller: navigationHistory,
          location: state.uri.toString(),
          rememberAsSafe: _shouldRememberAsSafeLocation(state.uri.path),
          child: EventScreen(eventId: state.pathParameters['eventId']),
        ),
        routes: [
          GoRoute(
            path: 'edit',
            pageBuilder: (context, state) => _trackedNoTransitionPage(
              controller: navigationHistory,
              location: state.uri.toString(),
              rememberAsSafe: _shouldRememberAsSafeLocation(state.uri.path),
              child: CreateEventScreen(
                editingEventId: state.pathParameters['eventId'],
                canSubmit: true,
              ),
            ),
          ),
          GoRoute(
            path: 'review',
            pageBuilder: (context, state) => _trackedNoTransitionPage(
              controller: navigationHistory,
              location: state.uri.toString(),
              rememberAsSafe: _shouldRememberAsSafeLocation(state.uri.path),
              child: EventReviewScreen(
                eventId: state.pathParameters['eventId'] ?? '',
              ),
            ),
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/auth/login',
        pageBuilder: (context, state) => _trackedNoTransitionPage(
          controller: navigationHistory,
          location: state.uri.toString(),
          rememberAsSafe: _shouldRememberAsSafeLocation(state.uri.path),
          child: LoginScreen(
            returnLocation: state.uri.queryParameters['from'],
            targetLocation: state.uri.queryParameters['target'],
          ),
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/auth/register',
        pageBuilder: (context, state) => _trackedNoTransitionPage(
          controller: navigationHistory,
          location: state.uri.toString(),
          rememberAsSafe: _shouldRememberAsSafeLocation(state.uri.path),
          child: RegisterScreen(
            returnLocation: state.uri.queryParameters['from'],
            targetLocation: state.uri.queryParameters['target'],
          ),
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/legal/terms',
        pageBuilder: (context, state) => _trackedNoTransitionPage(
          controller: navigationHistory,
          location: state.uri.toString(),
          rememberAsSafe: _shouldRememberAsSafeLocation(state.uri.path),
          child: const PolicyScreen(type: PolicyType.terms),
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/legal/privacy',
        pageBuilder: (context, state) => _trackedNoTransitionPage(
          controller: navigationHistory,
          location: state.uri.toString(),
          rememberAsSafe: _shouldRememberAsSafeLocation(state.uri.path),
          child: const PolicyScreen(type: PolicyType.privacy),
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/legal/help',
        pageBuilder: (context, state) => _trackedNoTransitionPage(
          controller: navigationHistory,
          location: state.uri.toString(),
          rememberAsSafe: _shouldRememberAsSafeLocation(state.uri.path),
          child: const HelpScreen(),
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/legal/consents',
        pageBuilder: (context, state) => _trackedNoTransitionPage(
          controller: navigationHistory,
          location: state.uri.toString(),
          rememberAsSafe: _shouldRememberAsSafeLocation(state.uri.path),
          child: const ConsentsScreen(),
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/legal/accept',
        pageBuilder: (context, state) => _trackedNoTransitionPage(
          controller: navigationHistory,
          location: state.uri.toString(),
          rememberAsSafe: _shouldRememberAsSafeLocation(state.uri.path),
          child: const LegalAcceptanceScreen(),
        ),
      ),
    ],
  );
}
