import 'package:flutter/material.dart';

import '../../explore/explore_ui_models.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    required this.selectedView,
    required this.onViewChanged,
  });

  final ExploreContentView selectedView;
  final ValueChanged<ExploreContentView> onViewChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 14),
              child: Text(
                'Locario',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          _ViewToggle(selectedView: selectedView, onChanged: onViewChanged),
        ],
      ),
    );
  }
}

class _ViewToggle extends StatelessWidget {
  const _ViewToggle({required this.selectedView, required this.onChanged});

  final ExploreContentView selectedView;
  final ValueChanged<ExploreContentView> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isMapSelected = selectedView == ExploreContentView.map;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: SizedBox(
        width: 196,
        height: 48,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Stack(
            children: [
              AnimatedAlign(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                alignment: isMapSelected
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: Container(
                  width: 92,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.24),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ViewToggleButton(
                    icon: Icons.map_outlined,
                    label: 'Mapa',
                    selected: isMapSelected,
                    colorScheme: colorScheme,
                    onTap: () => onChanged(ExploreContentView.map),
                  ),
                  _ViewToggleButton(
                    icon: Icons.view_list_rounded,
                    label: 'Lista',
                    selected: !isMapSelected,
                    colorScheme: colorScheme,
                    onTap: () => onChanged(ExploreContentView.list),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ViewToggleButton extends StatelessWidget {
  const _ViewToggleButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.colorScheme,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: 94,
        height: 40,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
              child: Icon(
                icon,
                key: ValueKey('$label-$selected'),
                size: 17,
                color: selected ? colorScheme.onPrimary : colorScheme.secondary,
              ),
            ),
            const SizedBox(width: 6),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                color: selected ? colorScheme.onPrimary : colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
