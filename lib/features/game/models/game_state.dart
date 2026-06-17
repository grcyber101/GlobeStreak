import '../../../core/constants/game_constants.dart';

class GameState {
  const GameState({
    required this.streak,
    required this.bestStreak,
    required this.globeLives,
  });

  const GameState.initial({this.bestStreak = 0})
      : streak = 0,
        globeLives = GameConstants.startingLives;

  final int streak;
  final int bestStreak;
  final int globeLives;

  bool get isGameOver => globeLives <= 0;

  GameState copyWith({
    int? streak,
    int? bestStreak,
    int? globeLives,
  }) {
    return GameState(
      streak: streak ?? this.streak,
      bestStreak: bestStreak ?? this.bestStreak,
      globeLives: globeLives ?? this.globeLives,
    );
  }
}
