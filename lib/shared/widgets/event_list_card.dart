import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:locario/l10n/app_localizations.dart';

import '../../features/explore/models.dart';

class EventListCard extends StatelessWidget {
  const EventListCard({
    super.key,
    required this.event,
    required this.onTap,
    required this.actionIcon,
    required this.onActionPressed,
    this.actionTooltip,
    this.activeActionIcon,
    this.activeActionTooltip,
    this.isActionActive = false,
    this.referenceLocation,
    this.showDistance = true,
  });

  final ExploreEvent event;
  final VoidCallback onTap;
  final IconData actionIcon;
  final IconData? activeActionIcon;
  final String? actionTooltip;
  final String? activeActionTooltip;
  final VoidCallback? onActionPressed;
  final bool isActionActive;
  final LatLng? referenceLocation;
  final bool showDistance;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final showDistanceLine = showDistance && referenceLocation != null;
    final trailingIcon = isActionActive
        ? activeActionIcon ?? actionIcon
        : actionIcon;
    final trailingTooltip = isActionActive
        ? activeActionTooltip ?? actionTooltip
        : actionTooltip;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.18),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: Theme.of(context).brightness == Brightness.dark
                      ? 0.22
                      : 0.05,
                ),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              if (event.effectiveThumbnailUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: CachedNetworkImage(
                    imageUrl: event.effectiveThumbnailUrl!,
                    width: 54,
                    height: 54,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 54,
                      height: 54,
                      color: event.accentColor.withValues(alpha: 0.1),
                      child: const Center(
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 54,
                      height: 54,
                      color: event.accentColor.withValues(alpha: 0.14),
                      child: Icon(event.icon, color: event.accentColor),
                    ),
                  ),
                )
              else
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: event.accentColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(event.icon, color: event.accentColor),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      showDistanceLine
                          ? '${event.categoryLabel(l10n)} • ${event.distanceLabel(l10n, referenceLocation!)}'
                          : event.categoryLabel(l10n),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: event.accentColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${event.timeLabel(l10n)} • ${event.venue}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.66),
                      ),
                    ),
                    if (event.slotLimit != null && event.slotLimit! > 0) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.people_outline_rounded,
                            size: 12,
                            color: colorScheme.onSurface.withValues(alpha: 0.4),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            l10n.eventCardSpots(event.slotLimit!),
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.4,
                                  ),
                                ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                tooltip: trailingTooltip,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                icon: Icon(
                  trailingIcon,
                  size: 20,
                  color: isActionActive
                      ? colorScheme.primary
                      : colorScheme.secondary,
                ),
                onPressed: onActionPressed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
