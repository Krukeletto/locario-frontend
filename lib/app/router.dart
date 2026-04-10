import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../features/explore/explore_screen.dart';
import '../features/hub/hub_placeholder_screen.dart';
import '../features/inbox/inbox_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/saved/saved_screen.dart';
import '../features/shell/app_shell.dart';
import '../features/shell/hub/hub_action_item.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final List<HubActionItem> hubActionItems = [
  const HubActionItem(
    id: 'create-event',
    title: 'Create event',
    subtitle: 'Start something new',
    icon: 'add_box',
    routePath: '/hub/create-event',
    isPrimary: true,
  ),
  const HubActionItem(
    id: 'community',
    title: 'Community',
    subtitle: 'Local updates',
    icon: 'groups',
    routePath: '/hub/community',
  ),
  const HubActionItem(
    id: 'friends',
    title: 'Friends',
    subtitle: 'Your network',
    icon: 'person_add',
    routePath: '/hub/friends',
  ),
];

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/explore',
  routes: [
    // Indexed stack keeps tab navigator state alive between tab switches.
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        final showHeader = state.uri.queryParameters['header'] != 'false';
        final showViewToggle =
            showHeader &&
            state.uri.pathSegments.isNotEmpty &&
            state.uri.pathSegments.first == 'explore';

        return AppShell(
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
        builder: (context, state) => HubPlaceholderScreen(item: item),
      ),
    ),
  ],
);
