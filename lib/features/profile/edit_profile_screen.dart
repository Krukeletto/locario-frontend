import 'dart:io';

import 'package:flutter/material.dart';
import 'package:locario/l10n/app_localizations.dart';

import '../../shared/auth/auth_api.dart';
import '../../shared/auth/auth_models.dart';
import '../../shared/auth/auth_scope.dart';
import '../../shared/services/feedback_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _instagramController = TextEditingController();
  final TextEditingController _facebookController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    _websiteController.dispose();
    _instagramController.dispose();
    _facebookController.dispose();
    super.dispose();
  }

  String _resolveValue(String value, String fallback) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? fallback : trimmed;
  }

  Future<void> _handleSubmit(BuildContext context) async {
    if (_isSubmitting) {
      return;
    }

    final sessionController = AuthScope.of(context);
    final profile = sessionController.profile;
    if (profile == null || sessionController.isBusy) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    setState(() {
      _isSubmitting = true;
    });

    try {
      final request = UpdateProfileRequest(
        username: _resolveValue(_usernameController.text, profile.username),
        email: profile.email,
        avatarUrl: profile.avatarUrl ?? '',
        bio: _resolveValue(_bioController.text, profile.bio ?? ''),
        websiteUrl: _resolveValue(
          _websiteController.text,
          profile.websiteUrl ?? '',
        ),
        instagramUrl: _resolveValue(
          _instagramController.text,
          profile.instagramUrl ?? '',
        ),
        facebookUrl: _resolveValue(
          _facebookController.text,
          profile.facebookUrl ?? '',
        ),
      );

      await sessionController.updateProfile(request: request);
      if (!mounted) {
        return;
      }
      FeedbackService.showSuccess(FeedbackMessage.profileUpdateSuccess);
    } catch (error) {
      if (!mounted) {
        return;
      }
      _showUpdateProfileError(error);
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showUpdateProfileError(Object error) {
    if (error is SocketException) {
      FeedbackService.showError(FeedbackMessage.networkError);
      return;
    }

    if (error is AuthApiException) {
      FeedbackService.showError(FeedbackMessage.profileUpdateFailed);
      return;
    }

    FeedbackService.showError(FeedbackMessage.profileUpdateFailed);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final sessionController = AuthScope.of(context);
    final profile = sessionController.profile;
    final canSubmit =
        !_isSubmitting && !sessionController.isBusy && profile != null;
    final fallbackHintStyle = theme.textTheme.bodyMedium?.copyWith(
      color: scheme.onSurface.withValues(alpha: 0.7),
    );
    final valueHintStyle = theme.textTheme.bodyMedium?.copyWith(
      color: scheme.onSurface.withValues(alpha: 0.86),
    );

    String placeholderOrValue(String? value, String fallback) {
      final trimmed = value?.trim() ?? '';
      return trimmed.isEmpty ? fallback : trimmed;
    }

    TextStyle? hintStyleFor(String? value) {
      final trimmed = value?.trim() ?? '';
      return trimmed.isEmpty ? fallbackHintStyle : valueHintStyle;
    }

    InputDecoration buildFieldDecoration({
      required String hintText,
      TextStyle? hintStyle,
    }) {
      final isDark = theme.brightness == Brightness.dark;
      final fillColor = isDark
          ? scheme.primary.withValues(alpha: 0.14)
          : scheme.surfaceContainerHighest.withValues(alpha: 0.3);
      return InputDecoration(
        hintText: hintText,
        hintStyle: hintStyle,
        filled: true,
        fillColor: fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      );
    }

    Text fieldLabel(String text) {
      return Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: scheme.primary.withValues(alpha: 0.8),
        ),
      );
    }

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
          l10n.editProfileTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            color: scheme.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        children: [
          Center(
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_rounded,
                color: scheme.primary,
                size: 48,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.editProfileChangePhoto,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleSmall?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          fieldLabel(l10n.editProfileUsernameLabel),
          const SizedBox(height: 6),
          TextFormField(
            controller: _usernameController,
            decoration: buildFieldDecoration(
              hintText: placeholderOrValue(
                profile?.username,
                l10n.editProfileUsernamePlaceholder,
              ),
              hintStyle: hintStyleFor(profile?.username),
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          fieldLabel(l10n.editProfileBioLabel),
          const SizedBox(height: 6),
          TextFormField(
            controller: _bioController,
            decoration: buildFieldDecoration(
              hintText: placeholderOrValue(
                profile?.bio,
                l10n.editProfileBioPlaceholder,
              ),
              hintStyle: hintStyleFor(profile?.bio),
            ),
            maxLength: 160,
            maxLines: 4,
            textInputAction: TextInputAction.newline,
          ),
          const SizedBox(height: 16),
          fieldLabel(l10n.editProfileWebsiteLabel),
          const SizedBox(height: 6),
          TextFormField(
            controller: _websiteController,
            decoration: buildFieldDecoration(
              hintText: placeholderOrValue(
                profile?.websiteUrl,
                l10n.editProfileWebsitePlaceholder,
              ),
              hintStyle: hintStyleFor(profile?.websiteUrl),
            ),
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          fieldLabel(l10n.editProfileInstagramLabel),
          const SizedBox(height: 6),
          TextFormField(
            controller: _instagramController,
            decoration: buildFieldDecoration(
              hintText: placeholderOrValue(
                profile?.instagramUrl,
                l10n.editProfileInstagramPlaceholder,
              ),
              hintStyle: hintStyleFor(profile?.instagramUrl),
            ),
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          fieldLabel(l10n.editProfileFacebookLabel),
          const SizedBox(height: 6),
          TextFormField(
            controller: _facebookController,
            decoration: buildFieldDecoration(
              hintText: placeholderOrValue(
                profile?.facebookUrl,
                l10n.editProfileFacebookPlaceholder,
              ),
              hintStyle: hintStyleFor(profile?.facebookUrl),
            ),
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: canSubmit ? () => _handleSubmit(context) : null,
            child: _isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.editProfileSaveButton),
          ),
        ],
      ),
    );
  }
}
