import 'package:flutter/material.dart';
import 'package:locario/l10n/app_localizations.dart';

import '../explore/models.dart';

class EventScreen extends StatelessWidget {
  const EventScreen({super.key, this.eventId});

  final String? eventId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final selectedEvent = eventId == null
        ? null
        : buildExploreEvents(
            l10n,
          ).where((event) => event.id == eventId).firstOrNull;
    final eventTitle = selectedEvent?.title ?? 'Unknown event';

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        title: const Text('Event details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              eventTitle,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              eventId == null
                  ? 'No eventId passed in route.'
                  : 'eventId: $eventId',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.78),
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}
