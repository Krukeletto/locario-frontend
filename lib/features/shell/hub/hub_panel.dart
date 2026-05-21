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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final panelBackground = theme.brightness == Brightness.dark
        ? scheme.surfaceContainerLow
        : scheme.surface;
    final tileBackground = theme.brightness == Brightness.dark
        ? scheme.surfaceContainer
        : scheme.surfaceContainerHigh;

    return Container(
      decoration: BoxDecoration(
        color: panelBackground,
        borderRadius: BorderRadius.circular(32),
      ),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
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
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  for (var index = 0; index < items.length; index += 2)
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: index + 2 < items.length ? 12 : 0,
                      ),
                      child: index + 1 < items.length
                          ? Row(
                              children: [
                                Expanded(
                                  child: _HubActionTile(
                                    item: items[index],
                                    l10n: l10n,
                                    backgroundColor: tileBackground,
                                    onTap: items[index].isEnabled
                                        ? () => onItemSelected(items[index])
                                        : () => FeedbackService.showInfo(
                                            FeedbackMessage.featureComingSoon,
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _HubActionTile(
                                    item: items[index + 1],
                                    l10n: l10n,
                                    backgroundColor: tileBackground,
                                    onTap: items[index + 1].isEnabled
                                        ? () => onItemSelected(items[index + 1])
                                        : () => FeedbackService.showInfo(
                                            FeedbackMessage.featureComingSoon,
                                          ),
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                Expanded(
                                  child: _HubActionTile(
                                    item: items[index],
                                    l10n: l10n,
                                    backgroundColor: tileBackground,
                                    onTap: items[index].isEnabled
                                        ? () => onItemSelected(items[index])
                                        : () => FeedbackService.showInfo(
                                            FeedbackMessage.featureComingSoon,
                                          ),
                                  ),
                                ),
                              ],
                            ),
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

class _HubActionTile extends StatelessWidget {
  const _HubActionTile({
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
    final theme = Theme.of(context);
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
              color: isEnabled ? theme.shadowColor : Colors.transparent,
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
