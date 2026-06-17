class GameStatistics {
  const GameStatistics({
    required this.gamesPlayed,
    required this.bestStreak,
    required this.longestLifeChain,
    required this.totalGuesses,
    required this.correctGuesses,
    required this.totalDistanceKm,
  });

  const GameStatistics.empty()
      : gamesPlayed = 0,
        bestStreak = 0,
        longestLifeChain = 0,
        totalGuesses = 0,
        correctGuesses = 0,
        totalDistanceKm = 0;

  final int gamesPlayed;
  final int bestStreak;
  final int longestLifeChain;
  final int totalGuesses;
  final int correctGuesses;
  final double totalDistanceKm;

  double get averageDistanceKm =>
      totalGuesses == 0 ? 0 : totalDistanceKm / totalGuesses;

  GameStatistics copyWith({
    int? gamesPlayed,
    int? bestStreak,
    int? longestLifeChain,
    int? totalGuesses,
    int? correctGuesses,
    double? totalDistanceKm,
  }) {
    return GameStatistics(
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      bestStreak: bestStreak ?? this.bestStreak,
      longestLifeChain: longestLifeChain ?? this.longestLifeChain,
      totalGuesses: totalGuesses ?? this.totalGuesses,
      correctGuesses: correctGuesses ?? this.correctGuesses,
      totalDistanceKm: totalDistanceKm ?? this.totalDistanceKm,
    );
  }
}
