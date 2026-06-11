import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:locario/l10n/app_localizations.dart';
import 'package:locario/shared/groups/group_models.dart';

import '../../saved/saved_filters_scope.dart';
import '../explore_area_controller.dart';
import '../models.dart';
import 'area_picker.dart';

class ExploreAdvancedFilterResult {
  const ExploreAdvancedFilterResult({
    required this.filters,
    this.shouldPickOnMap = false,
  });

  final ExploreAdvancedFilters filters;
  final bool shouldPickOnMap;
}

class ExploreAdvancedFilterSheet extends StatefulWidget {
  const ExploreAdvancedFilterSheet({
    super.key,
    required this.initialFilters,
    required this.areaController,
    this.userGroups = const [],
  });

  final ExploreAdvancedFilters initialFilters;
  final ExploreAreaController areaController;
  final List<Group> userGroups;

  @override
  State<ExploreAdvancedFilterSheet> createState() =>
      _ExploreAdvancedFilterSheetState();
}

class _ExploreAdvancedFilterSheetState
    extends State<ExploreAdvancedFilterSheet> {
  static const _ageMin = 0.0;
  static const _ageMax = 100.0;

  late ExploreAdvancedFilters _filters;

  @override
  void initState() {
    super.initState();
    _filters = widget.initialFilters;
  }

  bool get _isDefaultState => _filters == ExploreAdvancedFilters.defaults;

  bool _isSameCalendarDay(DateTime? left, DateTime? right) {
    if (left == null || right == null) {
      return false;
    }

    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }

  bool _matchesQuickDay(int offset) {
    final now = DateTime.now();
    final day = DateTime(
      now.year,
      now.month,
      now.day,
    ).add(Duration(days: offset));
    return _isSameCalendarDay(_filters.dateFrom, day) &&
        _isSameCalendarDay(_filters.dateTo, day);
  }

  bool get _hasCustomDateRange {
    if (_filters.dateFrom == null && _filters.dateTo == null) {
      return false;
    }

    return !_matchesQuickDay(0) && !_matchesQuickDay(1);
  }

  bool get _hasCustomAgeRange {
    if (_filters.ageFrom == null && _filters.ageTo == null) {
      return false;
    }

    return !(_filters.ageFrom == 12 && _filters.ageTo == null) &&
        !(_filters.ageFrom == 18 && _filters.ageTo == null);
  }

  void _apply() {
    Navigator.of(context).pop(ExploreAdvancedFilterResult(filters: _filters));
  }

  Future<void> _saveFilter() async {
    final l10n = AppLocalizations.of(context);
    final savedFiltersController = SavedFiltersScope.maybeOf(context);
    if (savedFiltersController == null) return;

    final nameController = TextEditingController();
    var notificationsEnabled = false;
    var useCurrentLocation = true;
    LatLng? savedLocation;

    final areaMode = widget.areaController.selectionMode;
    if (areaMode != ExploreAreaSelectionMode.currentLocation) {
      savedLocation = widget.areaController.referenceLocation(
        currentLocation: null,
        fallbackCenter: const LatLng(0, 0),
      );
      useCurrentLocation = false;
    }

    try {
      final result = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: Text(l10n.savedFiltersSaveDialogTitle),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: nameController,
                        onChanged: (_) => setDialogState(() {}),
                        decoration: InputDecoration(
                          hintText: l10n.savedFiltersNameHint,
                          border: const OutlineInputBorder(),
                        ),
                        autofocus: true,
                      ),
                      if (savedLocation != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          l10n.savedFiltersLocationLabel,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        SegmentedButton<bool>(
                          segments: [
                            ButtonSegment(
                              value: true,
                              label: Text(l10n.savedFiltersUseCurrentLocation),
                              icon: const Icon(
                                Icons.my_location_rounded,
                                size: 16,
                              ),
                            ),
                            ButtonSegment(
                              value: false,
                              label: Text(l10n.savedFiltersUseSavedLocation),
                              icon: const Icon(
                                Icons.location_on_rounded,
                                size: 16,
                              ),
                            ),
                          ],
                          selected: {useCurrentLocation},
                          onSelectionChanged: (selected) {
                            setDialogState(() {
                              useCurrentLocation = selected.first;
                            });
                          },
                        ),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Text(l10n.savedFilterNotificationsLabel),
                          const Spacer(),
                          Switch(
                            value: notificationsEnabled,
                            onChanged: (value) {
                              setDialogState(() {
                                notificationsEnabled = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    child: Text(l10n.savedFiltersCancel),
                  ),
                  FilledButton(
                    onPressed: nameController.text.trim().isEmpty
                        ? null
                        : () => Navigator.of(dialogContext).pop(true),
                    child: Text(l10n.savedFiltersSaveAction),
                  ),
                ],
              );
            },
          );
        },
      );

      if (result != true || !context.mounted) return;
      if (nameController.text.trim().isEmpty) return;

      await savedFiltersController.saveFilter(
        name: nameController.text.trim(),
        filters: _filters,
        location: useCurrentLocation ? null : savedLocation,
        useCurrentLocation: useCurrentLocation,
        notificationsEnabled: notificationsEnabled,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.savedFiltersSaveConfirmation),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      nameController.dispose();
    }
  }

  void _onPickOnMap() {
    Navigator.of(context).pop(
      ExploreAdvancedFilterResult(filters: _filters, shouldPickOnMap: true),
    );
  }

  Future<void> _handleAreaPressed() async {
    final l10n = AppLocalizations.of(context);
    final action = await showModalBottomSheet<ExploreAreaSelectionAction>(
      context: context,
      showDragHandle: true,
      builder: (context) => ExploreAreaSelectionSheet(
        title: l10n.areaPickerTitle,
        subtitle: l10n.areaPickerSubtitle,
        onActionSelected: (action) => Navigator.of(context).pop(action),
      ),
    );

    if (!mounted || action == null) {
      return;
    }

    switch (action) {
      case ExploreAreaSelectionAction.currentLocation:
        widget.areaController.selectCurrentLocation();
        setState(() {});
        return;
      case ExploreAreaSelectionAction.enterAddress:
        await _handleAddressSelection();
        return;
      case ExploreAreaSelectionAction.pickOnMap:
        _onPickOnMap();
        return;
    }
  }

  Future<void> _handleAddressSelection() async {
    final l10n = AppLocalizations.of(context);
    final address = await showDialog<String>(
      context: context,
      builder: (context) => const ExploreAddressInputDialog(),
    );

    if (!mounted || address == null || address.trim().isEmpty) {
      return;
    }

    final result = await widget.areaController.selectAddress(address.trim());
    if (!mounted) {
      return;
    }

    switch (result.status) {
      case ExploreAddressLookupStatus.success:
        setState(() {});
        return;
      case ExploreAddressLookupStatus.notFound:
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.areaAddressNotFound)));
        return;
      case ExploreAddressLookupStatus.error:
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.areaAddressLookupFailed)));
        return;
    }
  }

  void _clear() {
    if (_isDefaultState) {
      return;
    }

    setState(() {
      _filters = ExploreAdvancedFilters.defaults;
    });
  }

  void _setQuickDate(int days) {
    final now = DateTime.now();
    final target = DateTime(
      now.year,
      now.month,
      now.day,
    ).add(Duration(days: days));
    setState(() {
      _filters = _filters.copyWith(
        dateFrom: () => target,
        dateTo: () => target,
      );
    });
  }

  void _setAgeGroup(int? min, int? max) {
    setState(() {
      _filters = _filters.copyWith(ageFrom: () => min, ageTo: () => max);
    });
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      initialDateRange: _filters.dateFrom != null && _filters.dateTo != null
          ? DateTimeRange(start: _filters.dateFrom!, end: _filters.dateTo!)
          : null,
      firstDate: DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(const Duration(days: 1)),
      lastDate: DateTime(now.year + 1, now.month, now.day),
    );

    if (range == null || !mounted) {
      return;
    }

    setState(() {
      _filters = _filters.copyWith(
        dateFrom: () =>
            DateTime(range.start.year, range.start.month, range.start.day),
        dateTo: () => DateTime(range.end.year, range.end.month, range.end.day),
      );
    });
  }

  Future<void> _pickAgeRange() async {
    final result = await showModalBottomSheet<RangeValues>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (context) {
        var values = RangeValues(
          (_filters.ageFrom ?? _ageMin.toInt()).toDouble().clamp(
            _ageMin,
            _ageMax,
          ),
          (_filters.ageTo ?? _ageMax.toInt()).toDouble().clamp(
            _ageMin,
            _ageMax,
          ),
        );

        if (values.start > values.end) {
          values = RangeValues(values.end, values.end);
        }

        return StatefulBuilder(
          builder: (context, setModalState) {
            final l10n = AppLocalizations.of(context);
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.filterAdvancedAgeOther,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.filterAdvancedAgeRangeSummary(
                      values.start.round(),
                      values.end.round(),
                    ),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  RangeSlider(
                    min: _ageMin,
                    max: _ageMax,
                    divisions: (_ageMax - _ageMin).toInt(),
                    values: values,
                    labels: RangeLabels(
                      values.start.round().toString(),
                      values.end.round().toString(),
                    ),
                    onChanged: (next) => setModalState(() => values = next),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(l10n.areaDialogCancel),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () => Navigator.of(context).pop(values),
                          child: Text(l10n.areaDialogConfirm),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (result == null || !mounted) {
      return;
    }

    final start = result.start.round();
    final end = result.end.round();
    setState(() {
      _filters = _filters.copyWith(
        ageFrom: () => start <= _ageMin ? null : start,
        ageTo: () => end >= _ageMax ? null : end,
      );
    });
  }

  String _distanceLabelFor(
    AppLocalizations l10n,
    ExploreDistanceFilter filter,
  ) {
    return switch (filter) {
      ExploreDistanceFilter.within1Km => l10n.distanceFilterWithinKm(1),
      ExploreDistanceFilter.within3Km => l10n.distanceFilterWithinKm(3),
      ExploreDistanceFilter.within5Km => l10n.distanceFilterWithinKm(5),
      ExploreDistanceFilter.within10Km => l10n.distanceFilterWithinKm(10),
      ExploreDistanceFilter.within25Km => l10n.distanceFilterWithinKm(25),
    };
  }

  String _dateSummary(AppLocalizations l10n) {
    final from = _filters.dateFrom;
    final to = _filters.dateTo;
    if (from == null && to == null) {
      return l10n.filterAdvancedDateAny;
    }
    if (from != null && to != null) {
      return '${_formatDate(from)} - ${_formatDate(to)}';
    }
    if (from != null) {
      return '${l10n.filterAdvancedDateFrom} ${_formatDate(from)}';
    }
    return '${l10n.filterAdvancedDateTo} ${_formatDate(to!)}';
  }

  String _ageSummary(AppLocalizations l10n) {
    final from = _filters.ageFrom;
    final to = _filters.ageTo;
    if (from == null && to == null) {
      return l10n.filterAll;
    }
    if (from != null && to != null) {
      return l10n.filterAdvancedAgeRangeSummary(from, to);
    }
    if (from != null) {
      return '$from+';
    }
    return '0-$to';
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day.$month.${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final distanceIndex = ExploreDistanceFilter.values.indexOf(
      _filters.distanceFilter,
    );

    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.56,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.filterAdvancedFilters,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colorScheme.primary,
                    ),
                  ),
                  TextButton(
                    onPressed: _isDefaultState ? null : _clear,
                    child: Text(l10n.filterAdvancedClear),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  children: [
                    _SectionTitle(title: l10n.filterAdvancedDistance),
                    const SizedBox(height: 8),
                    ListenableBuilder(
                      listenable: widget.areaController,
                      builder: (context, _) {
                        final selectedArea = widget.areaController
                            .selectedArea();
                        return _buildAreaSelector(
                          context,
                          colorScheme,
                          selectedArea,
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _CompactSurface(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _distanceLabelFor(l10n, _filters.distanceFilter),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Slider(
                            value: distanceIndex.toDouble(),
                            min: 0,
                            max: (ExploreDistanceFilter.values.length - 1)
                                .toDouble(),
                            divisions: ExploreDistanceFilter.values.length - 1,
                            label: _distanceLabelFor(
                              l10n,
                              _filters.distanceFilter,
                            ),
                            onChanged: (value) {
                              setState(() {
                                _filters = _filters.copyWith(
                                  distanceFilter: ExploreDistanceFilter
                                      .values[value.round()],
                                );
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SectionTitle(title: l10n.filterAdvancedDateRange),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _QuickChip(
                          label: l10n.filterAdvancedDateToday,
                          onTap: () => _setQuickDate(0),
                          isSelected: _matchesQuickDay(0),
                        ),
                        _QuickChip(
                          label: l10n.filterAdvancedDateTomorrow,
                          onTap: () => _setQuickDate(1),
                          isSelected: _matchesQuickDay(1),
                        ),
                        _QuickChip(
                          label: l10n.filterAdvancedDateOther,
                          onTap: _pickDateRange,
                          isSelected: _hasCustomDateRange,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _SelectionTile(
                      label: l10n.filterAdvancedDateSelection,
                      value: _dateSummary(l10n),
                      hasValue:
                          _filters.dateFrom != null || _filters.dateTo != null,
                      onTap: _pickDateRange,
                      onClear:
                          _filters.dateFrom != null || _filters.dateTo != null
                          ? () {
                              setState(() {
                                _filters = _filters.copyWith(
                                  dateFrom: () => null,
                                  dateTo: () => null,
                                );
                              });
                            }
                          : null,
                    ),
                    const SizedBox(height: 16),
                    _SectionTitle(title: l10n.filterAdvancedAge),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _QuickChip(
                          label: l10n.filterAll,
                          onTap: () => _setAgeGroup(null, null),
                          isSelected:
                              _filters.ageFrom == null &&
                              _filters.ageTo == null,
                        ),
                        _QuickChip(
                          label: '12+',
                          onTap: () => _setAgeGroup(12, null),
                          isSelected:
                              _filters.ageFrom == 12 && _filters.ageTo == null,
                        ),
                        _QuickChip(
                          label: '18+',
                          onTap: () => _setAgeGroup(18, null),
                          isSelected:
                              _filters.ageFrom == 18 && _filters.ageTo == null,
                        ),
                        _QuickChip(
                          label: l10n.filterAdvancedAgeOther,
                          onTap: _pickAgeRange,
                          isSelected: _hasCustomAgeRange,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _SelectionTile(
                      label: l10n.filterAdvancedAgeSelection,
                      value: _ageSummary(l10n),
                      hasValue:
                          _filters.ageFrom != null || _filters.ageTo != null,
                      onTap: _pickAgeRange,
                      onClear:
                          _filters.ageFrom != null || _filters.ageTo != null
                          ? () => _setAgeGroup(null, null)
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.savedShowPastEvents,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Switch(
                          value: _filters.showPastEvents,
                          onChanged: (value) {
                            setState(() {
                              _filters = _filters.copyWith(
                                showPastEvents: value,
                              );
                            });
                          },
                        ),
                      ],
                    ),
                    if (widget.userGroups.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _SectionTitle(title: l10n.groupsTabFeed),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _QuickChip(
                            label: l10n.filterAll,
                            onTap: () {
                              setState(() {
                                _filters = _filters.copyWith(groupIds: []);
                              });
                            },
                            isSelected: _filters.groupIds.isEmpty,
                          ),
                          for (final group in widget.userGroups)
                            _QuickChip(
                              label: group.name,
                              onTap: () {
                                final current = List<String>.of(
                                  _filters.groupIds,
                                );
                                if (current.contains(group.id)) {
                                  current.remove(group.id);
                                } else {
                                  current.add(group.id);
                                }
                                setState(() {
                                  _filters = _filters.copyWith(
                                    groupIds: current,
                                  );
                                });
                              },
                              isSelected: _filters.groupIds.contains(
                                group.id,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed: _saveFilter,
                      icon: const Icon(Icons.bookmark_add_outlined, size: 18),
                      label: Text(l10n.savedFiltersSaveAction),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: _apply,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        l10n.filterAdvancedApply,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAreaSelector(
    BuildContext context,
    ColorScheme colorScheme,
    ExploreAreaSelection selectedArea,
  ) {
    return InkWell(
      key: const Key('explore-area-filter-button'),
      onTap: _handleAreaPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            Icon(selectedArea.icon, color: colorScheme.primary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedArea.label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    selectedArea.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.edit_location_alt_rounded, color: colorScheme.secondary),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({
    required this.label,
    required this.onTap,
    required this.isSelected,
  });

  final String label;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      labelStyle: TextStyle(
        color: isSelected
            ? colorScheme.onSecondaryContainer
            : colorScheme.onSurfaceVariant,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
      ),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _CompactSurface extends StatelessWidget {
  const _CompactSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: child,
    );
  }
}

class _SelectionTile extends StatelessWidget {
  const _SelectionTile({
    required this.label,
    required this.value,
    required this.hasValue,
    required this.onTap,
    this.onClear,
  });

  final String label;
  final String value;
  final bool hasValue;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: hasValue ? FontWeight.w700 : FontWeight.w400,
                      color: hasValue
                          ? colorScheme.onSurface
                          : colorScheme.onSurface.withValues(alpha: 0.56),
                    ),
                  ),
                ],
              ),
            ),
            if (onClear != null)
              InkWell(
                onTap: onClear,
                child: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: colorScheme.secondary,
                ),
              )
            else
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: colorScheme.secondary,
              ),
          ],
        ),
      ),
    );
  }
}
