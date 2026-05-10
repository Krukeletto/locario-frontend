import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'package:locario/l10n/app_localizations.dart';

import '../../shared/events/category_scope.dart';
import '../../shared/location/location_service.dart';
import '../../shared/widgets/event_list_card.dart';
import '../explore/models.dart';
import 'saved_event_query.dart';
import 'saved_events_controller.dart';
import 'saved_events_scope.dart';
import 'saved_events_repository.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({
    super.key,
    this.savedEventsController,
    this.locationService,
  });

  final SavedEventsController? savedEventsController;
  final LocationService? locationService;

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  final SavedEventQuery _query = const SavedEventQuery();
  SavedFilters _filters = SavedFilters.defaults;
  SavedSortOption _sort = SavedSortOption.recent;
  LatLng? _referenceLocation;
  bool _hasRequestedLocation = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasRequestedLocation) {
      return;
    }

    _hasRequestedLocation = true;
    _loadReferenceLocation();
  }

  Future<void> _loadReferenceLocation() async {
    final locationService =
        widget.locationService ?? GeolocatorLocationService();
    try {
      final enabled = await locationService.isLocationServiceEnabled();
      if (!enabled) {
        return;
      }

      final permission = await locationService.checkPermission();
      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) {
        return;
      }

      final current = await locationService.getCurrentLocation();
      final fallback =
          current ??
          (locationService.supportsLastKnownLocation
              ? await locationService.getLastKnownLocation()
              : null);

      if (!mounted || fallback == null) {
        return;
      }

      setState(() {
        _referenceLocation = fallback;
        if (_sort == SavedSortOption.distance) {
          _sort = SavedSortOption.recent;
        }
      });
    } catch (_) {
      // Distance sorting is optional. If location cannot be resolved, keep the
      // screen functional and stay on the recent sort.
    }
  }

  Future<void> _openFilters({
    required List<Category> availableCategories,
    required List<String> availableTags,
  }) async {
    final result = await showModalBottomSheet<SavedFilters>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => _SavedFiltersSheet(
        initialFilters: _filters,
        availableCategories: availableCategories,
        availableTags: availableTags,
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    setState(() {
      _filters = result;
    });
  }

  void _resetFilters() {
    if (!_filters.hasActiveFilters) {
      return;
    }

    setState(() {
      _filters = SavedFilters.defaults;
    });
  }

  void _setSort(SavedSortOption sort) {
    if (sort == SavedSortOption.distance && _referenceLocation == null) {
      return;
    }

    if (_sort == sort) {
      return;
    }

    setState(() {
      _sort = sort;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final controller =
        widget.savedEventsController ?? SavedEventsScope.of(context);
    final availableCategories =
        CategoryScope.maybeOf(
          context,
        )?.categories.cast<Category>().toList(growable: false) ??
        const <Category>[];
    final effectiveSort =
        _referenceLocation == null && _sort == SavedSortOption.distance
        ? SavedSortOption.recent
        : _sort;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        top: false,
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final visibleRecords = _query.visibleRecords(
              records: controller.records,
              filters: _filters,
              sort: effectiveSort,
              referenceLocation: _referenceLocation,
            );
            final hasSavedItems = controller.records.isNotEmpty;
            final filteredOut = hasSavedItems && visibleRecords.isEmpty;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.savedTitle,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.savedSubtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.72),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: _SavedToolbar(
                    resultsCount: visibleRecords.length,
                    activeFiltersCount: _filters.activeFiltersCount,
                    selectedSort: effectiveSort,
                    canSortByDistance: _referenceLocation != null,
                    onSortChanged: _setSort,
                    onFiltersPressed: () => _openFilters(
                      availableCategories: availableCategories,
                      availableTags: _availableTags(controller.records),
                    ),
                    onClearFilters: _filters.hasActiveFilters
                        ? _resetFilters
                        : null,
                  ),
                ),
                if (controller.isLoading)
                  const LinearProgressIndicator(minHeight: 2),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: filteredOut
                        ? _SavedEmptyState(
                            title: l10n.savedEmptyFilteredTitle,
                            subtitle: l10n.savedEmptyFilteredSubtitle,
                            onClearFilters: _filters.hasActiveFilters
                                ? _resetFilters
                                : null,
                          )
                        : hasSavedItems
                        ? ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                            itemCount: visibleRecords.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final record = visibleRecords[index];
                              return EventListCard(
                                event: record.event,
                                referenceLocation: _referenceLocation,
                                showDistance: _referenceLocation != null,
                                actionIcon: Icons.bookmark_add_outlined,
                                activeActionIcon: Icons.bookmark_rounded,
                                actionTooltip: l10n.savedSaveActionTooltip,
                                activeActionTooltip:
                                    l10n.savedRemoveActionTooltip,
                                isActionActive: controller.isSaved(
                                  record.event.id,
                                ),
                                onTap: () =>
                                    context.push('/events/${record.event.id}'),
                                onActionPressed: () {
                                  unawaited(
                                    _toggleSaved(
                                      context: context,
                                      controller: controller,
                                      event: record.event,
                                    ),
                                  );
                                },
                              );
                            },
                          )
                        : _SavedEmptyState(
                            title: l10n.savedEmptyTitle,
                            subtitle: l10n.savedEmptySubtitle,
                          ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<String> _availableTags(List<SavedEventRecord> records) {
    final tags = <String>{};
    for (final record in records) {
      for (final tag in record.event.tags) {
        final normalized = tag.trim();
        if (normalized.isNotEmpty) {
          tags.add(normalized);
        }
      }
    }
    final result = tags.toList(growable: false);
    result.sort(
      (left, right) => left.toLowerCase().compareTo(right.toLowerCase()),
    );
    return result;
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

  final message = outcome == SavedToggleOutcome.saved && !wasSaved
      ? AppLocalizations.of(context).eventSaveSuccess
      : AppLocalizations.of(context).eventRemoveSuccess;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
  );
}

