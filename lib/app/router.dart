import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/events/event_screen.dart';
import '../features/explore/explore_screen.dart';
import '../features/hub/hub_placeholder_screen.dart';
import '../features/inbox/inbox_screen.dart';
import '../features/profile/edit_profile_screen.dart';
import '../features/profile/event_history_screen.dart';
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
  const HubActionItem(
    id: 'messages',
    icon: 'mail',
    routePath: '/hub/messages',
    isEnabled: false,
  ),
  const HubActionItem(
    id: 'friends',
    icon: 'person_add',
    routePath: '/hub/friends',
    isEnabled: false,
  ),
  const HubActionItem(
    id: 'community',
    icon: 'groups',
    routePath: '/hub/community',
    isEnabled: false,
  ),
];

bool _requiresAuth(String location) {
  return location.startsWith('/hub/messages') ||
      location.startsWith('/hub/friends') ||
      location.startsWith('/hub/create-event') ||
      location.startsWith('/inbox') ||
      location.startsWith('/profile/edit') ||
      location.startsWith('/profile/reviews') ||
      location.startsWith('/profile/history') ||
      location.startsWith('/events/') && location.contains('/review');
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
}) {
  final navigationHistory = NavigationHistoryController();
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/explore',
    refreshListenable: Listenable.merge([sessionController, legalController]),
    redirect: (context, state) {
      final normalizedLocation = normalizeIncomingLocation(state.uri);
      if (normalizedLocation != null && normalizedLocation != state.uri.path) {
        return normalizedLocation;
      }

      if (sessionController.isLoading) {
        return null;
      }

      final location = state.uri.path;
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
          targetLocation: state.uri.path,
        );
      }

      if (isAuthed &&
          location.startsWith('/profile/reviews') &&
          sessionController.profile?.hasOrganizerReviewAccess != true) {
        return '/profile';
      }

      if (!legalController.isLoading) {
        if (isAuthed &&
            legalController.isAcceptanceRequired &&
            location != '/legal/accept') {
          return '/legal/accept?from=${Uri.encodeComponent(location)}';
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
                    path: 'saved',
                    pageBuilder: (context, state) => _trackedNoTransitionPage(
                      controller: navigationHistory,
                      location: state.uri.toString(),
                      rememberAsSafe: _shouldRememberAsSafeLocation(
                        state.uri.path,
                      ),
                      child: const SavedScreen(),
                    ),
                  ),
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
            final child = HubPlaceholderScreen(item: item);
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
