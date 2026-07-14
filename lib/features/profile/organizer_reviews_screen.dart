import 'package:flutter/material.dart';
import 'package:locario/l10n/app_localizations.dart';

import '../../shared/auth/auth_scope.dart';
import '../../shared/auth/session_controller.dart';
import '../../shared/reviews/review_formatters.dart';
import '../../shared/reviews/review_models.dart';
import '../../shared/reviews/review_scope.dart';
import '../../shared/widgets/state_panel.dart';

class OrganizerReviewsScreen extends StatefulWidget {
  const OrganizerReviewsScreen({super.key});

  @override
  State<OrganizerReviewsScreen> createState() => _OrganizerReviewsScreenState();
}

class _OrganizerReviewsScreenState extends State<OrganizerReviewsScreen> {
  bool _hasLoaded = false;
  SessionController? _sessionController;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final sessionController = AuthScope.of(context);
    if (_sessionController != sessionController) {
      _sessionController?.removeListener(_sync);
      _sessionController = sessionController;
      _sessionController?.addListener(_sync);
      _hasLoaded = false;
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
        !sessionController.isAuthenticated) {
      return;
    }

    if (_hasLoaded) return;
    _hasLoaded = true;
    final profileId = profile.id;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ReviewScope.of(context).loadOrganizerReviews(profileId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

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
          l10n.profileOrganizerReviewsScreenTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            color: scheme.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Builder(
        builder: (context) {
          final controller = ReviewScope.of(context);
          final isLoading = controller.isOrganizerReviewsLoading;
          final overview = controller.organizerReviewsOverview;

          if (isLoading) {
            return StatePanel.loading(
              title: l10n.profileOrganizerReviewsLoadingTitle,
              subtitle: l10n.profileOrganizerReviewsLoadingSubtitle,
            );
          }

          if (overview == null) {
            return StatePanel.empty(
              title: l10n.profileOrganizerReviewsEmptyTitle,
              subtitle: l10n.profileOrganizerReviewsEmptySubtitle,
              customContent: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: FilledButton(
                  onPressed: _sync,
                  child: Text(l10n.exploreRetryButton),
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
            children: [
              _SummaryCard(overview: overview),
              const SizedBox(height: 14),
              if (overview.reviews.isEmpty)
                StatePanel.empty(
                  title: l10n.profileOrganizerReviewsEmptyTitle,
                  subtitle: l10n.profileOrganizerReviewsEmptySubtitle,
                )
              else
                ...overview.reviews.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _ReviewCard(entry: entry),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.overview});

  final OrganizerReviewsOverview overview;

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
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: scheme.tertiary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(Icons.star_rounded, color: scheme.tertiary, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.profileOrganizerReviewsSummaryTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  overview.hasReviews
                      ? l10n.profileOrganizerRatingsValue(
                          formatReviewAverage(
                            overview.averageRating.averageRating,
                          ),
                          overview.totalReviews,
                        )
                      : l10n.profileOrganizerRatingsEmpty,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.72),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.entry});

  final OrganizerReviewEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

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
            entry.eventTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.star_rounded, size: 18, color: scheme.tertiary),
              const SizedBox(width: 4),
              Text(
                entry.review.rating.toString(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                entry.review.username,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.62),
                ),
              ),
              const Spacer(),
              Text(
                _formatDate(entry.review.createdAt),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.62),
                ),
              ),
            ],
          ),
          if ((entry.review.comment ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              entry.review.comment!.trim(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString();
    return '$day.$month.$year';
  }
}
