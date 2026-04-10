import 'package:flutter/material.dart';

import 'app_tab.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.activeTab,
    required this.moreOpen,
    required this.onTabSelected,
    required this.onMoreToggle,
  });

  final AppTab activeTab;
  final bool moreOpen;
  final ValueChanged<AppTab> onTabSelected;
  final VoidCallback onMoreToggle;

  // Navigation bar with 5 items: Explore, Saved, More (center), Inbox, Profile.
  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    final scheme = Theme.of(context).colorScheme;
    const contentHeight = 64.0;

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
          // Five equal slots: 4 tabs + More action button as last item.
          child: Row(
            children: [
              Expanded(
                child: _NavItem(
                  tab: AppTab.explore,
                  activeTab: activeTab,
                  moreOpen: moreOpen,
                  onTap: onTabSelected,
                ),
              ),
              Expanded(
                child: _NavItem(
                  tab: AppTab.saved,
                  activeTab: activeTab,
                  moreOpen: moreOpen,
                  onTap: onTabSelected,
                ),
              ),
              Expanded(
                child: _NavItem(
                  tab: AppTab.inbox,
                  activeTab: activeTab,
                  moreOpen: moreOpen,
                  onTap: onTabSelected,
                ),
              ),
              Expanded(
                child: _NavItem(
                  tab: AppTab.profile,
                  activeTab: activeTab,
                  moreOpen: moreOpen,
                  onTap: onTabSelected,
                ),
              ),
              Expanded(
                child: _MoreNavItem(open: moreOpen, onTap: onMoreToggle),
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
    required this.moreOpen,
    required this.onTap,
  });

  final AppTab tab;
  final AppTab activeTab;
  final bool moreOpen;
  final ValueChanged<AppTab> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isActive = activeTab == tab && !moreOpen;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => onTap(tab),
      // Animated active state bubble behind each tab item.
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
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
              size: 21,
            ),
            const SizedBox(height: 3),
            Text(
              tab.label,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 11,
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

// "More" button at the end of the nav bar, which toggles the "more" layer when tapped.
class _MoreNavItem extends StatelessWidget {
  const _MoreNavItem({required this.open, required this.onTap});

  final bool open;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
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
              Icons.more_horiz,
              color: open ? scheme.primary : scheme.secondary,
              size: 21,
            ),
            const SizedBox(height: 3),
            Text(
              'More',
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 11,
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
