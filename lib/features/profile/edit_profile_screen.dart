import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:locario/l10n/app_localizations.dart';

import '../../shared/auth/auth_api.dart';
import '../../shared/auth/auth_models.dart';
import '../../shared/auth/auth_scope.dart';
import '../../shared/config/api_config.dart';
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

  String? _usernameError;
  String? _websiteError;
  String? _instagramError;
  String? _facebookError;

  bool _isSubmitting = false;
  String? _initializedProfileId;

  static final RegExp _usernameRegex = RegExp(r'^[a-zA-Z0-9._-]+$');

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    _websiteController.dispose();
    _instagramController.dispose();
    _facebookController.dispose();
    super.dispose();
  }

  void _initializeFields(UserProfile? profile) {
    if (profile == null || _initializedProfileId == profile.id) {
      return;
    }

    _initializedProfileId = profile.id;
    _usernameController.text = profile.username;
    _bioController.text = profile.bio ?? '';
    _websiteController.text = profile.websiteUrl ?? '';
    _instagramController.text = profile.instagramUrl ?? '';
    _facebookController.text = profile.facebookUrl ?? '';
  }

  String _trimmedValue(String value) {
    return value.trim();
  }

  String _resolveRequiredValue(String value, String fallback) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? fallback : trimmed;
  }

  String? _validateUsername(String value, AppLocalizations l10n) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return l10n.authValidationUsernameRequired;
    }
    if (trimmed.length < 3) {
      return l10n.authValidationUsernameMin3;
    }
    if (trimmed.length > 100) {
      return l10n.editProfileUsernameMax100Error;
    }
    if (!_usernameRegex.hasMatch(trimmed)) {
      return l10n.authValidationUsernameAllowed;
    }
    return null;
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

    final usernameError = _validateUsername(_usernameController.text, l10n);
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
      _usernameError = usernameError;
      _websiteError = websiteError;
      _instagramError = instagramError;
      _facebookError = facebookError;
    });

    if (usernameError != null ||
        websiteError != null ||
        instagramError != null ||
        facebookError != null) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    setState(() {
      _isSubmitting = true;
    });

    try {
      String avatarUrl;
      if (_avatarBytes != null) {
        final contentType = _resolveImageMimeType(_avatarFileName);
        final tokens = sessionController.tokens;
        if (tokens == null) {
          throw const AuthApiException('Missing session tokens');
        }

        final presignedResponse = await http.post(
          Uri.parse('${ApiConfig.baseUrl}/api/media/presigned-upload-url'),
          headers: {
            'Authorization': '${tokens.tokenType} ${tokens.accessToken}',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'entityType': 'USER_AVATAR',
            'entityId': profile.id,
            'fileName': _avatarFileName ?? 'avatar.jpg',
            'contentType': contentType,
            'fileSize': _avatarBytes!.length,
          }),
        );
        if (presignedResponse.statusCode != 201 &&
            presignedResponse.statusCode != 200) {
          throw AuthApiException(
            'Presigned URL request failed',
            statusCode: presignedResponse.statusCode,
          );
        }
        final presigned = jsonDecode(presignedResponse.body);

        final uploadResponse = await http.put(
          Uri.parse(presigned['uploadUrl'] as String),
          headers: {'Content-Type': contentType},
          body: _avatarBytes,
        );
        if (uploadResponse.statusCode != 200) {
          throw AuthApiException(
            'Avatar upload failed',
            statusCode: uploadResponse.statusCode,
          );
        }

        avatarUrl = presigned['publicUrl'] as String? ?? '';
      } else {
        avatarUrl = profile.avatarUrl ?? '';
      }

      final request = UpdateProfileRequest(
        username: _resolveRequiredValue(
          _usernameController.text,
          profile.username,
        ),
        email: profile.email,
        avatarUrl: avatarUrl,
        bio: _trimmedValue(_bioController.text),
        websiteUrl: _trimmedValue(_websiteController.text),
        instagramUrl: _trimmedValue(_instagramController.text),
        facebookUrl: _trimmedValue(_facebookController.text),
      );

      await sessionController.updateProfile(request: request);
      if (!mounted) {
        return;
      }
      FeedbackService.showSuccess(FeedbackMessage.profileUpdateSuccess);
      await Navigator.of(this.context).maybePop();
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
    _initializeFields(profile);
    final canSubmit =
        !_isSubmitting && !sessionController.isBusy && profile != null;

    InputDecoration buildFieldDecoration({
      required String hintText,
      String? errorText,
    }) {
      final isDark = theme.brightness == Brightness.dark;
      final fillColor = isDark
          ? scheme.primary.withValues(alpha: 0.14)
          : scheme.surfaceContainerHighest.withValues(alpha: 0.3);
      return InputDecoration(
        hintText: hintText,
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          color: scheme.onSurface.withValues(alpha: 0.38),
          fontStyle: FontStyle.italic,
        ),
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
              hintText: l10n.editProfileUsernamePlaceholder,
              errorText: _usernameError,
            ),
            textInputAction: TextInputAction.next,
            onChanged: (_) {
              if (_usernameError != null) {
                setState(() {
                  _usernameError = null;
                });
              }
            },
          ),
          const SizedBox(height: 16),
          fieldLabel(l10n.editProfileBioLabel),
          const SizedBox(height: 6),
          TextFormField(
            controller: _bioController,
            decoration: buildFieldDecoration(
              hintText: l10n.editProfileBioPlaceholder,
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
              hintText: l10n.editProfileWebsitePlaceholder,
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
              hintText: l10n.editProfileInstagramPlaceholder,
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
              hintText: l10n.editProfileFacebookPlaceholder,
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
