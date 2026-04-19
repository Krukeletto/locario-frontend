import 'package:flutter/material.dart';

class EventInfoCard extends StatelessWidget {
  const EventInfoCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.multiline = false,
  });

  final String label;
  final String value;
  final IconData? icon;
  final bool multiline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: scheme.primary),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: multiline ? null : 3,
            overflow: multiline ? null : TextOverflow.ellipsis,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: scheme.onSurface,
              height: multiline ? 1.4 : null,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
