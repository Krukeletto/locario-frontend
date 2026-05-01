import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:locario/l10n/app_localizations.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../shared/auth/auth_api.dart';
import '../../shared/auth/auth_scope.dart';
import '../../shared/config/api_config.dart';
import '../../shared/services/feedback_service.dart';
import 'widgets/google_logo_icon.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _emailError;
  String? _passwordError;
  bool _hasSubmitted = false;
  bool _isSubmitting = false;

  static final RegExp _emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: ApiConfig.googleWebClientId.isEmpty
        ? null
        : ApiConfig.googleWebClientId,
    scopes: ['email', 'profile'],
  );

  AppLocalizations get _l10n => AppLocalizations.of(context)!;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return _l10n.authValidationEmailRequired;
    }
    if (!_emailRegex.hasMatch(trimmed)) {
      return _l10n.authValidationEmailInvalid;
    }
    return null;
  }

  String? _validatePassword(String value) {
    if (value.isEmpty) {
      return _l10n.authValidationPasswordRequired;
    }
    if (value.length < 8) {
      return _l10n.authValidationPasswordMin8;
    }
    return null;
  }

  bool _validateForm() {
    final emailError = _validateEmail(_emailController.text);
    final passwordError = _validatePassword(_passwordController.text);

    setState(() {
      _emailError = emailError;
      _passwordError = passwordError;
    });

    return emailError == null && passwordError == null;
  }

  void _handleEmailChanged(String value) {
    if (!_hasSubmitted) {
      return;
    }
    setState(() {
      _emailError = _validateEmail(value);
    });
  }

  void _handlePasswordChanged(String value) {
    if (!_hasSubmitted) {
      return;
    }
    setState(() {
      _passwordError = _validatePassword(value);
    });
  }

  Future<void> _handleSubmit() async {
    if (_isSubmitting) {
      return;
    }

    if (!_hasSubmitted) {
      setState(() {
        _hasSubmitted = true;
      });
    }

    final isValid = _validateForm();
    if (!isValid) {
      return;
    }

    FocusScope.of(context).unfocus();

    final sessionController = AuthScope.maybeOf(context);
    if (sessionController == null) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await sessionController.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) {
        return;
      }
      FeedbackService.showSuccess(FeedbackMessage.loginSuccess);
    } catch (error) {
      if (!mounted) {
        return;
      }
      _showAuthError(error);
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showAuthError(Object error) {
    if (error is AuthApiException && error.statusCode == 401) {
      FeedbackService.showError(FeedbackMessage.loginInvalidCredentials);
      return;
    }

    if (error is SocketException) {
      FeedbackService.showError(FeedbackMessage.networkError);
      return;
    }

    FeedbackService.showError(FeedbackMessage.unknownError);
  }

  Future<void> _handleGoogleSignIn() async {
    if (_isSubmitting) {
      return;
    }

    final sessionController = AuthScope.maybeOf(context);
    if (sessionController == null) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      if (ApiConfig.googleWebClientId.isEmpty) {
        debugPrint('Auth: missing Google web client ID configuration.');
        throw const AuthApiException('Google Sign-In not configured');
      }

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return;
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw const AuthApiException('Google Sign-In missing idToken');
      }

      // Exchange Google credential for Firebase ID token and send that to backend
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      final userCred = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      final firebaseIdToken = await userCred.user!.getIdToken();

      await sessionController.loginWithGoogle(idToken: firebaseIdToken!);
      if (!mounted) {
        return;
      }
      FeedbackService.showSuccess(FeedbackMessage.loginSuccess);
    } catch (error) {
      if (!mounted) {
        return;
      }
      _showAuthError(error);
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final isSystemDark = theme.brightness == Brightness.dark;

    final pageBackground = isSystemDark
        ? const Color(0xFF0F1512)
        : scheme.surface;
    final subtitleColor = isSystemDark
        ? Colors.white.withValues(alpha: 0.9)
        : scheme.onSurface.withValues(alpha: 1);
    final footerTextColor = isSystemDark
        ? Colors.white.withValues(alpha: 0.86)
        : scheme.onSurface;

    final subtitleText = l10n.authSubtitle;

    return Scaffold(
      backgroundColor: pageBackground,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 0.92,
            colors: [
              isSystemDark
                  ? const Color.fromARGB(74, 69, 180, 95)
                  : const Color.fromARGB(60, 5, 239, 20),
              isSystemDark
                  ? const Color.fromARGB(0, 69, 180, 95)
                  : const Color.fromARGB(0, 24, 201, 36),
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 2, 20, 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 0, bottom: 6),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: scheme.surfaceContainerLow,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: scheme.outline.withValues(alpha: 0.18),
                            ),
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
                      const SizedBox(height: 4),
                      Center(
                        child: Text(
                          'Locario',
                          style: theme.textTheme.displaySmall?.copyWith(
                            color: scheme.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 46,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Center(
                        child: Text(
                          subtitleText,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontSize: 17,
                            color: subtitleColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _AuthCard(
                        theme: theme,
                        scheme: scheme,
                        isSystemDark: isSystemDark,
                        emailController: _emailController,
                        passwordController: _passwordController,
                        emailError: _emailError,
                        passwordError: _passwordError,
                        onEmailChanged: _handleEmailChanged,
                        onPasswordChanged: _handlePasswordChanged,
                        onSubmit: _handleSubmit,
                        onGooglePressed: _handleGoogleSignIn,
                        titleText: l10n.authLoginWelcome,
                        googleButtonText: l10n.authGoogleContinue,
                        dividerText: l10n.authDividerOr,
                        emailLabel: l10n.authEmailLabel,
                        emailHint: l10n.authEmailHint,
                        passwordLabel: l10n.authPasswordLabel,
                        passwordHint: l10n.authPasswordHint,
                        submitText: l10n.authLoginSubmit,
                        switchPromptText: l10n.authLoginNoAccount,
                        switchActionText: l10n.authLoginCreateAccount,
                      ),
                      const SizedBox(height: 22),
                      Opacity(
                        opacity: 0.58,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _FooterLink(
                              label: l10n.authFooterTerms,
                              textColor: footerTextColor,
                              onTap: () {},
                            ),
                            const SizedBox(width: 18),
                            _FooterLink(
                              label: l10n.authFooterPrivacy,
                              textColor: footerTextColor,
                              onTap: () {},
                            ),
                            const SizedBox(width: 18),
                            _FooterLink(
                              label: l10n.authFooterHelp,
                              textColor: footerTextColor,
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AuthCard extends StatelessWidget {
  const _AuthCard({
    required this.theme,
    required this.scheme,
    required this.isSystemDark,
    required this.emailController,
    required this.passwordController,
    required this.emailError,
    required this.passwordError,
    required this.onEmailChanged,
    required this.onPasswordChanged,
    required this.onSubmit,
    required this.onGooglePressed,
    required this.titleText,
    required this.googleButtonText,
    required this.dividerText,
    required this.emailLabel,
    required this.emailHint,
    required this.passwordLabel,
    required this.passwordHint,
    required this.submitText,
    required this.switchPromptText,
    required this.switchActionText,
  });

  final ThemeData theme;
  final ColorScheme scheme;
  final bool isSystemDark;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final String? emailError;
  final String? passwordError;
  final ValueChanged<String> onEmailChanged;
  final ValueChanged<String> onPasswordChanged;
  final VoidCallback onSubmit;
  final VoidCallback onGooglePressed;
  final String titleText;
  final String googleButtonText;
  final String dividerText;
  final String emailLabel;
  final String emailHint;
  final String passwordLabel;
  final String passwordHint;
  final String submitText;
  final String switchPromptText;
  final String switchActionText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
      decoration: BoxDecoration(
        color: isSystemDark ? scheme.surfaceContainerHigh : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isSystemDark
              ? Colors.white.withValues(alpha: 0.16)
              : scheme.outline.withValues(alpha: 0.28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isSystemDark ? 0.28 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              titleText,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: isSystemDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w700,
                fontSize: 34,
              ),
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onGooglePressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: isSystemDark ? Colors.white : scheme.onSurface,
                side: BorderSide(
                  color: isSystemDark
                      ? Colors.white.withValues(alpha: 0.25)
                      : scheme.outline.withValues(alpha: 0.45),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: const GoogleLogoIcon(),
              label: Text(googleButtonText),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Divider(
                  color: isSystemDark
                      ? Colors.white.withValues(alpha: 0.24)
                      : scheme.outline.withValues(alpha: 0.35),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  dividerText,
                  style: theme.textTheme.labelSmall?.copyWith(
                    letterSpacing: 1.2,
                    color: isSystemDark
                        ? Colors.white.withValues(alpha: 0.76)
                        : scheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(
                child: Divider(
                  color: isSystemDark
                      ? Colors.white.withValues(alpha: 0.24)
                      : scheme.outline.withValues(alpha: 0.35),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _AuthInputField(
            label: emailLabel,
            hintText: emailHint,
            keyboardType: TextInputType.emailAddress,
            obscureText: false,
            controller: emailController,
            errorText: emailError,
            onChanged: onEmailChanged,
            isSystemDark: isSystemDark,
          ),
          const SizedBox(height: 10),
          _AuthInputField(
            label: passwordLabel,
            hintText: passwordHint,
            keyboardType: TextInputType.visiblePassword,
            obscureText: true,
            controller: passwordController,
            errorText: passwordError,
            onChanged: onPasswordChanged,
            isSystemDark: isSystemDark,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onSubmit,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                submitText,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          Center(
            child: Text(
              switchPromptText,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isSystemDark
                    ? Colors.white.withValues(alpha: 0.76)
                    : scheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                );
              },
              child: Text(
                switchActionText,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2E7D32),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthInputField extends StatelessWidget {
  const _AuthInputField({
    required this.label,
    required this.hintText,
    required this.keyboardType,
    required this.obscureText,
    required this.controller,
    required this.onChanged,
    required this.isSystemDark,
    this.errorText,
  });

  final String label;
  final String hintText;
  final TextInputType keyboardType;
  final bool obscureText;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool isSystemDark;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: isSystemDark
                ? const Color(0xFFA5D6A7)
                : const Color(0xFF1B5E20),
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: keyboardType,
          obscureText: obscureText,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isSystemDark ? Colors.white : Colors.black87,
          ),
          cursorColor: isSystemDark
              ? const Color(0xFF81C784)
              : const Color(0xFF2E7D32),
          decoration: InputDecoration(
            hintText: hintText,
            errorText: errorText,
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: isSystemDark ? Colors.white70 : Colors.black54,
            ),
            filled: true,
            fillColor: isSystemDark
                ? scheme.primary.withValues(alpha: 0.14)
                : const Color(0xFFF1F3F4),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isSystemDark
                    ? const Color(0xFF81C784)
                    : const Color(0xFF2E7D32),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FooterLink extends StatelessWidget {
  const _FooterLink({
    required this.label,
    required this.textColor,
    required this.onTap,
  });

  final String label;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: textColor,
            letterSpacing: 0.8,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
