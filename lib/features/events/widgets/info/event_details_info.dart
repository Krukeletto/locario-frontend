import 'package:flutter/material.dart';
import 'package:locario/l10n/app_localizations.dart';
import '../../../explore/models.dart';
import '../../../../shared/events/event_slots_response.dart';
import './event_info_card.dart';

class EventDetailsInfo extends StatelessWidget {
  const EventDetailsInfo({
    super.key,
    required this.event,
    required this.overlap,
    required this.onShowOnMapPressed,
    required this.onSavePressed,
    required this.isSaved,
    required this.isJoined,
    this.onJoinPressed,
    this.onLeavePressed,
    this.slots,
    this.isJoinLoading = false,
  });

  final ExploreEvent event;
  final double overlap;
  final VoidCallback onShowOnMapPressed;
  final VoidCallback onSavePressed;
  final bool isSaved;
  final bool isJoined;
  final VoidCallback? onJoinPressed;
  final VoidCallback? onLeavePressed;
  final EventSlotsResponse? slots;
  final bool isJoinLoading;

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
    final l10n = AppLocalizations.of(context);

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
            if (slots != null) ...[
              const SizedBox(height: 12),
              EventInfoCard(
                label: l10n.eventDetailsSlotsLabel,
                value: slots!.slotLimit > 0
                    ? l10n.eventSlotsTaken(
                        slots!.registeredCount,
                        slots!.slotLimit,
                      )
                    : l10n.eventSlotsJoined(slots!.registeredCount),
                icon: Icons.people_outline_rounded,
              ),
              if (slots!.soldOut)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 14,
                        color: scheme.error,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.eventSlotsSoldOut,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.error,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              if (slots!.waitlistCount > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.horizontal_split_rounded,
                        size: 14,
                        color: scheme.tertiary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.eventSlotsWaitlist(slots!.waitlistCount),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.tertiary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ] else if (event.slotLimit != null && event.slotLimit! > 0) ...[
              const SizedBox(height: 12),
              EventInfoCard(
                label: l10n.eventDetailsSlotsLabel,
                value: l10n.eventDetailsSlotsValue(event.slotLimit!),
                icon: Icons.people_outline_rounded,
              ),
            ],
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onShowOnMapPressed,
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                backgroundColor: scheme.secondaryContainer,
                foregroundColor: scheme.onSecondaryContainer,
                textStyle: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              icon: const Icon(Icons.map_outlined, size: 20),
              label: Text(l10n.eventDetailsShowOnMapButton),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: onSavePressed,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                textStyle: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              icon: Icon(
                isSaved ? Icons.bookmark_rounded : Icons.bookmark_add_outlined,
                size: 20,
              ),
              label: Text(
                isSaved ? l10n.savedRemoveAction : l10n.savedSaveAction,
              ),
            ),
            if (isJoined) ...[
              const SizedBox(height: 10),
              FilledButton.tonalIcon(
                onPressed: isJoinLoading ? null : onLeavePressed,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  backgroundColor: scheme.errorContainer,
                  foregroundColor: scheme.onErrorContainer,
                  textStyle: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                icon: isJoinLoading
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: scheme.onErrorContainer,
                        ),
                      )
                    : const Icon(Icons.exit_to_app_rounded, size: 20),
                label: Text(l10n.eventDetailsLeaveButton),
              ),
            ] else ...[
              const SizedBox(height: 10),
              FilledButton(
                onPressed: isJoinLoading || onJoinPressed == null
                    ? null
                    : onJoinPressed,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  textStyle: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: isJoinLoading
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.colorScheme.onPrimary,
                        ),
                      )
                    : Text(l10n.eventDetailsJoinButton),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
