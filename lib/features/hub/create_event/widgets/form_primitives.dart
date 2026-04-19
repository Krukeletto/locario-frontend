import 'package:flutter/material.dart';

import '../create_event_location_controller.dart';

class CreateEventSection extends StatelessWidget {
  const CreateEventSection({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.12)),
      ),
      child: child,
    );
  }
}

class CreateEventFieldLabel extends StatelessWidget {
  const CreateEventFieldLabel({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text,
      style: theme.textTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.w700,
        color: theme.colorScheme.primary.withValues(alpha: 0.8),
      ),
    );
  }
}

/// Returns a standardised [InputDecoration] for text fields in the create-event
/// form. Pass [errorText] to show validation feedback.
InputDecoration createEventFieldDecoration(
  BuildContext context, {
  required String hintText,
  String? errorText,
}) {
  final scheme = Theme.of(context).colorScheme;
  return InputDecoration(
    hintText: hintText,
    errorText: errorText,
    filled: true,
    fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );
}

/// Tappable tile used for date and time pickers.
class CreateEventPickerTile extends StatelessWidget {
  const CreateEventPickerTile({
    super.key,
    required this.value,
    required this.isPlaceholder,
    required this.onTap,
    this.errorText,
  });

  final String value;
  final bool isPlaceholder;
  final VoidCallback onTap;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
              border: errorText != null
                  ? Border.all(color: scheme.error)
                  : null,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: isPlaceholder
                          ? scheme.onSurface.withValues(alpha: 0.5)
                          : scheme.onSurface,
                    ),
                  ),
                ),
                Icon(
                  Icons.calendar_today_rounded,
                  size: 18,
                  color: scheme.primary.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 12),
            child: Text(
              errorText!,
              style: theme.textTheme.bodySmall?.copyWith(color: scheme.error),
            ),
          ),
      ],
    );
  }
}

/// Tappable tile for the location picker — shows an icon, label, and optional
/// description row, plus a loading state.
class CreateEventLocationPickerTile extends StatelessWidget {
  const CreateEventLocationPickerTile({
    super.key,
    required this.selection,
    required this.isLoading,
    required this.placeholder,
    required this.loadingLabel,
    this.loadingDescription,
    required this.onTap,
    this.errorText,
  });

  final CreateEventLocationSelection? selection;
  final bool isLoading;
  final String placeholder;
  final String loadingLabel;
  final String? loadingDescription;
  final VoidCallback onTap;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
              border: errorText != null
                  ? Border.all(color: scheme.error)
                  : null,
            ),
            child: Row(
              children: [
                Icon(Icons.location_on_rounded, color: scheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isLoading
                            ? loadingLabel
                            : (selection?.label ?? placeholder),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: selection == null && !isLoading
                              ? scheme.onSurface.withValues(alpha: 0.5)
                              : scheme.onSurface,
                        ),
                      ),
                      if (isLoading && loadingDescription != null)
                        Text(
                          loadingDescription!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurface.withValues(alpha: 0.6),
                          ),
                        )
                      else if (selection?.description != null)
                        Text(
                          selection!.description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                    ],
                  ),
                ),
                if (isLoading)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  const Icon(Icons.keyboard_arrow_right_rounded),
              ],
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 12),
            child: Text(
              errorText!,
              style: theme.textTheme.bodySmall?.copyWith(color: scheme.error),
            ),
          ),
      ],
    );
  }
}
