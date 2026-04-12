import 'package:flutter/material.dart';

import '../shell/hub/hub_action_item.dart';

class HubPlaceholderScreen extends StatelessWidget {
  const HubPlaceholderScreen({super.key, required this.item});

  final HubActionItem item;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Color.alphaBlend(
      Colors.black.withValues(alpha: 0.18),
      Theme.of(context).colorScheme.primary,
    );

    return Scaffold(
      backgroundColor: backgroundColor,
      body: const SizedBox.expand(
        // TODO: Implement Hub destination screen content.
        child: SizedBox.shrink(),
      ),
    );
  }
}
