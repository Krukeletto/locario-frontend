import 'package:flutter/material.dart';

import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _usernameError;
  String? _emailError;
  String? _passwordError;
  bool _hasSubmitted = false;

  static final RegExp _emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  static final RegExp _usernameRegex = RegExp(r'^[a-zA-Z0-9._-]+$');

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateUsername(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return 'Podaj nazwę użytkownika';
    }
    if (trimmed.length < 3) {
      return 'Nazwa użytkownika musi mieć min. 3 znaki';
    }
    if (!_usernameRegex.hasMatch(trimmed)) {
      return 'Dozwolone: litery, cyfry, . _ -';
    }
    return null;
  }

  String? _validateEmail(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return 'Podaj adres e-mail';
    }
    if (!_emailRegex.hasMatch(trimmed)) {
      return 'Podaj poprawny adres e-mail';
    }
    return null;
  }

  String? _validatePassword(String value) {
    if (value.isEmpty) {
      return 'Podaj hasło';
    }
    if (value.length < 8) {
      return 'Hasło musi mieć min. 8 znaków';
    }
    return null;
  }

  bool _validateForm() {
    final usernameError = _validateUsername(_usernameController.text);
    final emailError = _validateEmail(_emailController.text);
    final passwordError = _validatePassword(_passwordController.text);

    setState(() {
      _usernameError = usernameError;
      _emailError = emailError;
      _passwordError = passwordError;
    });

    return usernameError == null && emailError == null && passwordError == null;
  }

  void _handleUsernameChanged(String value) {
    if (!_hasSubmitted) {
      return;
    }
    setState(() {
      _usernameError = _validateUsername(value);
    });
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

  void _handleSubmit() {
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
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 0.92,
            colors: [
              Color.fromARGB(60, 5, 239, 20),
              Color.fromARGB(0, 24, 201, 36),
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
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
                          'Odkryj lokalne perełki w Twojej okolicy',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontSize: 17,
                            color: scheme.onSurface.withValues(alpha: 1),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _AuthCard(
                        theme: theme,
                        scheme: scheme,
                        usernameController: _usernameController,
                        emailController: _emailController,
                        passwordController: _passwordController,
                        usernameError: _usernameError,
                        emailError: _emailError,
                        passwordError: _passwordError,
                        onUsernameChanged: _handleUsernameChanged,
                        onEmailChanged: _handleEmailChanged,
                        onPasswordChanged: _handlePasswordChanged,
                        onSubmit: _handleSubmit,
                      ),
                      const SizedBox(height: 22),
                      Opacity(
                        opacity: 0.58,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _FooterLink(label: 'REGULAMIN', onTap: () {}),
                            const SizedBox(width: 18),
                            _FooterLink(label: 'PRYWATNOŚĆ', onTap: () {}),
                            const SizedBox(width: 18),
                            _FooterLink(label: 'POMOC', onTap: () {}),
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
    required this.usernameController,
    required this.emailController,
    required this.passwordController,
    required this.usernameError,
    required this.emailError,
    required this.passwordError,
    required this.onUsernameChanged,
    required this.onEmailChanged,
    required this.onPasswordChanged,
    required this.onSubmit,
  });

  final ThemeData theme;
  final ColorScheme scheme;
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final String? usernameError;
  final String? emailError;
  final String? passwordError;
  final ValueChanged<String> onUsernameChanged;
  final ValueChanged<String> onEmailChanged;
  final ValueChanged<String> onPasswordChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: theme.brightness == Brightness.dark ? 0.22 : 0.05,
            ),
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
              'Witaj',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.w700,
                fontSize: 34,
              ),
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: const Icon(Icons.account_circle_outlined),
              label: const Text('Kontynuuj przez Google'),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Divider(color: scheme.outline.withValues(alpha: 0.35)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'LUB',
                  style: theme.textTheme.labelSmall?.copyWith(
                    letterSpacing: 1.2,
                    color: scheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(
                child: Divider(color: scheme.outline.withValues(alpha: 0.35)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _AuthInputField(
            label: 'NAZWA UŻYTKOWNIKA',
            hintText: 'twoja nazwa uzytkownika',
            keyboardType: TextInputType.text,
            obscureText: false,
            controller: usernameController,
            errorText: usernameError,
            onChanged: onUsernameChanged,
          ),
          const SizedBox(height: 10),
          _AuthInputField(
            label: 'E-MAIL',
            hintText: 'twoj@email.pl',
            keyboardType: TextInputType.emailAddress,
            obscureText: false,
            controller: emailController,
            errorText: emailError,
            onChanged: onEmailChanged,
          ),
          const SizedBox(height: 10),
          _AuthInputField(
            label: 'HASŁO',
            hintText: '********',
            keyboardType: TextInputType.visiblePassword,
            obscureText: true,
            controller: passwordController,
            errorText: passwordError,
            onChanged: onPasswordChanged,
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
                'Zarejestruj się',
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
              'Masz już konto?',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              child: Text(
                'Zaloguj się na konto',
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
    this.errorText,
  });

  final String label;
  final String hintText;
  final TextInputType keyboardType;
  final bool obscureText;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1B5E20),
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: keyboardType,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hintText,
            errorText: errorText,
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.black54,
            ),
            filled: true,
            fillColor: const Color(0xFFF1F3F4),
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
              borderSide: const BorderSide(
                color: Color(0xFF2E7D32),
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
  const _FooterLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: scheme.onSurface,
            letterSpacing: 0.8,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
