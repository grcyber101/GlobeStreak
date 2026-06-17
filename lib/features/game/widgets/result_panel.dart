import 'package:flutter/material.dart';

import '../models/run_guess_summary.dart';

class ResultPanel extends StatelessWidget {
  const ResultPanel({
    super.key,
    required this.status,
    required this.gameOver,
    required this.hasPendingGuess,
    required this.runSummary,
    required this.onConfirmGuess,
    required this.onNewGame,
  });

  final String status;
  final bool gameOver;
  final bool hasPendingGuess;
  final List<RunGuessSummary> runSummary;
  final VoidCallback onConfirmGuess;
  final VoidCallback onNewGame;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (status.isNotEmpty) ...[
              Text(
                status,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 12),
            ],
            if (gameOver && runSummary.isNotEmpty) ...[
              _RunSummaryList(runSummary: runSummary),
              const SizedBox(height: 12),
            ],
            if (gameOver)
              FilledButton.icon(
                onPressed: onNewGame,
                icon: const Icon(Icons.restart_alt),
                label: const Text('New Game'),
              )
            else
              FilledButton.icon(
                onPressed: hasPendingGuess ? onConfirmGuess : null,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Confirm Guess'),
              ),
          ],
        ),
      ),
    );
  }
}

class _RunSummaryList extends StatelessWidget {
  const _RunSummaryList({required this.runSummary});

  final List<RunGuessSummary> runSummary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Run Summary',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 220),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: runSummary.length,
            separatorBuilder: (_, __) => const Divider(height: 12),
            itemBuilder: (context, index) {
              final item = runSummary[index];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 28,
                    child: Text(
                      '${index + 1}.',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item.target.displayName,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${item.distanceKm.round()} km',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
