import 'package:flutter/material.dart';
import 'package:locario/l10n/app_localizations.dart';

import '../../shared/auth/auth_scope.dart';
import '../../shared/events/event_repository.dart';
import '../../shared/reviews/review_formatters.dart';
import '../../shared/reviews/review_models.dart';
import '../../shared/reviews/review_repository.dart';
import '../../shared/services/feedback_service.dart';
import '../../shared/widgets/state_panel.dart';
import '../events/joined_events_scope.dart';
import '../explore/models.dart';
import '../events/widgets/info/event_info_card.dart';

class EventReviewScreen extends StatefulWidget {
  const EventReviewScreen({
    super.key,
    required this.eventId,
    EventRepository? eventRepository,
    ReviewRepository? reviewRepository,
  }) : _eventRepository = eventRepository,
       _reviewRepository = reviewRepository;

  final String eventId;
  final EventRepository? _eventRepository;
  final ReviewRepository? _reviewRepository;

  @override
  State<EventReviewScreen> createState() => _EventReviewScreenState();
}

class _EventReviewScreenState extends State<EventReviewScreen> {
  late final EventRepository _eventRepository;
  late final ReviewRepository _reviewRepository;
  final TextEditingController _commentController = TextEditingController();

  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _hasRequestedLoad = false;
  String? _error;
  ExploreEvent? _event;
  AverageRating? _averageRating;
  ReviewResponse? _myReview;
  int? _selectedRating;
  bool _hasAppliedReviewValues = false;

  @override
  void initState() {
    super.initState();
    _eventRepository = widget._eventRepository ?? HttpEventRepository();
    _reviewRepository = widget._reviewRepository ?? HttpReviewRepository();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasRequestedLoad) {
      return;
    }
    _hasRequestedLoad = true;
    _load();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final auth = AuthScope.maybeOf(context);
      final accessToken = auth?.tokens?.accessToken;
      final tokenType = auth?.tokens?.tokenType ?? 'Bearer';
      final event = await _eventRepository.fetchEvent(widget.eventId);
      AverageRating? averageRating;
      if (event.organizerId != null && event.organizerId!.isNotEmpty) {
        try {
          averageRating = await _reviewRepository.fetchOrganizerAverageRating(
            event.organizerId!,
            accessToken: accessToken,
            tokenType: tokenType,
          );
        } catch (_) {
          averageRating = null;
        }
      }

      ReviewResponse? myReview;
      if (accessToken != null && accessToken.isNotEmpty) {
        try {
          myReview = await _reviewRepository.fetchMyReviewForEvent(
            event.id,
            accessToken: accessToken,
            tokenType: tokenType,
          );
        } catch (_) {
          myReview = null;
        }
      }

      if (!mounted) return;

      setState(() {
        _event = event;
        _averageRating = averageRating;
        _myReview = myReview;
        _isLoading = false;
      });

      _applyExistingReview();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  void _applyExistingReview() {
    if (_hasAppliedReviewValues || _myReview == null) {
      return;
    }

    _hasAppliedReviewValues = true;
    _selectedRating = _myReview!.rating;
    _commentController.text = _myReview!.comment ?? '';
  }

  Future<void> _submitReview() async {
    final event = _event;
    if (event == null || _selectedRating == null || _isSubmitting) {
      return;
    }

    final auth = AuthScope.maybeOf(context);
    final tokens = auth?.tokens;
    if (tokens == null) {
      return;
    }

    final joinedController = JoinedEventsScope.maybeOf(context);
    final isJoined = joinedController?.isJoined(event.id) == true;
    if (!event.hasEnded || !isJoined) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final submitted = await _reviewRepository.submitEventReview(
        event.id,
        ReviewRequest(
          rating: _selectedRating!,
          comment: _commentController.text.trim(),
        ),
        accessToken: tokens.accessToken,
        tokenType: tokens.tokenType,
      );
      if (!mounted) return;
      setState(() => _myReview = submitted);
      FeedbackService.showSuccess(FeedbackMessage.eventReviewSuccess);
    } catch (_) {
      if (!mounted) return;
      FeedbackService.showError(FeedbackMessage.eventReviewError);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final joinedController = JoinedEventsScope.maybeOf(context);
    final event = _event;

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
          l10n.eventReviewScreenTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            color: scheme.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: _isLoading
          ? StatePanel.loading(
              title: l10n.eventReviewLoadingTitle,
              subtitle: l10n.eventReviewLoadingSubtitle,
            )
          : _error != null || event == null
          ? StatePanel.error(
              title: l10n.eventReviewErrorTitle,
              subtitle: l10n.eventReviewErrorSubtitle,
              retryLabel: l10n.exploreRetryButton,
              onRetry: _load,
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
              children: [
                _EventHeader(event: event, averageRating: _averageRating),
                const SizedBox(height: 14),
                if (event.organizerId != null && event.organizerId!.isNotEmpty)
                  _OrganizerRatingCard(averageRating: _averageRating),
                const SizedBox(height: 14),
                _ReviewComposerCard(
                  event: event,
                  selectedRating: _selectedRating,
                  commentController: _commentController,
                  isSubmitting: _isSubmitting,
                  isReviewLocked: _myReview != null,
                  canSubmit:
                      joinedController?.isJoined(event.id) == true &&
                      event.hasEnded,
                  onRatingSelected: (rating) {
                    setState(() => _selectedRating = rating);
                  },
                  onSubmit: _submitReview,
                  submittedReview: _myReview,
                ),
              ],
            ),
    );
  }
}

