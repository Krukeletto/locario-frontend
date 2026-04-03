import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../features/explore/explore_screen.dart';
import '../features/inbox/inbox_screen.dart';
import '../features/more/more_placeholder_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/saved/saved_screen.dart';
import '../features/shell/app_shell.dart';
import '../features/shell/more_action_item.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>();

final List<MoreActionItem> moreActionItems = [
  const MoreActionItem(
    id: 'create-event',
    title: 'Dodaj wydarzenie',
    subtitle: 'Stworz cos nowego',
    icon: 'add_box',
    routePath: '/more/create-event',
    isPrimary: true,
  ),
  const MoreActionItem(
    id: 'community',
    title: 'Spolecznosc',
    subtitle: 'Lokalne wiadomosci',
    icon: 'groups',
    routePath: '/more/community',
  ),
  const MoreActionItem(
    id: 'friends',
    title: 'Znajomi',
    subtitle: 'Twoja siec',
    icon: 'person_add',
    routePath: '/more/friends',
  ),
  const MoreActionItem(
    id: 'groups',
    title: 'Grupy',
    subtitle: 'Zainteresowania',
    icon: 'group_work',
    routePath: '/more/groups',
  ),
  const MoreActionItem(
    id: 'premium',
    title: 'Premium',
    subtitle: 'Wyjatkowe',
    icon: 'auto_awesome',
    routePath: '/more/premium',
    accentColor: 0xFFB14B6F,
  ),
];

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/explore',
  routes: [
    // Shell keeps bottom navigation persistent across main tabs.
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return AppShell(
          location: state.uri.path,
          moreItems: moreActionItems,
          child: child,
        );
      },
      routes: [
        GoRoute(
          path: '/explore',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: ExploreScreen()),
        ),
        GoRoute(
          path: '/saved',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: SavedScreen()),
        ),
        GoRoute(
          path: '/inbox',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: InboxScreen()),
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: ProfileScreen()),
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
