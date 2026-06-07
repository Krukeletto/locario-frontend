import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:locario/l10n/app_localizations.dart';

import '../../shared/auth/auth_scope.dart';
import '../../shared/events/event_detail_controller.dart';
import '../../shared/events/event_detail_scope.dart';
import '../../shared/services/calendar_service.dart';
import '../../shared/reviews/review_controller.dart';
import '../../shared/reviews/review_scope.dart';
import '../../shared/services/feedback_service.dart';
import '../../shared/services/map_launch_service.dart';
import '../../shared/services/share_service.dart';
import '../../shared/widgets/state_panel.dart';
import '../explore/models.dart';
import '../saved/saved_events_controller.dart';
import '../saved/saved_events_scope.dart';
import 'joined_events_controller.dart';
import 'joined_events_scope.dart';
import 'widgets/gallery/event_details_gallery.dart';
import 'widgets/info/event_details_info.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({super.key, this.eventId, CalendarService? calendarService})
    : _calendarService = calendarService;

  final String? eventId;
  final CalendarService? _calendarService;

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  late final CalendarService _calendarService;
  bool _hasRequestedInitialLoad = false;
  bool _hasRequestedRatingLoad = false;
  bool _invalidEventId = false;

  bool _isJoinLoading = false;

  @override
  void initState() {
    super.initState();
    _calendarService = widget._calendarService ?? CalendarService();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasRequestedInitialLoad) return;
    _hasRequestedInitialLoad = true;
    _loadEvent();
  }

  void _loadEvent() {
    final eventId = widget.eventId;
    if (eventId == null || eventId.isEmpty) {
      _invalidEventId = true;
      return;
    }
    EventDetailScope.of(context).loadEvent(eventId);
  }

  void _shareEvent(ExploreEvent event) {
    final l10n = AppLocalizations.of(context);
    ShareService.shareEvent(eventId: event.id, title: event.title, l10n: l10n);
  }

  Future<void> _toggleSaved(ExploreEvent event) async {
    final controller = SavedEventsScope.maybeOf(context);
    if (controller == null) return;

    final wasSaved = controller.isSaved(event.id);
    final outcome = await controller.toggleSaved(event);
    if (!mounted) return;

    if (outcome == SavedToggleOutcome.failed) {
      FeedbackService.showError(FeedbackMessage.networkError);
      return;
    }

    if (outcome == SavedToggleOutcome.saved && !wasSaved) {
      FeedbackService.showSuccess(FeedbackMessage.eventSaveSuccess);
      return;
    }

    FeedbackService.showSuccess(FeedbackMessage.eventRemoveSuccess);
  }

  Future<void> _joinEvent(ExploreEvent event) async {
    final joinedController = JoinedEventsScope.maybeOf(context);
    if (joinedController == null) return;

    final auth = AuthScope.maybeOf(context);
    if (auth == null || !auth.isAuthenticated) {
      if (!mounted) return;
      await context.push('/auth/login');
      return;
    }

    setState(() => _isJoinLoading = true);

    try {
      await joinedController.joinEvent(event);
      if (!mounted) return;
      FeedbackService.showSuccess(FeedbackMessage.eventJoinSuccess);
      await _promptCalendarAdd(event);
    } catch (e) {
      if (!mounted) return;
      FeedbackService.showError(FeedbackMessage.eventJoinError);
    } finally {
      if (mounted) setState(() => _isJoinLoading = false);
    }
  }

  Future<void> _leaveEvent(ExploreEvent event) async {
    final joinedController = JoinedEventsScope.maybeOf(context);
    if (joinedController == null) return;

    setState(() => _isJoinLoading = true);

    try {
      await joinedController.cancelRegistration(event.id);
      if (!mounted) return;
      FeedbackService.showSuccess(FeedbackMessage.eventLeaveSuccess);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to leave event'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isJoinLoading = false);
    }
  }

  Future<void> _showEventOnMap(ExploreEvent event) async {
    final l10n = AppLocalizations.of(context);
    final opened = await MapLaunchService.openLocation(event.location);
    if (opened || !mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.eventDetailsOpenMapError),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _openReviewScreen(ExploreEvent event) async {
    if (!mounted) return;
    await context.push('/events/${event.id}/review');
  }

  Future<void> _addEventToCalendar(ExploreEvent event) async {
    final added = await _calendarService.addEvent(event);
    if (!mounted) {
      return;
    }

    if (added) {
      FeedbackService.showSuccess(FeedbackMessage.eventAddToCalendarSuccess);
      return;
    }

    FeedbackService.showError(FeedbackMessage.eventAddToCalendarError);
  }

  Future<void> _promptCalendarAdd(ExploreEvent event) async {
    final l10n = AppLocalizations.of(context);
    final shouldAdd = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(Icons.calendar_month_rounded),
          title: Text(l10n.eventCalendarPromptTitle),
          content: Text(l10n.eventCalendarPromptBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.eventCalendarPromptLater),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.eventCalendarPromptAddNow),
            ),
          ],
        );
      },
    );

    if (shouldAdd != true || !mounted) {
      return;
    }

    await _addEventToCalendar(event);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final savedController = SavedEventsScope.maybeOf(context);
    final joinedController = JoinedEventsScope.maybeOf(context);
    final detailController = EventDetailScope.of(context);
    final reviewController = ReviewScope.of(context);

    final event = detailController.event;
    if (event != null && !_hasRequestedRatingLoad) {
      _hasRequestedRatingLoad = true;
      final organizerId = event.organizerId;
      if (organizerId != null && organizerId.isNotEmpty) {
        reviewController.loadOrganizerRating(organizerId);
      }
    }

    return AnimatedBuilder(
      animation: Listenable.merge([?savedController, ?joinedController]),
      builder: (context, _) => _buildScaffold(
        context,
        theme,
        scheme,
        l10n,
        savedController,
        joinedController,
        detailController,
        reviewController,
      ),
    );
  }

  Scaffold _buildScaffold(
    BuildContext context,
    ThemeData theme,
    ColorScheme scheme,
    AppLocalizations l10n,
    SavedEventsController? savedController,
    JoinedEventsController? joinedController,
    EventDetailController detailController,
    ReviewController reviewController,
  ) {
    final event = detailController.event;

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
          if (event != null)
            IconButton(
              icon: Icon(Icons.share_rounded, size: 20, color: scheme.primary),
              onPressed: () => _shareEvent(event),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildBody(
        context,
        l10n,
        savedController,
        joinedController,
        detailController,
        reviewController,
      ),
      floatingActionButton: _buildReviewAction(context, l10n, event),
    );
  }

  Widget? _buildReviewAction(
    BuildContext context,
    AppLocalizations l10n,
    ExploreEvent? event,
  ) {
    if (event == null || !event.hasEnded) {
      return null;
    }

    final auth = AuthScope.maybeOf(context);
    final joinedController = JoinedEventsScope.maybeOf(context);
    final canReview =
        auth?.isAuthenticated == true &&
        joinedController?.isJoined(event.id) == true &&
        event.organizerId != null &&
        event.organizerId!.isNotEmpty;

    if (!canReview) {
      return null;
    }

    return FloatingActionButton.extended(
      onPressed: () => _openReviewScreen(event),
      icon: const Icon(Icons.rate_review_outlined),
      label: Text(l10n.eventDetailsReviewButton),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AppLocalizations l10n,
    SavedEventsController? savedController,
    JoinedEventsController? joinedController,
    EventDetailController detailController,
    ReviewController reviewController,
  ) {
    if (_invalidEventId || detailController.error != null) {
      return StatePanel.error(
        title: l10n.eventDetailsErrorTitle,
        subtitle: l10n.eventDetailsErrorSubtitle,
        retryLabel: l10n.exploreRetryButton,
        onRetry: _loadEvent,
      );
    }

    if (detailController.isLoading) {
      return StatePanel.loading(
        title: l10n.eventDetailsLoadingTitle,
        subtitle: l10n.eventDetailsLoadingSubtitle,
      );
    }

    final event = detailController.event;
    if (event == null) {
      return const SizedBox.shrink();
    }

    const overlap = 12.0;
    final isJoined = joinedController?.isJoined(event.id) ?? false;

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
              onShowOnMapPressed: () => _showEventOnMap(event),
              onSavePressed: () => _toggleSaved(event),
              isSaved: savedController?.isSaved(event.id) ?? false,
              isJoined: isJoined,
              organizerRating: reviewController.organizerRating,
              onJoinPressed: isJoined ? null : () => _joinEvent(event),
              onLeavePressed: isJoined ? () => _leaveEvent(event) : null,
              onAddToCalendarPressed: isJoined
                  ? () => _addEventToCalendar(event)
                  : null,
              slots: detailController.slots,
              isJoinLoading: _isJoinLoading,
            ),
          ),
        ),
      ],
    );
  }
}
