import 'package:flutter/material.dart';

enum AppTab {
  explore(
    label: 'Explore',
    icon: Icons.explore_outlined,
    selectedIcon: Icons.explore,
    routePath: '/explore',
  ),
  saved(
    label: 'Saved',
    icon: Icons.bookmark_border_rounded,
    selectedIcon: Icons.bookmark_rounded,
    routePath: '/saved',
  ),
  inbox(
    label: 'Inbox',
    icon: Icons.notifications_none_rounded,
    selectedIcon: Icons.notifications_rounded,
    routePath: '/inbox',
  ),
  profile(
    label: 'Profile',
    icon: Icons.person_outline_rounded,
    selectedIcon: Icons.person_rounded,
    routePath: '/profile',
  );

  const AppTab({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.routePath,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String routePath;

  static AppTab fromLocation(String location) {
    return AppTab.values.firstWhere(
      (tab) => location.startsWith(tab.routePath),
      orElse: () => AppTab.explore,
    );
  }
}
