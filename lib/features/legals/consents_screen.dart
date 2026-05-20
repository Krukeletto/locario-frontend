import 'package:flutter/material.dart';
import 'package:locario/l10n/app_localizations.dart';

import 'consent_type.dart';
import 'consents_store.dart';
import 'shared_prefs_consents_store.dart';

class ConsentsScreen extends StatefulWidget {
  const ConsentsScreen({super.key});

  @override
  State<ConsentsScreen> createState() => _ConsentsScreenState();
}

class _ConsentsScreenState extends State<ConsentsScreen> {
  final ConsentsStore _store = const SharedPrefsConsentsStore();
  Map<ConsentType, bool> _consents = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConsents();
  }

  Future<void> _loadConsents() async {
    final consents = await _store.loadAll();
    if (!mounted) {
      return;
    }
    setState(() {
      _consents = consents;
      _isLoading = false;
    });
  }

  Future<void> _toggle(ConsentType type, bool value) async {
    await _store.setGranted(type, value);
    setState(() {
      _consents[type] = value;
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
          l10n.legalConsentsTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            color: scheme.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: scheme.outline.withValues(alpha: 0.28),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.legalConsentsSectionTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.legalConsentsSectionSubtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.72),
                        ),
                      ),
                      const SizedBox(height: 14),
                      for (final type in ConsentType.values)
                        _ConsentToggle(
                          type: type,
                          granted: _consents[type] ?? false,
                          onChanged: (value) => _toggle(type, value),
                        ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _ConsentToggle extends StatelessWidget {
  const _ConsentToggle({
    required this.type,
    required this.granted,
    required this.onChanged,
  });

  final ConsentType type;
  final bool granted;
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
              color: granted
                  ? scheme.primary.withValues(alpha: 0.12)
                  : scheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              type.icon,
              color: granted
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
                  type.label(l10n),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
                Text(
                  type.description(l10n),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.56),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch.adaptive(value: granted, onChanged: onChanged),
        ],
      ),
    );
  }
}
