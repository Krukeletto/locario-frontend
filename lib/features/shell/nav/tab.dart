import 'package:flutter/material.dart';
import 'package:locario/l10n/app_localizations.dart';

enum ShellTab {
  explore(
    icon: Icons.explore_outlined,
    selectedIcon: Icons.explore,
    routePath: '/explore',
  ),
  saved(
    icon: Icons.bookmark_outline_rounded,
    selectedIcon: Icons.bookmark_rounded,
    routePath: '/saved',
  ),
  profile(
    icon: Icons.person_outline_rounded,
    selectedIcon: Icons.person_rounded,
    routePath: '/profile',
  );

  const ShellTab({
    required this.icon,
    required this.selectedIcon,
    required this.routePath,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String routePath;

  String label(AppLocalizations l10n) {
    return switch (this) {
      ShellTab.explore => l10n.tabExplore,
      ShellTab.saved => l10n.savedTitle,
      ShellTab.profile => l10n.tabProfile,
    };
  }

  static ShellTab fromLocation(String location) {
    return ShellTab.values.firstWhere(
      (tab) => location.startsWith(tab.routePath),
      orElse: () => ShellTab.explore,
    );
  }
}
