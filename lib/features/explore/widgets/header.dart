import 'package:flutter/material.dart';
import 'package:locario/l10n/app_localizations.dart';
import '../models.dart';

class ExploreHeader extends StatelessWidget implements PreferredSizeWidget {
  const ExploreHeader({
    super.key,
    required this.searchController,
    required this.searchFocusNode,
    required this.onFilterPressed,
    this.includeTopInset = true,
    this.searchResults = const [],
    this.onSearchChanged,
    this.onSearchResultSelected,
    this.onSearchCleared,
    this.activeFiltersCount = 0,
    required this.selectedFilterIndices,
    required this.onFilterToggled,
    this.availableCategories = const [],
  });

  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final VoidCallback onFilterPressed;
  final bool includeTopInset;
  final List<ExploreEvent> searchResults;
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<ExploreEvent>? onSearchResultSelected;
  final VoidCallback? onSearchCleared;
  final int activeFiltersCount;
  final Set<int> selectedFilterIndices;
  final ValueChanged<int> onFilterToggled;
  final List<Category> availableCategories;

  @override
  Size get preferredSize => const Size.fromHeight(116);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final topPadding = includeTopInset
        ? MediaQuery.paddingOf(context).top + 8
        : 4.0;

    return Container(
      padding: EdgeInsets.only(top: topPadding, bottom: 8),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _SearchField(
                    controller: searchController,
                    focusNode: searchFocusNode,
                    results: searchResults,
                    onChanged: onSearchChanged,
                    onResultSelected: onSearchResultSelected,
                    onCleared: onSearchCleared,
                  ),
                ),
                const SizedBox(width: 12),
                _HeaderIconButton(
                  icon: Icons.tune_rounded,
                  onPressed: onFilterPressed,
                  badgeCount: activeFiltersCount,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _CategoryFilterBar(
            selectedFilterIndices: selectedFilterIndices,
            onFilterToggled: onFilterToggled,
            availableCategories: availableCategories,
          ),
        ],
      ),
    );
  }
}

class _CategoryFilterBar extends StatelessWidget {
  const _CategoryFilterBar({
    required this.selectedFilterIndices,
    required this.onFilterToggled,
    required this.availableCategories,
  });

  final Set<int> selectedFilterIndices;
  final ValueChanged<int> onFilterToggled;
  final List<Category> availableCategories;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    final categoryCount = 1 + availableCategories.length;

    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categoryCount,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = selectedFilterIndices.contains(index);
          final String label;
          if (index == 0) {
            label = l10n.filterAll;
          } else {
            label = availableCategories[index - 1].name;
          }

          return FilterChip(
            selected: isSelected,
            showCheckmark: false,
            label: Text(label),
            onSelected: (_) => onFilterToggled(index),
            labelStyle: TextStyle(
              color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 13,
            ),
            backgroundColor: colorScheme.surfaceContainerLow,
            selectedColor: colorScheme.primary,
            side: BorderSide.none,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          );
        },
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.focusNode,
    required this.results,
    this.onChanged,
    this.onResultSelected,
    this.onCleared,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final List<ExploreEvent> results;
  final ValueChanged<String>? onChanged;
  final ValueChanged<ExploreEvent>? onResultSelected;
  final VoidCallback? onCleared;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final hasQuery = controller.text.trim().isNotEmpty;
    final showResults = hasQuery && results.isNotEmpty;

    return RawAutocomplete<ExploreEvent>(
      textEditingController: controller,
      focusNode: focusNode,
      displayStringForOption: (event) => event.title,
      optionsBuilder: (textEditingValue) {
        if (textEditingValue.text.trim().isEmpty) {
          return const Iterable<ExploreEvent>.empty();
        }
        return results;
      },
      onSelected: (event) {
        onResultSelected?.call(event);
      },
      fieldViewBuilder: (context, textEditingController, textFocusNode, _) {
        return Container(
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
                  controller: textEditingController,
                  focusNode: textFocusNode,
                  onChanged: onChanged,
                  textInputAction: TextInputAction.search,
                  onTapOutside: (_) => textFocusNode.unfocus(),
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
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        if (!showResults) {
          return const SizedBox.shrink();
        }

        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.sizeOf(context).width - 92,
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.14),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 280),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shrinkWrap: true,
                  itemCount: options.length,
                  separatorBuilder: (_, _) => Divider(
                    height: 1,
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                  itemBuilder: (context, index) {
                    final event = options.elementAt(index);
                    return ListTile(
                      dense: true,
                      title: Text(
                        event.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        event.venue,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Icon(
                        event.icon,
                        size: 18,
                        color: event.accentColor,
                      ),
                      onTap: () => onSelected(event),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.onPressed,
    this.badgeCount = 0,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(icon),
          color: badgeCount > 0 ? colorScheme.primary : colorScheme.secondary,
          style: IconButton.styleFrom(
            backgroundColor: colorScheme.surfaceContainerLow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            minimumSize: const Size(48, 48),
          ),
        ),
        if (badgeCount > 0)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
                border: Border.all(color: colorScheme.surface, width: 2),
              ),
              child: Text(
                badgeCount.toString(),
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
