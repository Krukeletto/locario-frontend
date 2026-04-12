import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:locario/l10n/app_localizations.dart';

import '../explore/models.dart';

class EventScreen extends StatelessWidget {
  const EventScreen({super.key, this.eventId});

  final String? eventId;

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

  _EventDetailsData _detailsFor(AppLocalizations l10n, String? id) {
    return switch (id) {
      'jazz-botanical-garden' => _EventDetailsData(
        description: l10n.eventDetailsJazzDescription,
        organizer: 'Lodz Jazz Collective',
        hasTickets: true,
        ticketPrice: '49 PLN',
        seats: '120',
      ),
      'night-sketching-vistula' => _EventDetailsData(
        description: l10n.eventDetailsSketchingDescription,
        organizer: 'Urban Sketchers PL',
        hasTickets: false,
        ticketPrice: '-',
        seats: '-',
      ),
      'run-club-coffee-stop' => _EventDetailsData(
        description: l10n.eventDetailsRunClubDescription,
        organizer: 'Morning Miles Club',
        hasTickets: false,
        ticketPrice: '-',
        seats: '-',
      ),
      'street-food-vinyl-market' => _EventDetailsData(
        description: l10n.eventDetailsStreetFoodDescription,
        organizer: 'City Flavor Team',
        hasTickets: true,
        ticketPrice: '25 PLN',
        seats: '300',
      ),
      _ => _EventDetailsData(
        description: l10n.eventDetailsFallbackDescription,
        organizer: 'Locario Community',
        hasTickets: false,
        ticketPrice: '-',
        seats: '-',
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final event = eventId == null
        ? null
        : buildExploreEvents(
            l10n,
          ).where((event) => event.id == eventId).firstOrNull;
    final details = _detailsFor(l10n, event?.id);

    final eventTitle = event?.title ?? l10n.eventDetailsUnknownEventTitle;
    final eventLocation = event?.venue ?? l10n.eventDetailsUnknownLocation;
    final eventDate = event == null ? '-' : _formatDate(event.startsAt);
    final eventTime = event == null ? '-' : _formatTime(event.startsAt);

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
          l10n.eventDetailsScreenTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            color: scheme.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final imageWidth = math.min(constraints.maxWidth - 40, 360.0);
          final imageHeight = imageWidth;
          const imageTopOffset = 8.0;
          const overlap = 34.0;

          return Stack(
            children: [
              Positioned(
                top: imageTopOffset,
                left: 0,
                right: 0,
                child: Center(
                  child: SizedBox(
                    width: imageWidth,
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: scheme.outline.withValues(alpha: 0.22),
                          ),
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_outlined,
                                  size: 44,
                                  color: scheme.primary,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  l10n.eventDetailsImagePlaceholder,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: scheme.onSurface,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              ListView(
                padding: EdgeInsets.fromLTRB(
                  20,
                  imageTopOffset + imageHeight - overlap,
                  20,
                  28,
                ),
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: scheme.outline.withValues(alpha: 0.2),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: theme.brightness == Brightness.dark
                                ? 0.2
                                : 0.05,
                          ),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _InfoBlock(
                          label: l10n.eventDetailsTitleLabel,
                          value: eventTitle,
                        ),
                        const SizedBox(height: 12),
                        _InfoBlock(
                          label: l10n.eventDetailsLocationLabel,
                          value: eventLocation,
                          icon: Icons.place_outlined,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _InfoBlock(
                                label: l10n.eventDetailsDateLabel,
                                value: eventDate,
                                icon: Icons.calendar_month_rounded,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _InfoBlock(
                                label: l10n.eventDetailsTimeLabel,
                                value: eventTime,
                                icon: Icons.schedule_rounded,
                              ),
                            ),
                          ],
                        ),
                        if (details.hasTickets) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _InfoBlock(
                                  label: l10n.eventDetailsPriceLabel,
                                  value: details.ticketPrice,
                                  icon: Icons.sell_outlined,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _InfoBlock(
                                  label: l10n.eventDetailsSeatsLabel,
                                  value: details.seats,
                                  icon: Icons.event_seat_outlined,
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 12),
                        _InfoBlock(
                          label: l10n.eventDetailsAboutLabel,
                          value: details.description,
                          icon: Icons.info_outline_rounded,
                          multiline: true,
                        ),
                        const SizedBox(height: 12),
                        _InfoBlock(
                          label: l10n.eventDetailsOrganizerLabel,
                          value: details.organizer,
                          icon: Icons.groups_2_outlined,
                        ),
                        const SizedBox(height: 14),
                        InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {},
                          child: Ink(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 13,
                            ),
                            decoration: BoxDecoration(
                              color: scheme.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: scheme.outline.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  color: scheme.primary,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    l10n.eventDetailsChatLabel,
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  color: scheme.secondary,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        FilledButton(
                          onPressed: () {},
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                            textStyle: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          child: Text(
                            details.hasTickets
                                ? l10n.eventDetailsBuyTicketButton
                                : l10n.eventDetailsJoinButton,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({
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

    return Column(
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
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: scheme.outline.withValues(alpha: 0.18)),
          ),
          child: Text(
            value,
            maxLines: multiline ? null : 2,
            overflow: multiline ? null : TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface,
              height: multiline ? 1.35 : null,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _EventDetailsData {
  const _EventDetailsData({
    required this.description,
    required this.organizer,
    required this.hasTickets,
    required this.ticketPrice,
    required this.seats,
  });

  final String description;
  final String organizer;
  final bool hasTickets;
  final String ticketPrice;
  final String seats;
}
