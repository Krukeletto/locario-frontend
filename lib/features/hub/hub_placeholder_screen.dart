import 'package:flutter/material.dart';
import 'package:locario/l10n/app_localizations.dart';

import '../shell/hub/hub_action_item.dart';
import '../../shared/widgets/state_panel.dart';

class HubPlaceholderScreen extends StatelessWidget {
  const HubPlaceholderScreen({super.key, required this.item});

  final HubActionItem item;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Color.alphaBlend(
      Colors.black.withValues(alpha: 0.18),
      Theme.of(context).colorScheme.primary,
    );
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: StatePanel.empty(
            title: item.title(l10n),
            subtitle: l10n.featureComingSoon,
          ),
        ),
      ),
    );
  }
}
