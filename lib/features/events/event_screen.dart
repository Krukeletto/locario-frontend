import 'package:flutter/material.dart';
import 'package:locario/l10n/app_localizations.dart';

import '../../shared/events/event_repository.dart';
import '../../shared/services/share_service.dart';
import '../../shared/widgets/state_panel.dart';
import '../explore/models.dart';
import 'widgets/gallery/event_details_gallery.dart';
import 'widgets/info/event_details_info.dart';

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
      final event = await _eventRepository.fetchEvent(eventId);
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

  void _shareEvent(ExploreEvent event) {
    final l10n = AppLocalizations.of(context)!;
    ShareService.shareEvent(eventId: event.id, title: event.title, l10n: l10n);
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
        actions: [
          if (_event != null)
            IconButton(
              icon: Icon(Icons.share_rounded, size: 20, color: scheme.primary),
              onPressed: () => _shareEvent(_event!),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildBody(context, l10n),
    );
  }

  Widget _buildBody(BuildContext context, AppLocalizations l10n) {
    if (_isLoading) {
      return StatePanel.loading(
        title: l10n.eventDetailsLoadingTitle,
        subtitle: l10n.eventDetailsLoadingSubtitle,
      );
    }

    if (_error != null || _event == null) {
      return StatePanel.error(
        title: l10n.eventDetailsErrorTitle,
        subtitle: l10n.eventDetailsErrorSubtitle,
        retryLabel: l10n.exploreRetryButton,
        onRetry: _loadEvent,
      );
    }

    final event = _event!;
    const overlap = 12.0;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: EventDetailsGallery(event: event)),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
          sliver: SliverToBoxAdapter(
            child: EventDetailsInfo(
              event: event,
              overlap: overlap,
              onJoinPressed: () {},
            ),
          ),
        ),
      ],
    );
  }
}
