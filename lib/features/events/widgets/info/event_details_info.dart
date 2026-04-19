import 'package:flutter/material.dart';
import 'package:locario/l10n/app_localizations.dart';
import '../../../explore/models.dart';
import './event_info_card.dart';

class EventDetailsInfo extends StatelessWidget {
  const EventDetailsInfo({
    super.key,
    required this.event,
    required this.overlap,
    required this.onJoinPressed,
  });

  final ExploreEvent event;
  final double overlap;
  final VoidCallback onJoinPressed;

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day.$month.${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Transform.translate(
      offset: Offset(0, -overlap),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: scheme.outline.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: theme.brightness == Brightness.dark ? 0.2 : 0.05,
              ),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EventInfoCard(
              label: l10n.eventDetailsTitleLabel,
              value: event.title,
            ),
            const SizedBox(height: 12),
            EventInfoCard(
              label: l10n.eventDetailsLocationLabel,
              value: event.locationLabel(l10n),
              icon: Icons.place_outlined,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: EventInfoCard(
                    label: l10n.eventDetailsDateLabel,
                    value: _formatDate(event.startsAt.toLocal()),
                    icon: Icons.calendar_month_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: EventInfoCard(
                    label: l10n.eventDetailsTimeLabel,
                    value: _formatTime(event.startsAt.toLocal()),
                    icon: Icons.schedule_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            EventInfoCard(
              label: l10n.eventDetailsAboutLabel,
              value: (event.description == null || event.description!.isEmpty)
                  ? l10n.eventDetailsFallbackDescription
                  : event.description!,
              icon: Icons.info_outline_rounded,
              multiline: true,
            ),
            if (event.ticketUrl != null && event.ticketUrl!.isNotEmpty) ...[
              const SizedBox(height: 12),
              EventInfoCard(
                label: l10n.eventDetailsTicketLabel,
                value: event.ticketUrl!,
                icon: Icons.confirmation_number_outlined,
              ),
            ],
            if (event.slotLimit != null) ...[
              const SizedBox(height: 12),
              EventInfoCard(
                label: l10n.eventDetailsSlotsLabel,
                value: l10n.eventDetailsSlotsValue(event.slotLimit!),
                icon: Icons.people_outline_rounded,
              ),
            ],
            const SizedBox(height: 18),
            FilledButton(
              onPressed: onJoinPressed,
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                textStyle: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: Text(l10n.eventDetailsJoinButton),
            ),
          ],
        ),
      ),
    );
  }
}
