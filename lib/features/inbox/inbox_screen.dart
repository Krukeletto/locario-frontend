import 'package:flutter/material.dart';

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Color.alphaBlend(
      Colors.black.withValues(alpha: 0.18),
      Theme.of(context).colorScheme.primary,
    );

    return Scaffold(
      backgroundColor: backgroundColor,
      body: const SizedBox.expand(
        // TODO: Implement Inbox screen content.
        child: SizedBox.shrink(),
      ),
    );
  }
}
