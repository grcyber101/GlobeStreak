import '../../../core/constants/storage_keys.dart';
import '../../../core/services/local_storage_service.dart';
import '../models/game_statistics.dart';

class StatisticsRepository {
  const StatisticsRepository(this._storage);

  final LocalStorageService _storage;

  GameStatistics load() {
    return GameStatistics(
      gamesPlayed: _storage.getInt(StorageKeys.gamesPlayed),
      bestStreak: _storage.getInt(StorageKeys.bestStreak),
      longestLifeChain: _storage.getInt(StorageKeys.longestLifeChain),
      totalGuesses: _storage.getInt(StorageKeys.totalGuesses),
      correctGuesses: _storage.getInt(StorageKeys.correctGuesses),
      totalDistanceKm: _storage.getDouble(StorageKeys.totalDistanceKm),
    );
  }

  Future<void> recordGuess({
    required double distanceKm,
    required bool success,
    required int currentStreak,
    required int currentLifeChain,
  }) async {
    final stats = load();
    await _save(
      stats.copyWith(
        totalGuesses: stats.totalGuesses + 1,
        correctGuesses: stats.correctGuesses + (success ? 1 : 0),
        totalDistanceKm: stats.totalDistanceKm + distanceKm,
        bestStreak:
            currentStreak > stats.bestStreak ? currentStreak : stats.bestStreak,
        longestLifeChain: currentLifeChain > stats.longestLifeChain
            ? currentLifeChain
            : stats.longestLifeChain,
      ),
    );
  }

  Future<void> recordGameStarted() async {
    final stats = load();
    await _storage.setInt(StorageKeys.gamesPlayed, stats.gamesPlayed + 1);
  }

  Future<void> _save(GameStatistics stats) async {
    await Future.wait([
      _storage.setInt(StorageKeys.gamesPlayed, stats.gamesPlayed),
      _storage.setInt(StorageKeys.bestStreak, stats.bestStreak),
      _storage.setInt(StorageKeys.longestLifeChain, stats.longestLifeChain),
      _storage.setInt(StorageKeys.totalGuesses, stats.totalGuesses),
      _storage.setInt(StorageKeys.correctGuesses, stats.correctGuesses),
      _storage.setDouble(StorageKeys.totalDistanceKm, stats.totalDistanceKm),
    ]);
  }
}
