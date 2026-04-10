import 'package:flutter/material.dart';
import 'package:locario/l10n/app_localizations.dart';

import '../../app/app_locale_scope.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final localeController = AppLocaleScope.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8EF),
        surfaceTintColor: Colors.transparent,
        title: Text(l10n.settingsScreenTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          Text(
            l10n.settingsScreenDescription,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.72),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: scheme.outline.withValues(alpha: 0.28)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.languageSectionTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.languageSectionSubtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.72),
                  ),
                ),
                const SizedBox(height: 14),
                SegmentedButton<Locale>(
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
