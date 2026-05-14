import 'dart:async';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:locario/l10n/app_localizations.dart';

import '../../../shared/services/feedback_service.dart';
import '../../../shared/widgets/event_list_card.dart';
import '../../saved/saved_events_controller.dart';
import '../models.dart';

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
    this.savedEventsController,
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
  final SavedEventsController? savedEventsController;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
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
                final controller = savedEventsController;

                return EventListCard(
                  event: event,
                  referenceLocation: referenceLocation,
                  showDistance: true,
                  actionIcon: Icons.bookmark_add_outlined,
                  activeActionIcon: Icons.bookmark_rounded,
                  actionTooltip: l10n.savedSaveActionTooltip,
                  activeActionTooltip: l10n.savedRemoveActionTooltip,
                  isActionActive: controller?.isSaved(event.id) ?? false,
                  onTap: () => onEventTap(event),
                  onActionPressed: controller == null
                      ? null
                      : () {
                          unawaited(
                            _toggleSaved(
                              context: context,
                              controller: controller,
                              event: event,
                            ),
                          );
                        },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _toggleSaved({
  required BuildContext context,
  required SavedEventsController controller,
  required ExploreEvent event,
}) async {
  final wasSaved = controller.isSaved(event.id);
  final outcome = await controller.toggleSaved(event);
  if (!context.mounted) {
    return;
  }

  if (outcome == SavedToggleOutcome.failed) {
    FeedbackService.showError(FeedbackMessage.networkError);
    return;
  }

  if (outcome == SavedToggleOutcome.saved && !wasSaved) {
    FeedbackService.showSuccess(FeedbackMessage.eventSaveSuccess);
    return;
  }

  FeedbackService.showSuccess(FeedbackMessage.eventRemoveSuccess);
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
    final l10n = AppLocalizations.of(context);

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
    final l10n = AppLocalizations.of(context);

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
