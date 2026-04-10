import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../features/explore/explore_screen.dart';
import '../features/inbox/inbox_screen.dart';
import '../features/more/more_placeholder_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/saved/saved_screen.dart';
import '../features/shell/app_shell.dart';
import '../features/shell/more/more_action_item.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final List<MoreActionItem> moreActionItems = [
  const MoreActionItem(
    id: 'create-event',
    title: 'Create event',
    subtitle: 'Start something new',
    icon: 'add_box',
    routePath: '/more/create-event',
    isPrimary: true,
  ),
  const MoreActionItem(
    id: 'community',
    title: 'Community',
    subtitle: 'Local updates',
    icon: 'groups',
    routePath: '/more/community',
  ),
  const MoreActionItem(
    id: 'friends',
    title: 'Friends',
    subtitle: 'Your network',
    icon: 'person_add',
    routePath: '/more/friends',
  ),
  const MoreActionItem(
    id: 'groups',
    title: 'Groups',
    subtitle: 'Shared interests',
    icon: 'group_work',
    routePath: '/more/groups',
  ),
  const MoreActionItem(
    id: 'premium',
    title: 'Premium',
    subtitle: 'Extra features',
    icon: 'auto_awesome',
    routePath: '/more/premium',
    accentColor: 0xFFB14B6F,
  ),
];

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/explore',
  routes: [
    // Indexed stack keeps tab navigator state alive between tab switches.
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppShell(
          navigationShell: navigationShell,
          moreItems: moreActionItems,
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
              path: '/saved',
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: SavedScreen()),
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
            ),
          ],
        ),
      ],
    ),
    // More actions open above the shell on the root navigator.
    ...moreActionItems.map(
      (item) => GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: item.routePath,
        builder: (context, state) => MorePlaceholderScreen(item: item),
      ),
    ),
  ],
);
