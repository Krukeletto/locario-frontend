import 'package:flutter/material.dart';
import 'package:locario/l10n/app_localizations.dart';

import '../../shared/auth/auth_scope.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final sessionController = AuthScope.of(context);
    final profile = sessionController.profile;
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
        ],
      ),
    );
  }
}
