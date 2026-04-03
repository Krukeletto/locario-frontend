import 'package:flutter/material.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Color.alphaBlend(
      Colors.black.withValues(alpha: 0.18),
      Theme.of(context).colorScheme.primary,
    );

    return Scaffold(
      backgroundColor: backgroundColor,
      body: const SizedBox.expand(
        // TODO: Implement Saved screen content.
        child: SizedBox.shrink(),
      ),
    );
  }
}
