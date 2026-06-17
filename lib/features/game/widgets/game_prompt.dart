import 'package:flutter/material.dart';

import '../../../data/models/city.dart';

class GamePrompt extends StatelessWidget {
  const GamePrompt({
    super.key,
    required this.target,
    required this.gameOver,
  });

  final City target;
  final bool gameOver;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          gameOver ? 'Streak Ended' : 'Locate: ${target.displayName}',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
