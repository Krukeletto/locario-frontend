import 'package:flutter/material.dart';
import 'package:locario/l10n/app_localizations.dart';
import '../../../../../shared/events/category_scope.dart';
import '../../../../explore/models.dart';
import '../../create_event_state.dart';
import '../form_primitives.dart';

class CreateEventCategoriesSection extends StatelessWidget {
  const CreateEventCategoriesSection({
    super.key,
    required this.state,
    required this.onCategoryToggled,
  });

  final CreateEventState state;
  final ValueChanged<Category> onCategoryToggled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final categoriesController = CategoryScope.maybeOf(context);
    final available = categoriesController?.categories ?? const [];
    final isLoading = categoriesController?.isLoading ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: double.infinity),
        Align(
          alignment: Alignment.centerLeft,
          child: CreateEventFieldLabel(text: l10n.hubCreateEventCategoryLabel),
        ),
        const SizedBox(height: 8),
        if (isLoading && available.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: LinearProgressIndicator(),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: Wrap(
            alignment: WrapAlignment.start,
            spacing: 8,
            runSpacing: 8,
            children: [
              if (available.isEmpty)
                FilterChip(
                  label: const Text('Dowolna'),
                  selected: state.selectedCategories.isEmpty,
                  onSelected: (_) {},
                ),
              ...available.map((category) {
                final isSelected = state.selectedCategories.contains(category);
                return FilterChip(
                  label: Text(category.name),
                  selected: isSelected,
                  onSelected: (_) => onCategoryToggled(category),
                );
              }),
            ],
          ),
        ),
        if (state.categoriesError != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 12),
            child: Text(
              state.categoriesError!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }
}
