import 'package:flutter/material.dart';
import 'package:locario/l10n/app_localizations.dart';

import '../models.dart';

class ExploreHeader extends StatelessWidget {
  const ExploreHeader({
    super.key,
    required this.selectedFilterIndices,
    required this.filters,
    required this.onFilterToggled,
    required this.searchController,
    required this.searchResults,
    required this.onSearchChanged,
    required this.onSearchResultSelected,
    required this.onSearchCleared,
  });

  final Set<int> selectedFilterIndices;
  final List<ExploreFilter> filters;
  final ValueChanged<int> onFilterToggled;
  final TextEditingController searchController;
  final List<ExploreEvent> searchResults;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<ExploreEvent> onSearchResultSelected;
  final VoidCallback onSearchCleared;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSearching = searchController.text.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SearchField(
            controller: searchController,
            results: searchResults,
            onChanged: onSearchChanged,
            onResultSelected: onSearchResultSelected,
            onCleared: onSearchCleared,
          ),
          if (!isSearching) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 38,
              child: Row(
                children: [
                  Expanded(
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: filters.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final filter = filters[index];
                        final isSelected = selectedFilterIndices.contains(index);

                        return FilterChip(
                          selected: isSelected,
                          showCheckmark: false,
                          avatar: Icon(
                            filter.icon,
                            size: 16,
                            color: isSelected
                                ? colorScheme.onPrimary
                                : colorScheme.secondary,
                          ),
                          label: Text(filter.label),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? colorScheme.onPrimary
                                : colorScheme.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                          backgroundColor: colorScheme.surfaceContainerLowest,
                          selectedColor: colorScheme.primary,
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          onSelected: (_) => onFilterToggled(index),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.results,
    required this.onChanged,
    required this.onResultSelected,
    required this.onCleared,
  });

  final TextEditingController controller;
  final List<ExploreEvent> results;
  final ValueChanged<String> onChanged;
  final ValueChanged<ExploreEvent> onResultSelected;
  final VoidCallback onCleared;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final isKeyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
    final hasQuery = controller.text.trim().isNotEmpty;
    final visibleResults = results
        .take(isKeyboardVisible ? 3 : 4)
        .toList(growable: false);

    return Row(
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                key: const Key('explore-search-field'),
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search_rounded,
                      color: colorScheme.secondary,
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: controller,
                        onChanged: onChanged,
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          hintText: l10n.exploreSearchHint,
                          border: InputBorder.none,
                          isCollapsed: true,
                        ),
                      ),
                    ),
                    if (hasQuery)
                      IconButton(
                        onPressed: onCleared,
                        icon: const Icon(Icons.close_rounded),
                        color: colorScheme.secondary,
                        splashRadius: 18,
                      ),
                  ],
                ),
              ),
              if (hasQuery && visibleResults.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.15),
                    ),
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: isKeyboardVisible ? 168 : 220,
                    ),
                    child: ListView(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      children: [
                        for (final event in visibleResults)
                          InkWell(
                            onTap: () => onResultSelected(event),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: event.accentColor.withValues(
                                        alpha: 0.14,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      event.icon,
                                      color: event.accentColor,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          event.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${event.categoryLabel} • ${event.venue}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: colorScheme.onSurface
                                                    .withValues(alpha: 0.64),
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
