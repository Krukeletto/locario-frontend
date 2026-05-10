import 'package:flutter/material.dart';
import 'package:locario/l10n/app_localizations.dart';

import '../../shared/widgets/state_panel.dart';

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Color.alphaBlend(
      Colors.black.withValues(alpha: 0.18),
      Theme.of(context).colorScheme.primary,
    );
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: StatePanel.empty(
            title: l10n.tabInbox,
            subtitle: l10n.featureComingSoon,
          ),
        ),
      ),
    );
  }
}
