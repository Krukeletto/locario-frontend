import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:locario/l10n/app_localizations.dart';

import '../models.dart';
import '../../../shared/services/share_service.dart';

class ExploreListView extends StatelessWidget {
  const ExploreListView({
    super.key,
    required this.events,
    required this.referenceLocation,
    required this.selectedFilterSummary,
    required this.selectedSort,
    required this.sortAscending,
    required this.isSearchActive,
    required this.onSortChanged,
    required this.onSortOrderToggled,
    this.onSortOpened,
    required this.onEventTap,
  });

  final List<ExploreEvent> events;
  final LatLng referenceLocation;
  final String selectedFilterSummary;
  final ExploreSortOption selectedSort;
  final bool sortAscending;
  final bool isSearchActive;
  final ValueChanged<ExploreSortOption> onSortChanged;
  final VoidCallback onSortOrderToggled;
  final VoidCallback? onSortOpened;
  final ValueChanged<ExploreEvent> onEventTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final isKeyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
    final hideToolbar = isKeyboardVisible || isSearchActive;

    return ColoredBox(
      color: colorScheme.surface,
      child: Column(
        children: [
          if (!hideToolbar)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: _ListToolbar(
                eventsCount: events.length,
                selectedFilterSummary: selectedFilterSummary,
                allFilterLabel: l10n.filterAll,
                selectedSort: selectedSort,
                sortAscending: sortAscending,
                onSortOpened: onSortOpened,
                onSortChanged: onSortChanged,
                onSortOrderToggled: onSortOrderToggled,
              ),
            ),
          Expanded(
            child: ListView.separated(
              key: const Key('explore-event-list'),
              padding: EdgeInsets.fromLTRB(16, hideToolbar ? 12 : 8, 16, 20),
              itemCount: events.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final event = events[index];
                return _EventCard(
                  event: event,
                  referenceLocation: referenceLocation,
                  onTap: () => onEventTap(event),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ListToolbar extends StatelessWidget {
  const _ListToolbar({
    required this.eventsCount,
    required this.selectedFilterSummary,
    required this.allFilterLabel,
    required this.selectedSort,
    required this.sortAscending,
    this.onSortOpened,
    required this.onSortChanged,
    required this.onSortOrderToggled,
  });

  final int eventsCount;
  final String selectedFilterSummary;
  final String allFilterLabel;
  final ExploreSortOption selectedSort;
  final bool sortAscending;
  final VoidCallback? onSortOpened;
  final ValueChanged<ExploreSortOption> onSortChanged;
  final VoidCallback onSortOrderToggled;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            selectedFilterSummary == allFilterLabel
                ? l10n.exploreNearbyEvents
                : l10n.exploreNearbyWithFilter(selectedFilterSummary),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Spacer(),
              IconButton.filledTonal(
                onPressed: onSortOrderToggled,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                padding: EdgeInsets.zero,
                icon: AnimatedRotation(
                  duration: const Duration(milliseconds: 200),
                  turns: sortAscending ? 0 : 0.5,
                  child: const Icon(Icons.sort_rounded, size: 20),
                ),
              ),
              const SizedBox(width: 8),
              _SortMenu(
                selectedSort: selectedSort,
                onOpened: onSortOpened,
                onSortChanged: onSortChanged,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.format_list_bulleted_rounded,
                size: 14,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                l10n.resultsCount(eventsCount),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SortMenu extends StatelessWidget {
  const _SortMenu({
    required this.selectedSort,
    this.onOpened,
    required this.onSortChanged,
  });

  final ExploreSortOption selectedSort;
  final VoidCallback? onOpened;
  final ValueChanged<ExploreSortOption> onSortChanged;

  String _labelFor(AppLocalizations l10n, ExploreSortOption option) {
    return switch (option) {
      ExploreSortOption.distance => l10n.sortDistance,
      ExploreSortOption.soonest => l10n.sortSoonest,
      ExploreSortOption.trending => l10n.sortTrending,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return PopupMenuButton<ExploreSortOption>(
      tooltip: l10n.sortTooltip,
      onOpened: onOpened,
      onSelected: onSortChanged,
      itemBuilder: (context) => ExploreSortOption.values
          .map(
            (option) => PopupMenuItem<ExploreSortOption>(
              value: option,
              child: Row(
                children: [
                  Icon(
                    option == ExploreSortOption.distance
                        ? Icons.near_me_rounded
                        : option == ExploreSortOption.soonest
                        ? Icons.schedule_rounded
                        : Icons.local_fire_department_rounded,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_labelFor(l10n, option))),
                  if (option == selectedSort)
                    Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: colorScheme.primary,
                    ),
                ],
              ),
            ),
          )
          .toList(),
      child: Container(
        key: const Key('explore-sort-button'),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _labelFor(l10n, selectedSort),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down_rounded,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({
    required this.event,
    required this.referenceLocation,
    required this.onTap,
  });

  final ExploreEvent event;
  final LatLng referenceLocation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

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
                      '${event.categoryLabel(l10n)} • ${event.distanceLabel(l10n, referenceLocation)}',
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
                  ],
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                icon: Icon(
                  Icons.share_rounded,
                  size: 20,
                  color: colorScheme.secondary,
                ),
                onPressed: () {
                  final l10n = AppLocalizations.of(context)!;
                  ShareService.shareEvent(
                    eventId: event.id,
                    title: event.title,
                    l10n: l10n,
                  );
                },
              ),
              Icon(Icons.chevron_right_rounded, color: colorScheme.secondary),
            ],
          ),
        ),
      ),
    );
  }
}
