import 'dart:convert';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:locario/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../shared/auth/auth_models.dart';
import '../../shared/auth/auth_scope.dart';
import '../../shared/auth/session_controller.dart';
import '../../shared/reviews/review_formatters.dart';
import '../../shared/reviews/review_models.dart';
import '../../shared/reviews/review_repository.dart';
import '../../shared/services/feedback_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ReviewRepository _reviewRepository;
  bool _hasLoadedRatings = false;
  String? _ratingsUserId;
  Future<AverageRating?>? _ratingsFuture;
  SessionController? _sessionController;

  @override
  void initState() {
    super.initState();
    _reviewRepository = HttpReviewRepository();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final sessionController = AuthScope.of(context);
    if (_sessionController != sessionController) {
      _sessionController?.removeListener(_syncRatings);
      _sessionController = sessionController;
      _sessionController?.addListener(_syncRatings);
      _hasLoadedRatings = false;
    }
    _syncRatings();
  }

  @override
  void dispose() {
    _sessionController?.removeListener(_syncRatings);
    super.dispose();
  }

  void _syncRatings() {
    final sessionController = _sessionController;
    final profile = sessionController?.profile;
    if (sessionController == null ||
        profile == null ||
        !sessionController.isAuthenticated ||
        !profile.hasOrganizerReviewAccess) {
      if (_ratingsFuture != null || _ratingsUserId != null) {
        setState(() {
          _ratingsFuture = null;
          _ratingsUserId = null;
          _hasLoadedRatings = false;
        });
      }
      return;
    }

    if (_hasLoadedRatings && _ratingsUserId == profile.id) {
      return;
    }

    _hasLoadedRatings = true;
    _ratingsUserId = profile.id;
    setState(() {
      _ratingsFuture = _loadRatings(
        profile.id,
        sessionController.tokens?.accessToken,
        sessionController.tokens?.tokenType ?? 'Bearer',
      );
    });
  }

  Future<AverageRating?> _loadRatings(
    String organizerId,
    String? accessToken,
    String tokenType,
  ) async {
    try {
      return await _reviewRepository.fetchOrganizerAverageRating(
        organizerId,
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
    final isLoading = sessionController.isLoading;
    final isAuthenticated = sessionController.isAuthenticated;
    final profile = sessionController.profile;
    final hasProfile = isAuthenticated && profile != null;
    final canSeeOrganizerRatings = profile?.hasOrganizerReviewAccess == true;
    final isOrganizer = profile?.organizer == true;

    if (isLoading) {
      return Scaffold(
        backgroundColor: scheme.surface,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: scheme.surface,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        children: [
          if (!isAuthenticated && !isLoading) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    l10n.profileTitle,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n.profileDescription,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.72),
              ),
            ),
            const SizedBox(height: 24),
          ],
          if (hasProfile) ...[
            _ProfileHeaderCard(profile: profile),
            const SizedBox(height: 24),
          ],
          if (!isAuthenticated) ...[
            _ProfileActionCard(
              icon: Icons.login_rounded,
              title: l10n.profileAuthLoginTitle,
              subtitle: l10n.profileAuthLoginSubtitle,
              onTap: () {
                context.push(
                  '/auth/login?from=${Uri.encodeComponent('/profile')}&target=${Uri.encodeComponent('/profile')}',
                );
              },
            ),
            const SizedBox(height: 14),
          ],
          if (isAuthenticated) ...[
            _ProfileActionCard(
              icon: Icons.history_rounded,
              title: l10n.profileEventHistoryTitle,
              subtitle: l10n.profileEventHistorySubtitle,
              onTap: () => context.push('/profile/history'),
            ),
            const SizedBox(height: 14),
          ],
          if (isOrganizer) ...[
            _OrganizerSectionCard(
              onMyEventsTap: () => context.push('/profile/my-events'),
              onCreateEventTap: () => context.push('/hub/create-event'),
            ),
            const SizedBox(height: 14),
          ],
          if (canSeeOrganizerRatings) ...[
            _OrganizerRatingsCard(
              future: _ratingsFuture,
              onTap: () => context.push('/profile/reviews'),
            ),
            const SizedBox(height: 14),
          ],
          _ProfileActionCard(
            icon: Icons.bookmark_rounded,
            title: l10n.savedTitle,
            subtitle: l10n.savedSubtitle,
            onTap: () => context.push('/profile/saved'),
          ),
          const SizedBox(height: 14),
          if (isAuthenticated) ...[
            _LogoutActionCard(
              title: l10n.profileAuthLogoutTitle,
              subtitle: l10n.profileAuthLogoutSubtitle,
              isLoggingOut: sessionController.isBusy,
              onTap: sessionController.isBusy
                  ? null
                  : () {
                      sessionController.logout().then((_) {
                        FeedbackService.showSuccess(
                          FeedbackMessage.logoutSuccess,
                        );
                      });
                    },
            ),
          ],
        ],
      ),
    );
  }
}

