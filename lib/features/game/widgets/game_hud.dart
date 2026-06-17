import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/geo_streak_colors.dart';
import '../models/game_state.dart';

class GameHud extends StatelessWidget {
  const GameHud({
    super.key,
    required this.state,
  });

  final GameState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final safeLives = math.max(state.globeLives, 0);
    final globeLives = _formatLives(safeLives);

    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      runSpacing: 10,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.public, size: 32),
            const SizedBox(width: 10),
            Text(
              'GlobeStreak',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _HudPill(label: 'Best', value: '${state.bestStreak}'),
            _HudPill(label: 'Streak', value: '${state.streak}'),
            _HudPill(label: 'Lives', value: globeLives),
          ],
        ),
      ],
    );
  }

  String _formatLives(int lives) {
    final globe = String.fromCharCode(0x1F30D);
    if (lives == 0) return '0';
    if (lives <= 8) return List.filled(lives, globe).join();
    return '$globe x$lives';
  }
}

class _HudPill extends StatelessWidget {
  const _HudPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: GeoStreakColors.whiteText.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: GeoStreakColors.whiteText.withValues(alpha: 0.12),
        ),
      ),
      child: Text('$label $value'),
    );
  }
}
