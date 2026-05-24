import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:locario/l10n/app_localizations.dart';

import '../../shared/auth/auth_scope.dart';
import '../../shared/auth/session_controller.dart';
import '../../shared/events/event_repository.dart';
import '../../shared/widgets/state_panel.dart';
import '../explore/models.dart';

class OrganizerEventsScreen extends StatefulWidget {
  const OrganizerEventsScreen({super.key, EventRepository? eventRepository})
    : _eventRepository = eventRepository;

  final EventRepository? _eventRepository;

  @override
  State<OrganizerEventsScreen> createState() => _OrganizerEventsScreenState();
}

class _OrganizerEventsScreenState extends State<OrganizerEventsScreen> {
  late final EventRepository _eventRepository;
  Future<List<ExploreEvent>?>? _future;
  SessionController? _sessionController;

  @override
  void initState() {
    super.initState();
    _eventRepository = widget._eventRepository ?? HttpEventRepository();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final sessionController = AuthScope.of(context);
    if (_sessionController != sessionController) {
      _sessionController?.removeListener(_sync);
      _sessionController = sessionController;
      _sessionController?.addListener(_sync);
      _future = null;
    }
    _sync();
  }

  @override
  void dispose() {
    _sessionController?.removeListener(_sync);
    super.dispose();
  }

  void _sync() {
    final sessionController = _sessionController;
    final profile = sessionController?.profile;
    if (sessionController == null ||
        profile == null ||
        !sessionController.isAuthenticated ||
        profile.organizer != true) {
      if (_future != null) {
        setState(() => _future = null);
      }
      return;
    }

    if (_future != null) {
      return;
    }

    setState(() {
      _future = _loadEvents(
        accessToken: sessionController.tokens?.accessToken,
        tokenType: sessionController.tokens?.tokenType ?? 'Bearer',
      );
    });
  }

  Future<List<ExploreEvent>?> _loadEvents({
    required String? accessToken,
    required String tokenType,
  }) async {
    try {
      if (accessToken == null || accessToken.isEmpty) {
        return null;
      }
      return await _eventRepository.fetchMyOrganizerEvents(
        accessToken: accessToken,
        tokenType: tokenType,
      );
    } catch (_) {
      return null;
    }
  }

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
          l10n.profileMyEventsTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            color: scheme.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: sessionController.isLoading
          ? StatePanel.loading(
              title: l10n.profileMyEventsTitle,
              subtitle: l10n.profileMyEventsSubtitle,
            )
          : !sessionController.isAuthenticated ||
                profile == null ||
                profile.organizer != true
          ? StatePanel.empty(
              title: l10n.profileMyEventsTitle,
              subtitle: l10n.profileMyEventsSubtitle,
            )
          : _buildContent(l10n),
    );
  }

  Widget _buildContent(AppLocalizations l10n) {
    final future = _future;
    if (future == null) {
      return StatePanel.loading(
        title: l10n.profileMyEventsTitle,
        subtitle: l10n.profileMyEventsSubtitle,
      );
    }

    return FutureBuilder<List<ExploreEvent>?>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return StatePanel.loading(
            title: l10n.profileMyEventsTitle,
            subtitle: l10n.profileMyEventsSubtitle,
          );
        }

        final events = snapshot.data;
        if (events == null) {
          return StatePanel.empty(
            title: l10n.profileMyEventsTitle,
            subtitle: l10n.profileMyEventsSubtitle,
            customContent: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: FilledButton(
                onPressed: _sync,
                child: Text(l10n.exploreRetryButton),
              ),
            ),
          );
        }

        final currentEvents = <ExploreEvent>[];
        final pastEvents = <ExploreEvent>[];
        final now = DateTime.now();

        for (final event in events) {
          if (_isPast(event, now)) {
            pastEvents.add(event);
          } else {
            currentEvents.add(event);
          }
        }

        currentEvents.sort((left, right) {
          return left.startsAt.compareTo(right.startsAt);
        });

        if (currentEvents.isEmpty) {
          return StatePanel.empty(
            title: l10n.profileMyEventsTitle,
            subtitle: l10n.profileMyEventsSubtitle,
          );
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
          children: [
            Text(
              l10n.profileMyEventsSubtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.72),
              ),
            ),
            const SizedBox(height: 24),
            _SectionHeader(title: l10n.profileEventHistoryCurrentSectionTitle),
            const SizedBox(height: 14),
            ...currentEvents.map(
              (event) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _OrganizerEventCard(event: event),
              ),
            ),
          ],
        );
      },
    );
  }

  bool _isPast(ExploreEvent event, DateTime now) {
    final reference = event.endsAt ?? event.startsAt;
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

class _OrganizerEventCard extends StatelessWidget {
  const _OrganizerEventCard({required this.event});

  final ExploreEvent event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final accentColor = event.accentColor;
    final thumbnailUrl = event.effectiveThumbnailUrl;
    final titleColor = scheme.primary;
    final bodyColor = scheme.onSurface.withValues(alpha: 0.72);
    final arrowColor = scheme.primary;

    return InkWell(
      onTap: () => context.push('/events/${event.id}'),
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
                  child: thumbnailUrl == null
                      ? Icon(event.icon, color: accentColor, size: 26)
                      : CachedNetworkImage(
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
                              Icon(event.icon, color: accentColor, size: 26),
                        ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: titleColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _formatDateLine(event),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: bodyColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatTimeLine(event),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: bodyColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        event.categoryLabel(l10n),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: accentColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
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
  }

  String _formatDateLine(ExploreEvent event) {
    final start = event.startsAt.toLocal();
    final end = event.endsAt?.toLocal();
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

  String _formatTimeLine(ExploreEvent event) {
    final start = event.startsAt.toLocal();
    final end = event.endsAt?.toLocal();
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