class _LogoutActionCard extends StatelessWidget {
  const _LogoutActionCard({
    required this.title,
    required this.subtitle,
    required this.isLoggingOut,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool isLoggingOut;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final mutedColor = scheme.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: scheme.outline.withValues(alpha: 0.18)),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: mutedColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: isLoggingOut
                  ? SizedBox(
                      width: 26,
                      height: 26,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: mutedColor,
                      ),
                    )
                  : Icon(Icons.logout_rounded, color: mutedColor, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: mutedColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.6),
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
                color: mutedColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: isLoggingOut
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: mutedColor,
                      ),
                    )
                  : Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: mutedColor,
                      size: 16,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  const _ProfileHeaderCard({required this.profile});

  final UserProfile profile;

  static const double _avatarSize = 96;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final bio = profile.bio?.trim() ?? '';
    final role = profile.role?.trim() ?? '';
    final links = _buildLinks(profile, scheme);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.28)),
      ),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildAvatar(scheme),
              const SizedBox(height: 12),
              Text(
                profile.username,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (role.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  role,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.64),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Text(
                bio.isEmpty ? l10n.profileBioPlaceholder : bio,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.72),
                ),
              ),
              if (links.isNotEmpty) ...[
                const SizedBox(height: 14),
                Text(
                  l10n.profileLinksLabel,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Column(
                  children: [
                    for (final link in links)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 320),
                            child: _ProfileLinkRow(link: link),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Tooltip(
              message: l10n.editProfileTitle,
              child: Material(
                color: scheme.primary.withValues(alpha: 0.12),
                shape: const StadiumBorder(),
                child: InkWell(
                  onTap: () => context.push('/profile/edit'),
                  customBorder: const StadiumBorder(),
                  child: SizedBox(
                    height: 32,
                    width: 44,
                    child: Icon(
                      Icons.edit_rounded,
                      color: scheme.primary,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<_ProfileLinkData> _buildLinks(UserProfile profile, ColorScheme scheme) {
    final links = <_ProfileLinkData>[];

    final website = profile.websiteUrl?.trim() ?? '';
    if (website.isNotEmpty) {
      links.add(
        _ProfileLinkData(
          icon: Icon(Icons.language_rounded, color: scheme.primary, size: 18),
          label: website,
        ),
      );
    }

    final instagram = profile.instagramUrl?.trim() ?? '';
    if (instagram.isNotEmpty) {
      links.add(
        _ProfileLinkData(
          icon: SvgPicture.asset(
            'assets/instagram_profile/instagram.svg',
            width: 18,
            height: 18,
            colorFilter: ColorFilter.mode(scheme.primary, BlendMode.srcIn),
          ),
          label: instagram,
        ),
      );
    }

    final facebook = profile.facebookUrl?.trim() ?? '';
    if (facebook.isNotEmpty) {
      links.add(
        _ProfileLinkData(
          icon: Icon(Icons.facebook_rounded, color: scheme.primary, size: 18),
          label: facebook,
        ),
      );
    }

    return links;
  }

  Widget _buildAvatar(ColorScheme scheme) {
    final avatarUrl = profile.avatarUrl?.trim() ?? '';
    if (avatarUrl.isNotEmpty) {
      final dataBytes = avatarUrl.startsWith('data:')
          ? _decodeDataImage(avatarUrl)
          : null;
      if (dataBytes != null) {
        return _buildMemoryAvatar(dataBytes);
      }
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: avatarUrl,
          width: _avatarSize,
          height: _avatarSize,
          fit: BoxFit.cover,
          placeholder: (context, url) => _buildAvatarFallback(scheme),
          errorWidget: (context, url, error) => _buildAvatarFallback(scheme),
        ),
      );
    }

    return _buildAvatarFallback(scheme);
  }

  Uint8List? _decodeDataImage(String dataUri) {
    final commaIndex = dataUri.indexOf(',');
    if (commaIndex == -1) {
      return null;
    }
    try {
      return base64Decode(dataUri.substring(commaIndex + 1));
    } catch (_) {
      return null;
    }
  }

  Widget _buildMemoryAvatar(Uint8List bytes) {
    return ClipOval(
      child: Image.memory(
        bytes,
        width: _avatarSize,
        height: _avatarSize,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildAvatarFallback(ColorScheme scheme) {
    return Container(
      width: _avatarSize,
      height: _avatarSize,
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.person_rounded, color: scheme.primary, size: 48),
    );
  }
}

class _ProfileLinkData {
  const _ProfileLinkData({required this.icon, required this.label});

  final Widget icon;
  final String label;
}

class _ProfileLinkRow extends StatelessWidget {
  const _ProfileLinkRow({required this.link});

  final _ProfileLinkData link;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: scheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(child: link.icon),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: InkWell(
            onTap: () async {
              final url = _normalizeUrl(link.label);
              try {
                await launchUrlString(
                  url,
                  mode: LaunchMode.externalApplication,
                );
              } catch (_) {}
            },
            child: Text(
              link.label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.primary,
                decoration: TextDecoration.none,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }

  String _normalizeUrl(String raw) {
    final trimmed = raw.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    return 'https://$trimmed';
  }
}

class _OrganizerRatingsCard extends StatelessWidget {
  const _OrganizerRatingsCard({required this.future, required this.onTap});

  final Future<AverageRating?>? future;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return FutureBuilder<AverageRating?>(
      future: future,
      builder: (context, snapshot) {
        final rating = snapshot.data;
        final subtitle = snapshot.connectionState == ConnectionState.waiting
            ? l10n.profileOrganizerRatingsLoading
            : rating == null || !rating.hasReviews
            ? l10n.profileOrganizerRatingsEmpty
            : l10n.profileOrganizerRatingsValue(
                formatReviewAverage(rating.averageRating),
                rating.totalReviews,
              );

        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: scheme.outline.withValues(alpha: 0.28)),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: scheme.tertiary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    Icons.star_rounded,
                    color: scheme.tertiary,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.profileOrganizerRatingsTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.72),
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
                    color: scheme.tertiary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: scheme.tertiary,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _OrganizerSectionCard extends StatelessWidget {
  const _OrganizerSectionCard({
    required this.onMyEventsTap,
    required this.onCreateEventTap,
  });

  final VoidCallback onMyEventsTap;
  final VoidCallback onCreateEventTap;

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
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: scheme.tertiary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.star_rounded,
                  color: scheme.tertiary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                l10n.profileOrganizerSectionTitle,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: scheme.tertiary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 46),
            child: Text(
              l10n.profileOrganizerSectionSubtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          const SizedBox(height: 14),
          InkWell(
            onTap: onMyEventsTap,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Icon(Icons.event_rounded, color: scheme.onSurface, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.profileMyEventsTitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: scheme.onSurface.withValues(alpha: 0.38),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: onCreateEventTap,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Icon(Icons.add_rounded, color: scheme.primary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.profileOrganizerCreateEvent,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: scheme.primary,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: scheme.primary.withValues(alpha: 0.6),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileActionCard extends StatelessWidget {
  const _ProfileActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: scheme.outline.withValues(alpha: 0.28)),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: scheme.primary, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.72),
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
                color: scheme.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                color: scheme.primary,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
