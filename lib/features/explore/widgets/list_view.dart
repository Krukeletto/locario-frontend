import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:locario/l10n/app_localizations.dart';

import '../models.dart';

class ExploreListView extends StatelessWidget {
  const ExploreListView({
    super.key,
    required this.events,
    required this.referenceLocation,
    required this.selectedFilterSummary,
    required this.selectedArea,
    required this.selectedSort,
    required this.selectedDistanceFilter,
    required this.isSearchActive,
    required this.onAreaPressed,
    required this.onSortChanged,
    required this.onDistanceFilterChanged,
    required this.onEventTap,
  });

  final List<ExploreEvent> events;
  final LatLng referenceLocation;
  final String selectedFilterSummary;
  final ExploreAreaSelection selectedArea;
  final ExploreSortOption selectedSort;
  final ExploreDistanceFilter selectedDistanceFilter;
  final bool isSearchActive;
  final VoidCallback onAreaPressed;
  final ValueChanged<ExploreSortOption> onSortChanged;
  final ValueChanged<ExploreDistanceFilter> onDistanceFilterChanged;
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
                selectedArea: selectedArea,
                selectedSort: selectedSort,
                selectedDistanceFilter: selectedDistanceFilter,
                onAreaPressed: onAreaPressed,
                onSortChanged: onSortChanged,
                onDistanceFilterChanged: onDistanceFilterChanged,
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
    required this.selectedArea,
    required this.selectedSort,
    required this.selectedDistanceFilter,
    required this.onAreaPressed,
    required this.onSortChanged,
    required this.onDistanceFilterChanged,
  });

  final int eventsCount;
  final String selectedFilterSummary;
  final String allFilterLabel;
  final ExploreAreaSelection selectedArea;
  final ExploreSortOption selectedSort;
  final ExploreDistanceFilter selectedDistanceFilter;
  final VoidCallback onAreaPressed;
  final ValueChanged<ExploreSortOption> onSortChanged;
  final ValueChanged<ExploreDistanceFilter> onDistanceFilterChanged;

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
          Row(
            children: [
              Expanded(
                child: Text(
                  selectedFilterSummary == allFilterLabel
                      ? l10n.exploreNearbyEvents
                      : l10n.exploreNearbyWithFilter(selectedFilterSummary),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              _SortMenu(
                selectedSort: selectedSort,
                onSortChanged: onSortChanged,
              ),
              const SizedBox(width: 8),
              _DistanceFilterMenu(
                selectedDistanceFilter: selectedDistanceFilter,
                onDistanceFilterChanged: onDistanceFilterChanged,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.tune_rounded, size: 16, color: colorScheme.primary),
              const SizedBox(width: 6),
              Text(
                l10n.resultsCount(eventsCount),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                  key: const Key('explore-area-button'),
                  onTap: onAreaPressed,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          selectedArea.icon,
                          size: 16,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            selectedArea.label,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: colorScheme.secondary,
                        ),
                      ],
                    ),
                  ),
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
  const _SortMenu({required this.selectedSort, required this.onSortChanged});

  final ExploreSortOption selectedSort;
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
                  Text(_labelFor(l10n, option)),
                ],
              ),
            ),
          )
          .toList(),
      child: Container(
        key: const Key('explore-sort-button'),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.swap_vert_rounded, color: colorScheme.primary, size: 17),
            const SizedBox(width: 6),
            Text(
              _labelFor(l10n, selectedSort),
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _DistanceFilterMenu extends StatelessWidget {
  const _DistanceFilterMenu({
    required this.selectedDistanceFilter,
    required this.onDistanceFilterChanged,
  });

  final ExploreDistanceFilter selectedDistanceFilter;
  final ValueChanged<ExploreDistanceFilter> onDistanceFilterChanged;

  String _labelFor(
    AppLocalizations l10n,
    ExploreDistanceFilter distanceFilter,
  ) {
    return switch (distanceFilter) {
      ExploreDistanceFilter.any => l10n.distanceFilterAny,
      ExploreDistanceFilter.within1Km => l10n.distanceFilterWithinKm(1),
      ExploreDistanceFilter.within3Km => l10n.distanceFilterWithinKm(3),
      ExploreDistanceFilter.within5Km => l10n.distanceFilterWithinKm(5),
      ExploreDistanceFilter.within10Km => l10n.distanceFilterWithinKm(10),
      ExploreDistanceFilter.within25Km => l10n.distanceFilterWithinKm(25),
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return PopupMenuButton<ExploreDistanceFilter>(
      tooltip: l10n.distanceFilterTooltip,
      onSelected: onDistanceFilterChanged,
      itemBuilder: (context) => ExploreDistanceFilter.values
          .map(
            (option) => PopupMenuItem<ExploreDistanceFilter>(
              value: option,
              child: Row(
                children: [
                  Icon(
                    option == ExploreDistanceFilter.any
                        ? Icons.public_rounded
                        : Icons.radar_rounded,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(_labelFor(l10n, option)),
                ],
              ),
            ),
          )
          .toList(),
      child: Container(
        key: const Key('explore-distance-filter-button'),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.radar_rounded, color: colorScheme.primary, size: 17),
            const SizedBox(width: 6),
            Text(
              _labelFor(l10n, selectedDistanceFilter),
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
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
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded, color: colorScheme.secondary),
            ],
          ),
        ),
      ),
    );
  }
}
