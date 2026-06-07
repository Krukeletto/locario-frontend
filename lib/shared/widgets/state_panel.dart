import 'package:flutter/material.dart';

class StatePanel extends StatelessWidget {
  const StatePanel._({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.customContent,
  });

  factory StatePanel.loading({
    Key? key,
    IconData icon = Icons.hourglass_top_rounded,
    required String title,
    required String subtitle,
  }) {
    return StatePanel._(
      key: key,
      icon: icon,
      title: title,
      subtitle: subtitle,
      trailing: const Padding(
        padding: EdgeInsets.only(top: 12),
        child: CircularProgressIndicator(),
      ),
    );
  }

  factory StatePanel.error({
    Key? key,
    IconData icon = Icons.wifi_tethering_error_rounded,
    required String title,
    required String subtitle,
    required String retryLabel,
    VoidCallback? onRetry,
  }) {
    return StatePanel._(
      key: key,
      icon: icon,
      title: title,
      subtitle: subtitle,
      trailing: onRetry != null
          ? Padding(
              padding: const EdgeInsets.only(top: 12),
              child: FilledButton(onPressed: onRetry, child: Text(retryLabel)),
            )
          : null,
    );
  }

  factory StatePanel.empty({
    Key? key,
    IconData icon = Icons.event_busy_rounded,
    required String title,
    required String subtitle,
    Widget? customContent,
  }) {
    return StatePanel._(
      key: key,
      icon: icon,
      title: title,
      subtitle: subtitle,
      customContent: customContent,
    );
  }

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final Widget? customContent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final custom = customContent;
    final trail = trailing;

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
              child: Icon(icon, size: 34, color: scheme.primary),
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
            if (custom != null) ...[const SizedBox(height: 16), custom],
            if (trail != null) ...[trail],
          ],
        ),
      ),
    );
  }
}
