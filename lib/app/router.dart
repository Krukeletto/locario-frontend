import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/login_screen.dart';
import '../features/events/event_screen.dart';
import '../features/hub/create_event/create_event_screen.dart';
import '../features/explore/explore_screen.dart';
import '../features/hub/hub_placeholder_screen.dart';
import '../features/inbox/inbox_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/profile/settings_screen.dart';
import '../features/saved/saved_screen.dart';
import '../features/shell/shell.dart';
import '../features/shell/hub/hub_action_item.dart';
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

  // Accept the shared custom scheme `locario://events/<id>` (legacy)
  if (uri.scheme == 'locario' &&
      uri.host == 'events' &&
      pathSegments.length == 1) {
    return '/events/${pathSegments.first}';
  }

  // Accept the new HTTPS deep link `https://locario-events.web.app/events/<id>`
  if (uri.scheme == 'https' &&
      uri.host == 'locario-events.web.app' &&
      pathSegments.length == 2 &&
      pathSegments.first == 'events') {
    return '/events/${pathSegments.last}';
  }

  // Some platforms can surface the deep link to Flutter as only the path
  // portion. Support a single UUID-like segment and normalize it to the event
  // details route while leaving known top-level sections untouched.
  if (uri.scheme.isEmpty &&
      uri.host.isEmpty &&
      pathSegments.length == 1 &&
      !const {'explore', 'inbox', 'profile'}.contains(pathSegments.first) &&
      _uuidLikePattern.hasMatch(pathSegments.first)) {
    return '/events/${pathSegments.first}';
  }

  return null;
}

final List<HubActionItem> hubActionItems = [
  const HubActionItem(
    id: 'create-event',
    icon: 'add_box',
    routePath: '/hub/create-event',
    isPrimary: true,
  ),
  const HubActionItem(
    id: 'community',
    icon: 'groups',
    routePath: '/hub/community',
  ),
  const HubActionItem(
    id: 'friends',
    icon: 'person_add',
    routePath: '/hub/friends',
  ),
];

bool _requiresAuth(String location) {
  return location.startsWith('/hub/create-event') ||
      location.startsWith('/hub/friends') ||
      location.startsWith('/inbox') ||
      location.startsWith('/profile/saved');
}

String _loginRedirect(Uri uri) {
  final from = Uri.encodeComponent(uri.toString());
  return '/auth/login?from=$from';
}

GoRouter createAppRouter(SessionController sessionController) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/explore',
    refreshListenable: sessionController,
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

      if (!isAuthed && _requiresAuth(location)) {
        return _loginRedirect(state.uri);
      }

      return null;
    },
    routes: [
      // Indexed stack keeps tab navigator state alive between tab switches.
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

          return Shell(
            navigationShell: navigationShell,
            hubItems: hubActionItems,
            showHeader: showHeader,
            showViewToggle: showViewToggle,
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/explore',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: ExploreScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/inbox',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: InboxScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: ProfileScreen()),
                routes: [
                  GoRoute(
                    path: 'saved',
                    pageBuilder: (context, state) =>
                        const NoTransitionPage(child: SavedScreen()),
                  ),
                  GoRoute(
                    path: 'settings',
                    pageBuilder: (context, state) =>
                        const NoTransitionPage(child: SettingsScreen()),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      // Hub actions open above the shell on the root navigator.
      ...hubActionItems.map(
        (item) => GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: item.routePath,
          pageBuilder: (context, state) {
            if (item.id == 'create-event') {
              return const NoTransitionPage(child: CreateEventScreen());
            }
            return NoTransitionPage(child: HubPlaceholderScreen(item: item));
          },
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/events/:eventId',
        pageBuilder: (context, state) => NoTransitionPage(
          child: EventScreen(eventId: state.pathParameters['eventId']),
        ),
      ),
      GoRoute(
        // do testów
        parentNavigatorKey: _rootNavigatorKey,
        path: '/auth/login',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: LoginScreen()),
      ),
    ],
  );
}
