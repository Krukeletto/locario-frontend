import 'dart:io';

import 'package:flutter/material.dart';
import 'package:locario/l10n/app_localizations.dart';
import 'package:locario/shared/notifications/notification_scope.dart';
import 'package:locario/shared/notifications/notification_type.dart';

import 'package:go_router/go_router.dart';

import '../../app/locale/locale_scope.dart';
import '../../app/theme/theme_scope.dart';
import '../../shared/auth/auth_api.dart';
import '../../shared/auth/auth_scope.dart';
import '../../shared/services/feedback_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final localeController = LocaleScope.of(context);
    final themeController = ThemeScope.of(context);
    final notificationController = NotificationScope.of(context);
    final sessionController = AuthScope.of(context);
    final isAuthenticated = sessionController.isAuthenticated;
    final hasPassword = sessionController.profile?.hasPassword ?? false;
    final canChangePassword = isAuthenticated && hasPassword;
    final profile = sessionController.profile;
    final isOrganizer = profile?.organizer == true;
    final isVerificationPending =
        profile?.organizerVerificationStatus == 'pending';
    final canBecomeOrganizer =
        isAuthenticated && !isOrganizer && !isVerificationPending;

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
          l10n.settingsScreenTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            color: scheme.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        children: [
          _SettingsSection(
            title: l10n.languageSectionTitle,
            subtitle: l10n.languageSectionSubtitle,
            child: SegmentedButton<Locale>(
              key: const Key('settings-language-segmented'),
              showSelectedIcon: false,
              segments: [
                ButtonSegment<Locale>(
                  value: const Locale('pl'),
                  label: Text(l10n.localePolish),
                ),
                ButtonSegment<Locale>(
                  value: const Locale('en'),
                  label: Text(l10n.localeEnglish),
                ),
              ],
              selected: {localeController.locale},
              onSelectionChanged: (selection) {
                localeController.setLocale(selection.first);
              },
            ),
          ),
          const SizedBox(height: 14),
          _SettingsSection(
            title: l10n.themeSectionTitle,
            subtitle: l10n.themeSectionSubtitle,
            child: SegmentedButton<ThemeMode>(
              key: const Key('settings-theme-segmented'),
              showSelectedIcon: false,
              segments: [
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.system,
                  label: Text(l10n.themeModeSystem),
                ),
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.light,
                  label: Text(l10n.themeModeLight),
                ),
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.dark,
                  label: Text(l10n.themeModeDark),
                ),
              ],
              selected: {themeController.themeMode},
              onSelectionChanged: (selection) {
                themeController.setThemeMode(selection.first);
              },
            ),
          ),
          const SizedBox(height: 14),
          if (canChangePassword) ...[
            _SettingsSection(
              title: l10n.settingsAccountSectionTitle,
              subtitle: l10n.settingsAccountSectionSubtitle,
              child: FilledButton.icon(
                onPressed: () => _showChangePasswordDialog(context),
                icon: const Icon(Icons.lock_reset_rounded),
                label: Text(l10n.settingsAccountChangePassword),
              ),
            ),
            const SizedBox(height: 14),
          ],
          _SettingsSection(
            title: l10n.notificationSettingsTitle,
            subtitle: l10n.notificationSettingsSubtitle,
            child: Column(
              children: [
                for (final type in NotificationType.values)
                  _NotificationToggle(
                    type: type,
                    enabled: notificationController.isEnabled(type),
                    onChanged: (value) {
                      notificationController.setEnabled(type, value);
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _SettingsSection(
            title: l10n.settingsLegalSectionTitle,
            subtitle: l10n.settingsLegalSectionSubtitle,
            child: Column(
              children: [
                _SettingsLinkRow(
                  icon: Icons.description_rounded,
                  label: l10n.settingsLegalTerms,
                  onTap: () => context.push('/legal/terms'),
                ),
                const SizedBox(height: 12),
                _SettingsLinkRow(
                  icon: Icons.privacy_tip_rounded,
                  label: l10n.settingsLegalPrivacy,
                  onTap: () => context.push('/legal/privacy'),
                ),
                const SizedBox(height: 12),
                _SettingsLinkRow(
                  icon: Icons.help_outline_rounded,
                  label: l10n.settingsLegalHelp,
                  onTap: () => context.push('/legal/help'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _SettingsSection(
            title: l10n.settingsConsentsSectionTitle,
            subtitle: l10n.settingsConsentsSectionSubtitle,
            child: _SettingsLinkRow(
              icon: Icons.shield_outlined,
              label: l10n.legalConsentsTitle,
              onTap: () => context.push('/legal/consents'),
            ),
          ),
          const SizedBox(height: 14),
          if (canBecomeOrganizer) ...[
            _SettingsSection(
              title: l10n.profileBecomeOrganizerTitle,
              subtitle: l10n.profileBecomeOrganizerSubtitle,
              child: FilledButton.icon(
                onPressed: () => _showBecomeOrganizerDialog(context),
                icon: const Icon(Icons.verified_rounded),
                label: Text(l10n.profileBecomeOrganizerTitle),
              ),
            ),
            const SizedBox(height: 14),
          ],
          if (isVerificationPending) ...[
            _SettingsSection(
              title: l10n.profileOrganizerVerificationPendingTitle,
              subtitle: l10n.profileOrganizerVerificationPendingSubtitle,
              child: Row(
                children: [
                  Icon(
                    Icons.hourglass_empty_rounded,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    l10n.profileOrganizerVerificationPendingTitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],
          _SettingsSection(
            title: 'Debug',
            subtitle: 'Tap to send a test notification after 3 seconds',
            child: FilledButton.icon(
              onPressed: () {
                final scheduled = notificationController.sendTestNotification();
                final messenger = ScaffoldMessenger.of(context);
                if (scheduled) {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Notification in 3s...'),
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 2),
                    ),
                  );
                } else {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Type is disabled in settings'),
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.notifications_active_rounded),
              label: const Text('Send test notification (3s)'),
            ),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final sessionController = AuthScope.of(context);
    if (sessionController.isBusy) {
      return;
    }

    showDialog<void>(
      context: context,
      builder: (context) => const _ChangePasswordDialog(),
    );
  }

  void _showBecomeOrganizerDialog(BuildContext context) {
    final sessionController = AuthScope.of(context);
    if (sessionController.isBusy) {
      return;
    }

    final l10n = AppLocalizations.of(context);

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.profileBecomeOrganizerDialogTitle),
        content: Text(l10n.profileBecomeOrganizerDialogBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.profileBecomeOrganizerDialogCancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              try {
                await sessionController.requestOrganizerVerification();
                if (!context.mounted) {
                  return;
                }
                FeedbackService.showSuccess(
                  FeedbackMessage.organizerVerificationSent,
                );
              } catch (_) {
                if (!context.mounted) {
                  return;
                }
                FeedbackService.showError(FeedbackMessage.unknownError);
              }
            },
            child: Text(l10n.profileBecomeOrganizerDialogSubmit),
          ),
        ],
      ),
    );
  }
}

class _ChangePasswordDialog extends StatefulWidget {
  const _ChangePasswordDialog();

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  bool _hasSubmitted = false;
  bool _isSubmitting = false;
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  String? _oldPasswordError;
  String? _newPasswordError;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  String? _validateOldPassword(AppLocalizations l10n, String value) {
    if (value.isEmpty) {
      return l10n.authValidationPasswordRequired;
    }
    return null;
  }

  String? _validateNewPassword(AppLocalizations l10n, String value) {
    if (value.isEmpty) {
      return l10n.authValidationPasswordRequired;
    }
    if (value.length < 8) {
      return l10n.authValidationPasswordMin8;
    }
    return null;
  }

  void _handleOldPasswordChanged(AppLocalizations l10n, String value) {
    if (!_hasSubmitted) {
      return;
    }

    setState(() {
      _oldPasswordError = _validateOldPassword(l10n, value);
    });
  }

  void _handleNewPasswordChanged(AppLocalizations l10n, String value) {
    if (!_hasSubmitted) {
      return;
    }

    setState(() {
      _newPasswordError = _validateNewPassword(l10n, value);
    });
  }

  Future<void> _handleSubmit(AppLocalizations l10n) async {
    if (_isSubmitting) {
      return;
    }

    if (!_hasSubmitted) {
      setState(() {
        _hasSubmitted = true;
      });
    }

    final oldPasswordError = _validateOldPassword(
      l10n,
      _oldPasswordController.text,
    );
    final newPasswordError = _validateNewPassword(
      l10n,
      _newPasswordController.text,
    );

    setState(() {
      _oldPasswordError = oldPasswordError;
      _newPasswordError = newPasswordError;
    });

    if (oldPasswordError != null || newPasswordError != null) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    final sessionController = AuthScope.of(context);
    setState(() {
      _isSubmitting = true;
    });

    try {
      await sessionController.changePassword(
        oldPassword: _oldPasswordController.text,
        newPassword: _newPasswordController.text,
      );
      if (!mounted) {
        return;
      }
      FeedbackService.showSuccess(FeedbackMessage.changePasswordSuccess);
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) {
        return;
      }
      _showChangePasswordError(error);
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showChangePasswordError(Object error) {
    if (error is AuthApiException) {
      if (error.statusCode == 400 || error.statusCode == 401) {
        FeedbackService.showError(FeedbackMessage.changePasswordInvalidOld);
      } else {
        FeedbackService.showError(FeedbackMessage.changePasswordFailed);
      }
      return;
    }

    if (error is SocketException) {
      FeedbackService.showError(FeedbackMessage.networkError);
      return;
    }

    FeedbackService.showError(FeedbackMessage.changePasswordFailed);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final sessionController = AuthScope.of(context);
    final canSubmit = !_isSubmitting && !sessionController.isBusy;

    return AlertDialog(
      title: Text(l10n.settingsChangePasswordDialogTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _oldPasswordController,
              obscureText: _obscureOldPassword,
              textInputAction: TextInputAction.next,
              autocorrect: false,
              enableSuggestions: false,
              decoration: InputDecoration(
                labelText: l10n.settingsChangePasswordCurrentLabel,
                hintText: l10n.authPasswordHint,
                floatingLabelBehavior: FloatingLabelBehavior.always,
                errorText: _oldPasswordError,
                filled: true,
                fillColor: scheme.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureOldPassword
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureOldPassword = !_obscureOldPassword;
                    });
                  },
                ),
              ),
              onChanged: (value) => _handleOldPasswordChanged(l10n, value),
              onSubmitted: (_) => FocusScope.of(context).nextFocus(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _newPasswordController,
              obscureText: _obscureNewPassword,
              textInputAction: TextInputAction.done,
              autocorrect: false,
              enableSuggestions: false,
              decoration: InputDecoration(
                labelText: l10n.settingsChangePasswordNewLabel,
                hintText: l10n.authPasswordHint,
                floatingLabelBehavior: FloatingLabelBehavior.always,
                errorText: _newPasswordError,
                filled: true,
                fillColor: scheme.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNewPassword
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureNewPassword = !_obscureNewPassword;
                    });
                  },
                ),
              ),
              onChanged: (value) => _handleNewPasswordChanged(l10n, value),
              onSubmitted: (_) => _handleSubmit(l10n),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.settingsChangePasswordCancel),
        ),
        FilledButton(
          onPressed: canSubmit ? () => _handleSubmit(l10n) : null,
          child: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.settingsChangePasswordSubmit),
        ),
      ],
    );
  }
}

