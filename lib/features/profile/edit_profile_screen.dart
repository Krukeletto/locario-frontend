import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
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
  static const double _avatarSize = 96;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _instagramController = TextEditingController();
  final TextEditingController _facebookController = TextEditingController();

  Uint8List? _avatarBytes;
  String? _avatarFileName;

  String? _websiteError;
  String? _instagramError;
  String? _facebookError;

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

  String? _validateUrl(
    String value, {
    required String httpsError,
    String? domain,
    String? domainError,
  }) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    final lower = trimmed.toLowerCase();
    if (!lower.startsWith('https://')) {
      return httpsError;
    }

    if (domain != null && domainError != null && !lower.contains(domain)) {
      return domainError;
    }

    return null;
  }

  String _resolveImageMimeType(String? fileName) {
    final extension = fileName?.split('.').last.toLowerCase();
    return switch (extension) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      'gif' => 'image/gif',
      'jpg' || 'jpeg' => 'image/jpeg',
      _ => 'image/jpeg',
    };
  }

  String _buildAvatarDataUri(Uint8List bytes, String? fileName) {
    final mimeType = _resolveImageMimeType(fileName);
    return 'data:$mimeType;base64,${base64Encode(bytes)}';
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

  Future<void> _pickAvatar() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (!mounted || result == null || result.files.isEmpty) {
      return;
    }

    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null || bytes.isEmpty) {
      return;
    }

    setState(() {
      _avatarBytes = bytes;
      _avatarFileName = file.name;
    });
  }

  Future<void> _handleSubmit(BuildContext context) async {
    if (_isSubmitting) {
      return;
    }

    final l10n = AppLocalizations.of(context);
    final sessionController = AuthScope.of(context);
    final profile = sessionController.profile;
    if (profile == null || sessionController.isBusy) {
      return;
    }

    final websiteError = _validateUrl(
      _websiteController.text,
      httpsError: l10n.editProfileLinkHttpsError,
    );
    final instagramError = _validateUrl(
      _instagramController.text,
      httpsError: l10n.editProfileLinkHttpsError,
      domain: 'instagram',
      domainError: l10n.editProfileInstagramDomainError,
    );
    final facebookError = _validateUrl(
      _facebookController.text,
      httpsError: l10n.editProfileLinkHttpsError,
      domain: 'facebook',
      domainError: l10n.editProfileFacebookDomainError,
    );

    setState(() {
      _websiteError = websiteError;
      _instagramError = instagramError;
      _facebookError = facebookError;
    });

    if (websiteError != null ||
        instagramError != null ||
        facebookError != null) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    setState(() {
      _isSubmitting = true;
    });

    try {
      final avatarUrl = _avatarBytes != null
          ? _buildAvatarDataUri(_avatarBytes!, _avatarFileName)
          : (profile.avatarUrl ?? '');
      final request = UpdateProfileRequest(
        username: _resolveValue(_usernameController.text, profile.username),
        email: profile.email,
        avatarUrl: avatarUrl,
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

  Widget _buildAvatarPreview(ColorScheme scheme) {
    if (_avatarBytes != null) {
      return _buildMemoryAvatar(_avatarBytes!);
    }

    final avatarUrl = (AuthScope.of(context).profile?.avatarUrl ?? '').trim();
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
          placeholder: (context, url) => Container(
            width: _avatarSize,
            height: _avatarSize,
            color: scheme.primary.withValues(alpha: 0.12),
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          errorWidget: (context, url, error) => _buildAvatarFallback(scheme),
        ),
      );
    }

    return _buildAvatarFallback(scheme);
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
      String? errorText,
    }) {
      final isDark = theme.brightness == Brightness.dark;
      final fillColor = isDark
          ? scheme.primary.withValues(alpha: 0.14)
          : scheme.surfaceContainerHighest.withValues(alpha: 0.3);
      return InputDecoration(
        hintText: hintText,
        hintStyle: hintStyle,
        errorText: errorText,
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
            child: InkWell(
              onTap: _pickAvatar,
              borderRadius: BorderRadius.circular(_avatarSize / 2),
              child: _buildAvatarPreview(scheme),
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: _pickAvatar,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Text(
                l10n.editProfileChangePhoto,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
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
            key: const Key('edit-profile-website'),
            decoration: buildFieldDecoration(
              hintText: placeholderOrValue(
                profile?.websiteUrl,
                l10n.editProfileWebsitePlaceholder,
              ),
              hintStyle: hintStyleFor(profile?.websiteUrl),
              errorText: _websiteError,
            ),
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.next,
            onChanged: (_) {
              if (_websiteError != null) {
                setState(() {
                  _websiteError = null;
                });
              }
            },
          ),
          const SizedBox(height: 12),
          fieldLabel(l10n.editProfileInstagramLabel),
          const SizedBox(height: 6),
          TextFormField(
            controller: _instagramController,
            key: const Key('edit-profile-instagram'),
            decoration: buildFieldDecoration(
              hintText: placeholderOrValue(
                profile?.instagramUrl,
                l10n.editProfileInstagramPlaceholder,
              ),
              hintStyle: hintStyleFor(profile?.instagramUrl),
              errorText: _instagramError,
            ),
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.next,
            onChanged: (_) {
              if (_instagramError != null) {
                setState(() {
                  _instagramError = null;
                });
              }
            },
          ),
          const SizedBox(height: 12),
          fieldLabel(l10n.editProfileFacebookLabel),
          const SizedBox(height: 6),
          TextFormField(
            controller: _facebookController,
            key: const Key('edit-profile-facebook'),
            decoration: buildFieldDecoration(
              hintText: placeholderOrValue(
                profile?.facebookUrl,
                l10n.editProfileFacebookPlaceholder,
              ),
              hintStyle: hintStyleFor(profile?.facebookUrl),
              errorText: _facebookError,
            ),
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.done,
            onChanged: (_) {
              if (_facebookError != null) {
                setState(() {
                  _facebookError = null;
                });
              }
            },
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
