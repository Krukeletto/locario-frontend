import 'package:flutter/material.dart';
import 'package:locario/l10n/app_localizations.dart';

import '../../../shared/services/feedback_service.dart';
import 'hub_action_item.dart';

class HubPanel extends StatelessWidget {
  const HubPanel({
    super.key,
    required this.items,
    required this.onItemSelected,
  });

  final List<HubActionItem> items;
  final ValueChanged<HubActionItem> onItemSelected;

  @override
  Widget build(BuildContext context) {
    final primaryItem = items.firstWhere((item) => item.isPrimary);
    final secondaryItems = items.where((item) => !item.isPrimary).toList();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final panelBackground = theme.brightness == Brightness.dark
        ? scheme.surfaceContainerLow
        : scheme.surface;
    final tileBackground = theme.brightness == Brightness.dark
        ? scheme.surfaceContainer
        : scheme.surfaceContainerHigh;
    final rawHeight = MediaQuery.sizeOf(context).height * 0.68;
    final maxHeight = rawHeight.clamp(420.0, 620.0);

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Container(
        decoration: BoxDecoration(
          color: panelBackground,
          borderRadius: BorderRadius.circular(32),
        ),
        child: SafeArea(
          top: false,
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.hubTitle,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: scheme.primary,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.hubDescription,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.78),
                        height: 1.15,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Column(
                    children: [
                      for (
                        var index = 0;
                        index < secondaryItems.length;
                        index += 2
                      )
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: index + 2 < secondaryItems.length ? 12 : 0,
                          ),
                          child: index + 1 < secondaryItems.length
                              ? Row(
                                  children: [
                                    Expanded(
                                      child: _SecondaryActionTile(
                                        item: secondaryItems[index],
                                        l10n: l10n,
                                        backgroundColor: tileBackground,
                                        onTap: secondaryItems[index].isEnabled
                                            ? () => onItemSelected(
                                                secondaryItems[index],
                                              )
                                            : () => FeedbackService.showInfo(
                                                FeedbackMessage
                                                    .featureComingSoon,
                                              ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _SecondaryActionTile(
                                        item: secondaryItems[index + 1],
                                        l10n: l10n,
                                        backgroundColor: tileBackground,
                                        onTap:
                                            secondaryItems[index + 1].isEnabled
                                            ? () => onItemSelected(
                                                secondaryItems[index + 1],
                                              )
                                            : () => FeedbackService.showInfo(
                                                FeedbackMessage
                                                    .featureComingSoon,
                                              ),
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  children: [
                                    Expanded(
                                      child: _SecondaryActionTile(
                                        item: secondaryItems[index],
                                        l10n: l10n,
                                        backgroundColor: tileBackground,
                                        onTap: secondaryItems[index].isEnabled
                                            ? () => onItemSelected(
                                                secondaryItems[index],
                                              )
                                            : () => FeedbackService.showInfo(
                                                FeedbackMessage
                                                    .featureComingSoon,
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: _PrimaryActionCard(
                  item: primaryItem,
                  l10n: l10n,
                  onTap: () => onItemSelected(primaryItem),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrimaryActionCard extends StatelessWidget {
  const _PrimaryActionCard({
    required this.item,
    required this.l10n,
    required this.onTap,
  });

  final HubActionItem item;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(32),
      // Hero-like primary action card for the highlighted hub item.
      child: Container(
        decoration: BoxDecoration(
          color: scheme.primary,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: scheme.primary.withValues(alpha: 0.9)),
          boxShadow: [
            BoxShadow(
              color: scheme.primary.withValues(alpha: 0.18),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(item.iconData, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.title(l10n),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.subtitle(l10n).toUpperCase(),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.95),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

class _SecondaryActionTile extends StatelessWidget {
  const _SecondaryActionTile({
    required this.item,
    required this.l10n,
    required this.backgroundColor,
    required this.onTap,
  });

  final HubActionItem item;
  final AppLocalizations l10n;
  final Color backgroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = item.accent ?? scheme.secondary;
    final isAccent = item.accent != null;
    final isEnabled = item.isEnabled;
    final titleColor = isEnabled
        ? accent
        : scheme.onSurface.withValues(alpha: 0.45);
    final subtitleColor = isEnabled
        ? accent.withValues(alpha: 0.92)
        : scheme.onSurface.withValues(alpha: 0.38);
    final iconColor = isEnabled
        ? accent
        : scheme.onSurface.withValues(alpha: 0.35);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        constraints: const BoxConstraints(minHeight: 156),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isEnabled
                ? isAccent
                      ? accent.withValues(alpha: 0.28)
                      : scheme.outline.withValues(alpha: 0.4)
                : scheme.outline.withValues(alpha: 0.18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: isEnabled
                    ? Theme.of(context).brightness == Brightness.dark
                          ? 0.18
                          : 0.03
                    : 0.0,
              ),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 180),
          opacity: isEnabled ? 1 : 0.58,
          child: Center(
            child: SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(item.iconData, color: iconColor, size: 22),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.title(l10n),
                          maxLines: 2,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: titleColor,
                                fontWeight: FontWeight.w700,
                                height: 1.0,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.subtitle(l10n).toUpperCase(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: subtitleColor,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                                height: 1.0,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
