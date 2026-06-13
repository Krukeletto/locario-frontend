import 'package:flutter/material.dart';
import 'package:locario/l10n/app_localizations.dart';
import 'package:locario/shared/events/event_detail_scope.dart';
import 'package:locario/shared/reviews/review_scope.dart';

import '../../shared/reviews/review_formatters.dart';
import '../../shared/reviews/review_models.dart';
import '../../shared/services/feedback_service.dart';
import '../../shared/widgets/state_panel.dart';
import '../events/joined_events_scope.dart';
import '../explore/models.dart';
import '../events/widgets/info/event_info_card.dart';

class EventReviewScreen extends StatefulWidget {
  const EventReviewScreen({super.key, required this.eventId});

  final String eventId;

  @override
  State<EventReviewScreen> createState() => _EventReviewScreenState();
}

class _EventReviewScreenState extends State<EventReviewScreen> {
  final TextEditingController _commentController = TextEditingController();

  bool _isSubmitting = false;
  bool _hasRequestedLoad = false;
  int? _selectedRating;
  bool _hasAppliedReviewValues = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasRequestedLoad) return;
    _hasRequestedLoad = true;
    EventDetailScope.of(context).loadEvent(widget.eventId);
    EventDetailScope.of(context).addListener(_onEventDetailChanged);
  }

  void _onEventDetailChanged() {
    final event = EventDetailScope.of(context).event;
    if (event == null) return;
    if (event.organizerId != null && event.organizerId!.isNotEmpty) {
      ReviewScope.of(context).loadOrganizerRating(event.organizerId!);
    }
    ReviewScope.of(context).loadMyReviewForEvent(widget.eventId);
    ReviewScope.of(context).addListener(_onReviewChanged);
    EventDetailScope.of(context).removeListener(_onEventDetailChanged);
  }

  void _onReviewChanged() {
    _applyExistingReview();
  }

  void _applyExistingReview() {
    if (_hasAppliedReviewValues) return;
    final userReview = ReviewScope.of(context).userReview;
    if (userReview == null) return;
    _hasAppliedReviewValues = true;
    _selectedRating = userReview.rating;
    _commentController.text = userReview.comment ?? '';
  }

  Future<void> _submitReview() async {
    final eventDetailController = EventDetailScope.of(context);
    final event = eventDetailController.event;
    if (event == null || _selectedRating == null || _isSubmitting) return;

    final joinedController = JoinedEventsScope.maybeOf(context);
    final isJoined = joinedController?.isJoined(event.id) == true;
    if (!event.hasEnded || !isJoined) return;

    setState(() => _isSubmitting = true);

    try {
      final reviewController = ReviewScope.of(context);
      await reviewController.submitReview(
        widget.eventId,
        ReviewRequest(
          rating: _selectedRating!,
          comment: _commentController.text.trim(),
        ),
      );
      if (!mounted) return;
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
    final eventDetailController = EventDetailScope.of(context);
    final reviewController = ReviewScope.of(context);
    final joinedController = JoinedEventsScope.maybeOf(context);
    final event = eventDetailController.event;
    final isLoading = eventDetailController.isLoading;
    final error = eventDetailController.error;
    final userReview = reviewController.userReview;
    final organizerRating = reviewController.organizerRating;

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
      body: isLoading || event == null
          ? StatePanel.loading(
              title: l10n.eventReviewLoadingTitle,
              subtitle: l10n.eventReviewLoadingSubtitle,
            )
          : error != null
          ? StatePanel.error(
              title: l10n.eventReviewErrorTitle,
              subtitle: error,
              retryLabel: l10n.exploreRetryButton,
              onRetry: () => eventDetailController.loadEvent(
                widget.eventId,
                forceRefresh: true,
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
              children: [
                _EventHeader(event: event, averageRating: organizerRating),
                const SizedBox(height: 14),
                if (event.organizerId != null && event.organizerId!.isNotEmpty)
                  _OrganizerRatingCard(averageRating: organizerRating),
                const SizedBox(height: 14),
                _ReviewComposerCard(
                  event: event,
                  selectedRating: _selectedRating,
                  commentController: _commentController,
                  isSubmitting: _isSubmitting,
                  isReviewLocked: userReview != null,
                  canSubmit:
                      joinedController?.isJoined(event.id) == true &&
                      event.hasEnded,
                  onRatingSelected: (rating) {
                    setState(() => _selectedRating = rating);
                  },
                  onSubmit: _submitReview,
                  submittedReview: userReview,
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