class _EventHeader extends StatelessWidget {
  const _EventHeader({required this.event, required this.averageRating});

  final ExploreEvent event;
  final AverageRating? averageRating;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event.title,
            style: theme.textTheme.titleLarge?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            event.locationLabel(l10n),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.72),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.calendar_month_rounded,
                size: 16,
                color: scheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                _formatDateTime(event.startsAt),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.68),
                ),
              ),
            ],
          ),
          if (averageRating != null) ...[
            const SizedBox(height: 12),
            Text(
              l10n.eventOrganizerRatingValue(
                formatReviewAverage(averageRating!.averageRating),
                averageRating!.totalReviews,
              ),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.72),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    final local = date.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day.$month.$year, $hour:$minute';
  }
}

class _OrganizerRatingCard extends StatelessWidget {
  const _OrganizerRatingCard({required this.averageRating});

  final AverageRating? averageRating;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.28)),
      ),
      child: EventInfoCard(
        label: l10n.eventOrganizerRatingLabel,
        value: averageRating == null || !averageRating!.hasReviews
            ? l10n.eventOrganizerRatingEmpty
            : l10n.eventOrganizerRatingValue(
                formatReviewAverage(averageRating!.averageRating),
                averageRating!.totalReviews,
              ),
        icon: Icons.star_rounded,
      ),
    );
  }
}

class _ReviewComposerCard extends StatelessWidget {
  const _ReviewComposerCard({
    required this.event,
    required this.selectedRating,
    required this.commentController,
    required this.isSubmitting,
    required this.isReviewLocked,
    required this.canSubmit,
    required this.onRatingSelected,
    required this.onSubmit,
    required this.submittedReview,
  });

  final ExploreEvent event;
  final int? selectedRating;
  final TextEditingController commentController;
  final bool isSubmitting;
  final bool isReviewLocked;
  final bool canSubmit;
  final ValueChanged<int> onRatingSelected;
  final VoidCallback onSubmit;
  final ReviewResponse? submittedReview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final locked = isReviewLocked || !canSubmit;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.eventReviewFormTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            locked
                ? l10n.eventReviewLockedSubtitle
                : l10n.eventReviewFormSubtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.72),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(5, (index) {
              final rating = index + 1;
              final selected =
                  selectedRating != null && selectedRating! >= rating;
              return FilterChip(
                label: Text(rating.toString()),
                selected: selected,
                onSelected: locked
                    ? null
                    : (_) {
                        onRatingSelected(rating);
                      },
                showCheckmark: false,
                avatar: Icon(
                  selected ? Icons.star_rounded : Icons.star_border_rounded,
                  size: 18,
                ),
              );
            }),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: commentController,
            enabled: !locked,
            maxLines: 4,
            maxLength: 1000,
            decoration: InputDecoration(
              labelText: l10n.eventReviewCommentLabel,
              hintText: l10n.eventReviewCommentHint,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 4),
          if (submittedReview != null) ...[
            Text(
              l10n.eventReviewSubmittedLabel,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
          ],
          FilledButton.icon(
            onPressed: locked || selectedRating == null || isSubmitting
                ? null
                : onSubmit,
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              textStyle: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            icon: isSubmitting
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: scheme.onPrimary,
                    ),
                  )
                : const Icon(Icons.send_rounded, size: 20),
            label: Text(
              submittedReview != null
                  ? l10n.eventReviewSubmittedButton
                  : l10n.eventReviewSubmitButton,
            ),
          ),
          if (!canSubmit) ...[
            const SizedBox(height: 10),
            Text(
              l10n.eventReviewEligibilityHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.62),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
