import 'package:flutter/material.dart';
import 'package:locario/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../shared/auth/auth_models.dart';
import '../../shared/auth/auth_scope.dart';
import '../../shared/services/feedback_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final sessionController = AuthScope.of(context);
    final isAuthenticated = sessionController.isAuthenticated;
    final profile = sessionController.profile;
    final hasProfile = isAuthenticated && profile != null;
    final authTitle = isAuthenticated
        ? l10n.profileAuthLogoutTitle
        : l10n.profileAuthLoginTitle;
    final authSubtitle = isAuthenticated
        ? l10n.profileAuthLogoutSubtitle
        : l10n.profileAuthLoginSubtitle;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        children: [
          Text(
            l10n.profileTitle,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.profileDescription,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.72),
            ),
          ),
          const SizedBox(height: 24),
          if (hasProfile) ...[
            _ProfileHeaderCard(profile: profile),
            const SizedBox(height: 24),
          ],
          _ProfileActionCard(
            icon: isAuthenticated ? Icons.logout_rounded : Icons.login_rounded,
            title: authTitle,
            subtitle: authSubtitle,
            onTap: () {
              if (sessionController.isBusy) {
                return;
              }
              if (isAuthenticated) {
                sessionController.logout().then((_) {
                  FeedbackService.showSuccess(FeedbackMessage.logoutSuccess);
                });
              } else {
                context.push(
                  '/auth/login?from=${Uri.encodeComponent('/profile')}&target=${Uri.encodeComponent('/profile')}',
                );
              }
            },
          ),
          const SizedBox(height: 14),
          _ProfileActionCard(
            icon: Icons.notifications_rounded,
            title: l10n.tabInbox,
            subtitle: l10n.profileInboxSubtitle,
            onTap: () => context.push('/inbox'),
          ),
          const SizedBox(height: 14),
          _ProfileActionCard(
            icon: Icons.bookmark_rounded,
            title: l10n.savedTitle,
            subtitle: l10n.savedSubtitle,
            onTap: () => context.push('/profile/saved'),
          ),
          const SizedBox(height: 14),
          _ProfileActionCard(
            icon: Icons.settings_outlined,
            title: l10n.settingsTitle,
            subtitle: l10n.settingsSubtitle,
            onTap: () => context.push('/profile/settings'),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  const _ProfileHeaderCard({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final bio = profile.bio?.trim() ?? '';
    final links = _buildLinks(profile);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.28)),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor,
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_rounded,
                  color: scheme.primary,
                  size: 32,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  profile.username,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            bio.isEmpty ? l10n.profileBioPlaceholder : bio,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.72),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            l10n.profileLinksLabel,
            style: theme.textTheme.titleSmall?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          if (links.isEmpty)
            Text(
              l10n.profileLinksPlaceholder,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.56),
              ),
            )
          else
            Column(
              children: [
                for (final link in links)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _ProfileLinkRow(link: link),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  List<_ProfileLinkData> _buildLinks(UserProfile profile) {
    final links = <_ProfileLinkData>[];

    final website = profile.websiteUrl?.trim() ?? '';
    if (website.isNotEmpty) {
      links.add(_ProfileLinkData(icon: Icons.language_rounded, label: website));
    }

    final instagram = profile.instagramUrl?.trim() ?? '';
    if (instagram.isNotEmpty) {
      links.add(
        _ProfileLinkData(icon: Icons.camera_alt_rounded, label: instagram),
      );
    }

    final facebook = profile.facebookUrl?.trim() ?? '';
    if (facebook.isNotEmpty) {
      links.add(
        _ProfileLinkData(icon: Icons.facebook_rounded, label: facebook),
      );
    }

    return links;
  }
}

class _ProfileLinkData {
  const _ProfileLinkData({required this.icon, required this.label});

  final IconData icon;
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
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: scheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(link.icon, color: scheme.primary, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            link.label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.8),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
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
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor,
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
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
