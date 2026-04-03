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
          // Five equal slots: 4 tabs + center action button.
          child: Row(
            children: [
              Expanded(
                child: _NavItem(
                  tab: AppTab.explore,
                  activeTab: activeTab,
                  onTap: onTabSelected,
                ),
              ),
              Expanded(
                child: _NavItem(
                  tab: AppTab.saved,
                  activeTab: activeTab,
                  onTap: onTabSelected,
                ),
              ),
              Expanded(
                child: Center(
                  child: Transform.translate(
                    offset: const Offset(0, -14),
                    child: _MoreButton(open: moreOpen, onTap: onMoreToggle),
                  ),
                ),
              ),
              Expanded(
                child: _NavItem(
                  tab: AppTab.inbox,
                  activeTab: activeTab,
                  onTap: onTabSelected,
                ),
              ),
              Expanded(
                child: _NavItem(
                  tab: AppTab.profile,
                  activeTab: activeTab,
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
    required this.onTap,
  });

  final AppTab tab;
  final AppTab activeTab;
  final ValueChanged<AppTab> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isActive = activeTab == tab;

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

// "More" button in the center of the nav bar, which toggles the "more" layer when tapped.
class _MoreButton extends StatelessWidget {
  const _MoreButton({required this.open, required this.onTap});

  final bool open;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      // Center "More" action with icon morph (add <-> close).
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        width: 58,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Floating circular core of the center action.
            AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: scheme.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: open ? 0.22 : 0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                open ? Icons.close_rounded : Icons.add_rounded,
                color: Colors.white,
                size: 19,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'More',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 11,
                height: 1,
                color: scheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
