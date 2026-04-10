import 'package:flutter/material.dart';
import 'package:locario/l10n/app_localizations.dart';

import 'app_tab.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.activeTab,
    required this.hubOpen,
    required this.onTabSelected,
    required this.onHubToggle,
  });

  final AppTab activeTab;
  final bool hubOpen;
  final ValueChanged<AppTab> onTabSelected;
  final VoidCallback onHubToggle;

  // Navigation bar with 4 items: Explore, Inbox, Hub and Profile.
  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    final scheme = Theme.of(context).colorScheme;
    const contentHeight = 72.0;

    return Container(
      height: contentHeight + safeBottom,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.98),
        border: Border(
          top: BorderSide(color: scheme.outline.withValues(alpha: 0.35)),
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          10,
          2,
          10,
          safeBottom > 0 ? safeBottom : 2,
        ),
        child: SizedBox(
          height: contentHeight,
          child: Row(
            children: [
              Expanded(
                child: _NavItem(
                  tab: AppTab.explore,
                  activeTab: activeTab,
                  hubOpen: hubOpen,
                  onTap: onTabSelected,
                ),
              ),
              Expanded(
                child: _NavItem(
                  tab: AppTab.inbox,
                  activeTab: activeTab,
                  hubOpen: hubOpen,
                  onTap: onTabSelected,
                ),
              ),
              Expanded(
                child: _HubNavItem(open: hubOpen, onTap: onHubToggle),
              ),
              Expanded(
                child: _NavItem(
                  tab: AppTab.profile,
                  activeTab: activeTab,
                  hubOpen: hubOpen,
                  onTap: onTabSelected,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Single nav item widget, with icon and label, and active state styling.
class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.tab,
    required this.activeTab,
    required this.hubOpen,
    required this.onTap,
  });

  final AppTab tab;
  final AppTab activeTab;
  final bool hubOpen;
  final ValueChanged<AppTab> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final isActive = activeTab == tab && !hubOpen;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => onTap(tab),
      // Animated active state bubble behind each tab item.
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? scheme.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? tab.selectedIcon : tab.icon,
              color: isActive ? scheme.primary : scheme.secondary,
              size: 24,
            ),
            const SizedBox(height: 5),
            Text(
              tab.label(l10n),
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 12,
                height: 1,
                color: isActive ? scheme.primary : scheme.secondary,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HubNavItem extends StatelessWidget {
  const _HubNavItem({required this.open, required this.onTap});

  final bool open;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: open
              ? scheme.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.grid_view_rounded,
              color: open ? scheme.primary : scheme.secondary,
              size: 24,
            ),
            const SizedBox(height: 5),
            Text(
              l10n.tabHub,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 12,
                height: 1,
                color: open ? scheme.primary : scheme.secondary,
                fontWeight: open ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
