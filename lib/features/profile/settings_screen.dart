import 'package:flutter/material.dart';
import 'package:locario/l10n/app_localizations.dart';
import 'package:locario/shared/notifications/notification_scope.dart';
import 'package:locario/shared/notifications/notification_type.dart';

import '../../app/locale/locale_scope.dart';
import '../../app/theme/theme_scope.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final localeController = LocaleScope.of(context);
    final themeController = ThemeScope.of(context);
    final notificationController = NotificationScope.of(context);

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        titleSpacing: 8,
        leadingWidth: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16, top: 6, bottom: 6),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              shape: BoxShape.circle,
              border: Border.all(color: scheme.outline.withValues(alpha: 0.18)),
            ),
            child: IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: scheme.primary,
                size: 18,
              ),
            ),
          ),
        ),
        title: Text(
          l10n.settingsScreenTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            color: scheme.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        children: [
          _SettingsSection(
            title: l10n.languageSectionTitle,
            subtitle: l10n.languageSectionSubtitle,
            child: SegmentedButton<Locale>(
              key: const Key('settings-language-segmented'),
              showSelectedIcon: false,
              segments: [
                ButtonSegment<Locale>(
                  value: const Locale('pl'),
                  label: Text(l10n.localePolish),
                ),
                ButtonSegment<Locale>(
                  value: const Locale('en'),
                  label: Text(l10n.localeEnglish),
                ),
              ],
              selected: {localeController.locale},
              onSelectionChanged: (selection) {
                localeController.setLocale(selection.first);
              },
            ),
          ),
          const SizedBox(height: 14),
          _SettingsSection(
            title: l10n.themeSectionTitle,
            subtitle: l10n.themeSectionSubtitle,
            child: SegmentedButton<ThemeMode>(
              key: const Key('settings-theme-segmented'),
              showSelectedIcon: false,
              segments: [
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.system,
                  label: Text(l10n.themeModeSystem),
                ),
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.light,
                  label: Text(l10n.themeModeLight),
                ),
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.dark,
                  label: Text(l10n.themeModeDark),
                ),
              ],
              selected: {themeController.themeMode},
              onSelectionChanged: (selection) {
                themeController.setThemeMode(selection.first);
              },
            ),
          ),
          const SizedBox(height: 14),
          _SettingsSection(
            title: l10n.notificationSettingsTitle,
            subtitle: l10n.notificationSettingsSubtitle,
            child: Column(
              children: [
                for (final type in NotificationType.values)
                  _NotificationToggle(
                    type: type,
                    enabled: notificationController.isEnabled(type),
                    onChanged: (value) {
                      notificationController.setEnabled(type, value);
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _SettingsSection(
            title: 'Debug',
            subtitle: 'Tap to send a test notification after 3 seconds',
            child: FilledButton.icon(
              onPressed: () {
                final scheduled = notificationController.sendTestNotification();
                final messenger = ScaffoldMessenger.of(context);
                if (scheduled) {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Notification in 3s...'),
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 2),
                    ),
                  );
                } else {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Type is disabled in settings'),
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.notifications_active_rounded),
              label: const Text('Send test notification (3s)'),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationToggle extends StatelessWidget {
  const _NotificationToggle({
    required this.type,
    required this.enabled,
    required this.onChanged,
  });

  final NotificationType type;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: enabled
                  ? scheme.primary.withValues(alpha: 0.12)
                  : scheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              type.icon,
              color: enabled
                  ? scheme.primary
                  : scheme.onSurface.withValues(alpha: 0.38),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _notificationTypeName(l10n, type),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
                Text(
                  _notificationTypeDesc(l10n, type),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.56),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch.adaptive(value: enabled, onChanged: onChanged),
        ],
      ),
    );
  }

  String _notificationTypeName(AppLocalizations l10n, NotificationType type) {
    return switch (type) {
      NotificationType.upcomingEvent => l10n.notificationTypeUpcomingEvent,
      NotificationType.expiredEvent => l10n.notificationTypeExpiredEvent,
      NotificationType.eventPublished => l10n.notificationTypeEventPublished,
      NotificationType.systemMessage => l10n.notificationTypeSystemMessage,
    };
  }

  String _notificationTypeDesc(AppLocalizations l10n, NotificationType type) {
    return switch (type) {
      NotificationType.upcomingEvent => l10n.notificationTypeUpcomingEventDesc,
      NotificationType.expiredEvent => l10n.notificationTypeExpiredEventDesc,
      NotificationType.eventPublished =>
        l10n.notificationTypeEventPublishedDesc,
      NotificationType.systemMessage => l10n.notificationTypeSystemMessageDesc,
    };
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.28)),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor,
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.72),
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
