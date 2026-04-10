import 'package:flutter/material.dart';
import 'package:locario/l10n/app_localizations.dart';

enum AppTab {
  explore(
    icon: Icons.explore_outlined,
    selectedIcon: Icons.explore,
    routePath: '/explore',
  ),
  inbox(
    icon: Icons.notifications_none_rounded,
    selectedIcon: Icons.notifications_rounded,
    routePath: '/inbox',
  ),
  profile(
    icon: Icons.person_outline_rounded,
    selectedIcon: Icons.person_rounded,
    routePath: '/profile',
  );

  const AppTab({
    required this.icon,
    required this.selectedIcon,
    required this.routePath,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String routePath;

  String label(AppLocalizations l10n) {
    return switch (this) {
      AppTab.explore => l10n.tabExplore,
      AppTab.inbox => l10n.tabInbox,
      AppTab.profile => l10n.tabProfile,
    };
  }

  static AppTab fromLocation(String location) {
    return AppTab.values.firstWhere(
      (tab) => location.startsWith(tab.routePath),
      orElse: () => AppTab.explore,
    );
  }
}