class _NotificationToggle extends StatelessWidget {
  const _NotificationToggle({
    required this.type,
    required this.enabled,
    required this.onChanged,
  });

  final NotificationType type;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: enabled
                  ? scheme.primary.withValues(alpha: 0.12)
                  : scheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              type.icon,
              color: enabled
                  ? scheme.primary
                  : scheme.onSurface.withValues(alpha: 0.38),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _notificationTypeName(l10n, type),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
                Text(
                  _notificationTypeDesc(l10n, type),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.56),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch.adaptive(value: enabled, onChanged: onChanged),
        ],
      ),
    );
  }

  String _notificationTypeName(AppLocalizations l10n, NotificationType type) {
    return switch (type) {
      NotificationType.upcomingEvent => l10n.notificationTypeUpcomingEvent,
      NotificationType.expiredEvent => l10n.notificationTypeExpiredEvent,
      NotificationType.eventPublished => l10n.notificationTypeEventPublished,
      NotificationType.systemMessage => l10n.notificationTypeSystemMessage,
      NotificationType.chatMessage => l10n.notificationTypeChatMessage,
    };
  }

  String _notificationTypeDesc(AppLocalizations l10n, NotificationType type) {
    return switch (type) {
      NotificationType.upcomingEvent => l10n.notificationTypeUpcomingEventDesc,
      NotificationType.expiredEvent => l10n.notificationTypeExpiredEventDesc,
      NotificationType.eventPublished =>
        l10n.notificationTypeEventPublishedDesc,
      NotificationType.systemMessage => l10n.notificationTypeSystemMessageDesc,
      NotificationType.chatMessage => l10n.notificationTypeChatMessageDesc,
    };
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

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
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _SettingsLinkRow extends StatelessWidget {
  const _SettingsLinkRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: scheme.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              color: scheme.onSurface.withValues(alpha: 0.38),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