class _SavedToolbar extends StatelessWidget {
  const _SavedToolbar({
    required this.resultsCount,
    required this.activeFiltersCount,
    required this.selectedSort,
    required this.canSortByDistance,
    required this.onSortChanged,
    required this.onFiltersPressed,
    required this.onClearFilters,
  });

  final int resultsCount;
  final int activeFiltersCount;
  final SavedSortOption selectedSort;
  final bool canSortByDistance;
  final ValueChanged<SavedSortOption> onSortChanged;
  final VoidCallback onFiltersPressed;
  final VoidCallback? onClearFilters;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bookmark_rounded, color: scheme.primary, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.resultsCount(resultsCount),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (onClearFilters != null)
                TextButton(
                  onPressed: onClearFilters,
                  child: Text(l10n.savedFiltersClear),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _SavedSortMenu(
                selectedSort: selectedSort,
                canSortByDistance: canSortByDistance,
                onSortChanged: onSortChanged,
              ),
              const SizedBox(width: 8),
              Stack(
                alignment: Alignment.topRight,
                children: [
                  IconButton.filledTonal(
                    tooltip: l10n.savedFiltersTooltip,
                    onPressed: onFiltersPressed,
                    icon: const Icon(Icons.tune_rounded),
                  ),
                  if (activeFiltersCount > 0)
                    Positioned(
                      right: 2,
                      top: 2,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: scheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: scheme.surface, width: 2),
                        ),
                        child: Text(
                          activeFiltersCount.toString(),
                          style: TextStyle(
                            color: scheme.onPrimary,
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SavedSortMenu extends StatelessWidget {
  const _SavedSortMenu({
    required this.selectedSort,
    required this.canSortByDistance,
    required this.onSortChanged,
  });

  final SavedSortOption selectedSort;
  final bool canSortByDistance;
  final ValueChanged<SavedSortOption> onSortChanged;

  String _labelFor(AppLocalizations l10n, SavedSortOption option) {
    return switch (option) {
      SavedSortOption.recent => l10n.savedSortRecent,
      SavedSortOption.distance => l10n.savedSortDistance,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    final options = [
      SavedSortOption.recent,
      if (canSortByDistance) SavedSortOption.distance,
    ];

    return PopupMenuButton<SavedSortOption>(
      tooltip: l10n.savedSortTooltip,
      onSelected: onSortChanged,
      itemBuilder: (context) => options
          .map(
            (option) => PopupMenuItem<SavedSortOption>(
              value: option,
              child: Row(
                children: [
                  Icon(
                    option == SavedSortOption.distance
                        ? Icons.near_me_rounded
                        : Icons.schedule_rounded,
                    size: 18,
                    color: scheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_labelFor(l10n, option))),
                  if (option == selectedSort)
                    Icon(Icons.check_rounded, size: 16, color: scheme.primary),
                ],
              ),
            ),
          )
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _labelFor(l10n, selectedSort),
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down_rounded, color: scheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _SavedEmptyState extends StatelessWidget {
  const _SavedEmptyState({
    required this.title,
    required this.subtitle,
    this.onClearFilters,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onClearFilters;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.bookmark_border_rounded,
                size: 34,
                color: scheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.72),
              ),
            ),
            if (onClearFilters != null) ...[
              const SizedBox(height: 16),
              FilledButton.tonal(
                onPressed: onClearFilters,
                child: Text(AppLocalizations.of(context).savedFiltersClear),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SavedFiltersSheet extends StatefulWidget {
  const _SavedFiltersSheet({
    required this.initialFilters,
    required this.availableCategories,
    required this.availableTags,
  });

  final SavedFilters initialFilters;
  final List<Category> availableCategories;
  final List<String> availableTags;

  @override
  State<_SavedFiltersSheet> createState() => _SavedFiltersSheetState();
}

class _SavedFiltersSheetState extends State<_SavedFiltersSheet> {
  late SavedFilters _filters;

  @override
  void initState() {
    super.initState();
    _filters = widget.initialFilters;
  }

  void _toggleCategory(String id) {
    final selected = {..._filters.selectedCategoryIds};
    if (!selected.add(id)) {
      selected.remove(id);
    }
    setState(() {
      _filters = _filters.copyWith(selectedCategoryIds: selected);
    });
  }

  void _toggleTag(String tag) {
    final normalized = tag.trim().toLowerCase();
    final selected = {..._filters.selectedTags};
    if (!selected.add(normalized)) {
      selected.remove(normalized);
    }
    setState(() {
      _filters = _filters.copyWith(selectedTags: selected);
    });
  }

  void _setAgePreset(int? minAge, int? maxAge) {
    setState(() {
      _filters = _filters.copyWith(minAge: () => minAge, maxAge: () => maxAge);
    });
  }

  void _clear() {
    if (!_filters.hasActiveFilters) {
      return;
    }

    setState(() {
      _filters = SavedFilters.defaults;
    });
  }

  void _apply() {
    Navigator.of(context).pop(_filters);
  }

  bool _isAgeSelected(int? minAge, int? maxAge) {
    return _filters.minAge == minAge && _filters.maxAge == maxAge;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.savedFiltersTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.savedFilterCategoriesTitle,
              style: theme.textTheme.titleSmall?.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterChip(
                  label: Text(l10n.filterAll),
                  selected: _filters.selectedCategoryIds.isEmpty,
                  onSelected: _filters.selectedCategoryIds.isEmpty
                      ? null
                      : (_) {
                          setState(
                            () => _filters = _filters.copyWith(
                              selectedCategoryIds: const {},
                            ),
                          );
                        },
                ),
                for (final category in widget.availableCategories)
                  FilterChip(
                    label: Text(category.name),
                    selected: _filters.selectedCategoryIds.contains(
                      category.id.trim().toLowerCase(),
                    ),
                    onSelected: (_) =>
                        _toggleCategory(category.id.trim().toLowerCase()),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              l10n.savedFilterAgeTitle,
              style: theme.textTheme.titleSmall?.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterChip(
                  label: Text(l10n.savedAgeGroupAny),
                  selected: _isAgeSelected(null, null),
                  onSelected: (_) => _setAgePreset(null, null),
                ),
                FilterChip(
                  label: Text(l10n.savedAgeGroup12Plus),
                  selected: _isAgeSelected(12, null),
                  onSelected: (_) => _setAgePreset(12, null),
                ),
                FilterChip(
                  label: Text(l10n.savedAgeGroup18Plus),
                  selected: _isAgeSelected(18, null),
                  onSelected: (_) => _setAgePreset(18, null),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.savedShowPastEvents,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Switch(
                  value: _filters.showPastEvents,
                  onChanged: (value) {
                    setState(() {
                      _filters = _filters.copyWith(showPastEvents: value);
                    });
                  },
                ),
              ],
            ),
            if (widget.availableTags.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                l10n.savedFilterTagsTitle,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final tag in widget.availableTags)
                    FilterChip(
                      label: Text(tag),
                      selected: _filters.selectedTags.contains(
                        tag.trim().toLowerCase(),
                      ),
                      onSelected: (_) => _toggleTag(tag),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _filters.hasActiveFilters ? _clear : null,
                    child: Text(l10n.savedFiltersClear),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _apply,
                    child: Text(l10n.savedFiltersApply),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
