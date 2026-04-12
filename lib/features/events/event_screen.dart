import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:locario/l10n/app_localizations.dart';

import '../../shared/events/event_repository.dart';
import '../explore/models.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({super.key, this.eventId, EventRepository? eventRepository})
    : _eventRepository = eventRepository;

  final String? eventId;
  final EventRepository? _eventRepository;

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  late final EventRepository _eventRepository;
  AppLocalizations? _l10n;
  bool _hasRequestedInitialLoad = false;

  bool _isLoading = true;
  String? _error;
  ExploreEvent? _event;

  @override
  void initState() {
    super.initState();
    _eventRepository = widget._eventRepository ?? HttpEventRepository();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _l10n ??= AppLocalizations.of(context)!;
    if (_hasRequestedInitialLoad) {
      return;
    }

    _hasRequestedInitialLoad = true;
    _loadEvent();
  }

  Future<void> _loadEvent() async {
    final l10n = _l10n ?? AppLocalizations.of(context)!;
    final eventId = widget.eventId;
    if (eventId == null || eventId.isEmpty) {
      setState(() {
        _isLoading = false;
        _error = 'missing-id';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final event = await _eventRepository.fetchEvent(eventId, l10n);
      if (!mounted) {
        return;
      }

      setState(() {
        _event = event;
        _isLoading = false;
      });
    } on EventRepositoryException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _error = error.message;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _error = 'unknown';
        _isLoading = false;
      });
    }
  }

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
      body: _buildBody(context, l10n),
    );
  }

  Widget _buildBody(BuildContext context, AppLocalizations l10n) {
    if (_isLoading) {
      return _EventStateView(
        icon: Icons.hourglass_top_rounded,
        title: l10n.eventDetailsLoadingTitle,
        subtitle: l10n.eventDetailsLoadingSubtitle,
        trailing: const Padding(
          padding: EdgeInsets.only(top: 12),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null || _event == null) {
      return _EventStateView(
        icon: Icons.wifi_tethering_error_rounded,
        title: l10n.eventDetailsErrorTitle,
        subtitle: l10n.eventDetailsErrorSubtitle,
        trailing: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: FilledButton(
            onPressed: _loadEvent,
            child: Text(l10n.exploreRetryButton),
          ),
        ),
      );
    }

    final event = _event!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final imageWidth = math.min(MediaQuery.sizeOf(context).width - 40, 360.0);
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
                  _InfoCard(
                    label: l10n.eventDetailsTitleLabel,
                    value: event.title,
                  ),
                  const SizedBox(height: 12),
                  _InfoCard(
                    label: l10n.eventDetailsLocationLabel,
                    value: event.locationLabel(l10n),
                    icon: Icons.place_outlined,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _InfoCard(
                          label: l10n.eventDetailsDateLabel,
                          value: _formatDate(event.startsAt.toLocal()),
                          icon: Icons.calendar_month_rounded,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _InfoCard(
                          label: l10n.eventDetailsTimeLabel,
                          value: _formatTime(event.startsAt.toLocal()),
                          icon: Icons.schedule_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _InfoCard(
                    label: l10n.eventDetailsAboutLabel,
                    value:
                        (event.description == null ||
                            event.description!.isEmpty)
                        ? l10n.eventDetailsFallbackDescription
                        : event.description!,
                    icon: Icons.info_outline_rounded,
                    multiline: true,
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
                    child: Text(l10n.eventDetailsJoinButton),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
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
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: multiline ? null : 3,
            overflow: multiline ? null : TextOverflow.ellipsis,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: scheme.onSurface,
              height: multiline ? 1.4 : null,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EventStateView extends StatelessWidget {
  const _EventStateView({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

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
            ?trailing,
          ],
        ),
      ),
    );
  }
}
