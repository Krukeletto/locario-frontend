import 'package:flutter/material.dart';
import 'package:locario/l10n/app_localizations.dart';

import '../../explore/models.dart';

class ShellHeader extends StatelessWidget {
  static const _headerContentHeight = 48.0;
  static const _viewToggleWidth = 196.0;
  static const _viewToggleGap = 12.0;

  const ShellHeader({
    super.key,
    required this.selectedView,
    required this.onViewChanged,
    this.showViewToggle = true,
  });

  final ExploreContentView selectedView;
  final ValueChanged<ExploreContentView> onViewChanged;
  final bool showViewToggle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: Theme.of(context).brightness == Brightness.dark
                  ? 0.18
                  : 0.04,
            ),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SizedBox(
        height: _headerContentHeight,
        child: Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 14,
                  right: showViewToggle ? _viewToggleWidth + _viewToggleGap : 0,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Locario',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.8,
                    ),
                  ),
                ),
              ),
            ),
            if (showViewToggle)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: _viewToggleGap),
                    _ViewToggle(
                      mapLabel: l10n.headerMap,
                      listLabel: l10n.headerList,
                      selectedView: selectedView,
                      onChanged: onViewChanged,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ViewToggle extends StatelessWidget {
  const _ViewToggle({
    required this.selectedView,
    required this.onChanged,
    required this.mapLabel,
    required this.listLabel,
  });

  final ExploreContentView selectedView;
  final ValueChanged<ExploreContentView> onChanged;
  final String mapLabel;
  final String listLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isMapSelected = selectedView == ExploreContentView.map;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow.withValues(
          alpha: Theme.of(context).brightness == Brightness.dark ? 0.96 : 0.92,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: Theme.of(context).brightness == Brightness.dark
                  ? 0.2
                  : 0.05,
            ),
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
                    label: mapLabel,
                    selected: isMapSelected,
                    colorScheme: colorScheme,
                    onTap: () => onChanged(ExploreContentView.map),
                  ),
                  _ViewToggleButton(
                    icon: Icons.view_list_rounded,
                    label: listLabel,
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
