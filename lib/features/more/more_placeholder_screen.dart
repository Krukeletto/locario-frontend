import 'package:flutter/material.dart';

import '../shell/more/more_action_item.dart';

class MorePlaceholderScreen extends StatelessWidget {
  const MorePlaceholderScreen({super.key, required this.item});

  final MoreActionItem item;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Color.alphaBlend(
      Colors.black.withValues(alpha: 0.18),
      Theme.of(context).colorScheme.primary,
    );

    return Scaffold(
      backgroundColor: backgroundColor,
      body: const SizedBox.expand(
        // TODO: Implement More destination screen content.
        child: SizedBox.shrink(),
      ),
    );
  }
}
