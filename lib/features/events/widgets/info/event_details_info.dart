import 'package:flutter/material.dart';
import 'package:locario/l10n/app_localizations.dart';
import '../../../explore/models.dart';
import '../../../../shared/events/event_slots_response.dart';
import '../../../../shared/reviews/review_formatters.dart';
import '../../../../shared/reviews/review_models.dart';
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
    this.organizerRating,
    this.onJoinPressed,
    this.onLeavePressed,
    this.onAddToCalendarPressed,
    this.slots,
    this.isJoinLoading = false,
  });

  final ExploreEvent event;
  final double overlap;
  final VoidCallback onShowOnMapPressed;
  final VoidCallback onSavePressed;
  final bool isSaved;
  final bool isJoined;
  final AverageRating? organizerRating;
  final VoidCallback? onJoinPressed;
  final VoidCallback? onLeavePressed;
  final VoidCallback? onAddToCalendarPressed;
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

  bool _isSameCalendarDay(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }

  String? _validatedTicketUrl(String? url) {
    final trimmed = url?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }

    final uri = Uri.tryParse(trimmed);
    if (uri == null ||
        !uri.hasScheme ||
        !uri.hasAuthority ||
        uri.host.isEmpty) {
      return null;
    }

    if (uri.scheme != 'http' && uri.scheme != 'https') {
      return null;
    }

    return trimmed;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final showActionButtons = !event.hasEnded;
    final ticketUrl = _validatedTicketUrl(event.ticketUrl);

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
              color: theme.shadowColor,
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
            if (event.organizerUsername != null || event.createdAt != null) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (event.organizerUsername != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.person_outline_rounded,
                          size: 14,
                          color: scheme.onSurface.withValues(alpha: 0.68),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          event.organizerUsername!,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: scheme.onSurface.withValues(alpha: 0.68),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  if (event.createdAt != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 14,
                          color: scheme.onSurface.withValues(alpha: 0.52),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatCardTimestamp(event.createdAt!),
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: scheme.onSurface.withValues(alpha: 0.52),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            EventInfoCard(
              label: l10n.eventDetailsLocationLabel,
              value: event.locationLabel(l10n),
              icon: Icons.place_outlined,
            ),
            if (organizerRating != null) ...[
              const SizedBox(height: 12),
              EventInfoCard(
                label: l10n.eventOrganizerRatingLabel,
                value: organizerRating!.hasReviews
                    ? l10n.eventOrganizerRatingValue(
                        formatReviewAverage(organizerRating!.averageRating),
                        organizerRating!.totalReviews,
                      )
                    : l10n.eventOrganizerRatingEmpty,
                icon: Icons.star_rounded,
              ),
            ],
            const SizedBox(height: 12),
            EventInfoCard(
              label: l10n.eventDetailsDateLabel,
              value: _formatDate(event.startsAt.toLocal()),
              icon: Icons.calendar_month_rounded,
            ),
            if (event.endsAt != null &&
                !_isSameCalendarDay(
                  event.startsAt.toLocal(),
                  event.endsAt!.toLocal(),
                )) ...[
              const SizedBox(height: 12),
              EventInfoCard(
                label: l10n.eventDetailsEndDateLabel,
                value: _formatDate(event.endsAt!.toLocal()),
                icon: Icons.calendar_month_rounded,
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: EventInfoCard(
                    label: l10n.eventDetailsStartTimeLabel,
                    value: _formatTime(event.startsAt.toLocal()),
                    icon: Icons.schedule_rounded,
                  ),
                ),
                if (event.endsAt != null) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: EventInfoCard(
                      label: l10n.eventDetailsEndTimeLabel,
                      value: _formatTime(event.endsAt!.toLocal()),
                      icon: Icons.schedule_rounded,
                    ),
                  ),
                ],
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
            if (ticketUrl != null) ...[
              const SizedBox(height: 12),
              EventInfoCard(
                label: l10n.eventDetailsTicketLabel,
                value: ticketUrl,
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
            if (showActionButtons) ...[
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
                  isSaved
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_add_outlined,
                  size: 20,
                ),
                label: Text(
                  isSaved ? l10n.savedRemoveAction : l10n.savedSaveAction,
                ),
              ),
              if (isJoined) ...[
                const SizedBox(height: 10),
                FilledButton.tonalIcon(
                  onPressed: isJoinLoading || onAddToCalendarPressed == null
                      ? null
                      : onAddToCalendarPressed,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    textStyle: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  icon: const Icon(Icons.calendar_month_rounded, size: 20),
                  label: Text(l10n.eventDetailsAddToCalendarButton),
                ),
              ],
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
          ],
        ),
      ),
    );
  }

  String _formatCardTimestamp(DateTime date) {
    final local = date.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day.$month.$year, $hour:$minute';
  }
}
