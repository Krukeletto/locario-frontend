import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:locario/l10n/app_localizations.dart';

import '../../shared/auth/auth_models.dart';
import '../../shared/auth/auth_scope.dart';
import '../../shared/events/event_repository.dart';
import '../../shared/widgets/state_panel.dart';
import '../explore/models.dart';

class EventHistoryScreen extends StatelessWidget {
  const EventHistoryScreen({super.key, EventRepository? eventRepository})
    : _eventRepository = eventRepository;

  final EventRepository? _eventRepository;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final sessionController = AuthScope.of(context);
    final profile = sessionController.profile;

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
          l10n.profileEventHistoryTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            color: scheme.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: sessionController.isLoading
          ? StatePanel.loading(
              title: l10n.profileEventHistoryTitle,
              subtitle: l10n.profileEventHistorySubtitle,
            )
          : profile == null || !sessionController.isAuthenticated
          ? StatePanel.empty(
              title: l10n.profileEventHistoryEmptyTitle,
              subtitle: l10n.profileEventHistoryEmptySubtitle,
            )
          : _HistoryContent(
              profile: profile,
              eventRepository: _eventRepository,
            ),
    );
  }
}

class _HistoryContent extends StatefulWidget {
  const _HistoryContent({required this.profile, this.eventRepository});

  final UserProfile profile;
  final EventRepository? eventRepository;

  @override
  State<_HistoryContent> createState() => _HistoryContentState();
}

class _HistoryContentState extends State<_HistoryContent> {
  late final EventRepository _eventRepository;
  final Map<String, Future<ExploreEvent?>> _eventFutures = {};

  @override
  void initState() {
    super.initState();
    _eventRepository = widget.eventRepository ?? HttpEventRepository();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final current = <ProfileEventSummary>[];
    final past = <ProfileEventSummary>[];
    final now = DateTime.now();

    for (final summary in widget.profile.eventRegistrations) {
      if (_isPast(summary, now)) {
        past.add(summary);
      } else {
        current.add(summary);
      }
    }

    current.sort((left, right) => left.startAt.compareTo(right.startAt));
    past.sort((left, right) => right.startAt.compareTo(left.startAt));

    if (current.isEmpty && past.isEmpty) {
      return StatePanel.empty(
        title: l10n.profileEventHistoryEmptyTitle,
        subtitle: l10n.profileEventHistoryEmptySubtitle,
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      children: [
        Text(
          l10n.profileEventHistorySubtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.72),
          ),
        ),
        if (current.isNotEmpty) ...[
          const SizedBox(height: 24),
          _SectionHeader(title: l10n.profileEventHistoryCurrentSectionTitle),
          const SizedBox(height: 14),
          ...current.map(
            (summary) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _HistoryEventCard(
                summary: summary,
                eventFuture: _eventFuture(summary.eventId),
                isPast: false,
              ),
            ),
          ),
        ],
        if (past.isNotEmpty) ...[
          const SizedBox(height: 24),
          _SectionHeader(title: l10n.profileEventHistoryPastSectionTitle),
          const SizedBox(height: 14),
          ...past.map(
            (summary) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _HistoryEventCard(
                summary: summary,
                eventFuture: _eventFuture(summary.eventId),
                isPast: true,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<ExploreEvent?> _eventFuture(String eventId) {
    return _eventFutures.putIfAbsent(eventId, () async {
      try {
        return await _eventRepository.fetchEvent(eventId);
      } catch (_) {
        return null;
      }
    });
  }

  bool _isPast(ProfileEventSummary summary, DateTime now) {
    final reference = summary.endAt ?? summary.startAt;
    return !reference.toLocal().isAfter(now.toLocal());
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        color: scheme.primary,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _HistoryEventCard extends StatelessWidget {
  const _HistoryEventCard({
    required this.summary,
    required this.eventFuture,
    required this.isPast,
  });

  final ProfileEventSummary summary;
  final Future<ExploreEvent?> eventFuture;
  final bool isPast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return FutureBuilder<ExploreEvent?>(
      future: eventFuture,
      builder: (context, snapshot) {
        final event = snapshot.data;
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final thumbnailUrl = event?.effectiveThumbnailUrl;
        final accentColor = (event?.accentColor ?? scheme.primary).withValues(
          alpha: isPast ? 0.72 : 1.0,
        );
        final icon = event?.icon ?? Icons.event_rounded;
        final titleColor = isPast ? scheme.onSurfaceVariant : scheme.primary;
        final bodyColor = scheme.onSurface.withValues(
          alpha: isPast ? 0.58 : 0.72,
        );
        final arrowColor = isPast ? scheme.onSurfaceVariant : scheme.primary;

        return InkWell(
          onTap: () => context.push('/events/${summary.eventId}'),
          borderRadius: BorderRadius.circular(28),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: scheme.outline.withValues(alpha: 0.28)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      clipBehavior: Clip.antiAlias,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: isLoading
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: scheme.primary,
                              ),
                            )
                          : thumbnailUrl == null
                          ? Icon(icon, color: accentColor, size: 26)
                          : ColorFiltered(
                              colorFilter: isPast
                                  ? const ColorFilter.matrix(<double>[
                                      0.2126,
                                      0.7152,
                                      0.0722,
                                      0,
                                      0,
                                      0.2126,
                                      0.7152,
                                      0.0722,
                                      0,
                                      0,
                                      0.2126,
                                      0.7152,
                                      0.0722,
                                      0,
                                      0,
                                      0,
                                      0,
                                      0,
                                      1,
                                      0,
                                    ])
                                  : const ColorFilter.mode(
                                      Colors.transparent,
                                      BlendMode.srcOver,
                                    ),
                              child: CachedNetworkImage(
                                imageUrl: thumbnailUrl,
                                width: 52,
                                height: 52,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  width: 52,
                                  height: 52,
                                  color: accentColor.withValues(alpha: 0.1),
                                  child: const Center(
                                    child: SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    Icon(icon, color: accentColor, size: 26),
                              ),
                            ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            summary.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: titleColor,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _formatDateLine(summary),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: bodyColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatTimeLine(summary),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: bodyColor,
                            ),
                          ),
                          if (event != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              event.categoryLabel(l10n),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: accentColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ] else if (summary.categoryNames.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              summary.categoryNames.join(' · '),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: bodyColor,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: arrowColor,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDateLine(ProfileEventSummary summary) {
    final start = summary.startAt.toLocal();
    final end = summary.endAt?.toLocal();
    final startDate = _formatDate(start);
    if (end == null) {
      return startDate;
    }

    final endDate = _formatDate(end);
    if (start.year == end.year &&
        start.month == end.month &&
        start.day == end.day) {
      return startDate;
    }

    return '$startDate - $endDate';
  }

  String _formatTimeLine(ProfileEventSummary summary) {
    final start = summary.startAt.toLocal();
    final end = summary.endAt?.toLocal();
    if (end == null) {
      return _formatTime(start);
    }

    return '${_formatTime(start)} - ${_formatTime(end)}';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
