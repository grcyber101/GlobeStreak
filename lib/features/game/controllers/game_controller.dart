import 'dart:math' as math;

import '../../../core/constants/game_constants.dart';
import '../../../core/services/country_lookup_service.dart';
import '../../../core/utils/geo_math.dart';
import '../../../data/models/city.dart';
import '../../../data/repositories/city_repository.dart';
import '../../stats/controllers/statistics_repository.dart';
import '../models/game_state.dart';
import '../models/guess.dart';
import '../models/guess_result.dart';
import '../models/run_guess_summary.dart';

class GameController {
  GameController({
    required CityRepository cityRepository,
    required StatisticsRepository statisticsRepository,
    required CountryLookupService countryLookupService,
  })  : _cityRepository = cityRepository,
        _statisticsRepository = statisticsRepository,
        _countryLookupService = countryLookupService;

  final CityRepository _cityRepository;
  final StatisticsRepository _statisticsRepository;
  final CountryLookupService _countryLookupService;
  final math.Random _random = math.Random();

  late City target;
  late GameState state;
  List<City> _remainingRunCities = const [];
  final List<RunGuessSummary> _runSummary = [];
  Guess? lastGuess;
  GuessResult? lastResult;
  String status = '';
  int _currentLifeChain = 0;

  List<RunGuessSummary> get runSummary => List.unmodifiable(_runSummary);

  Future<void> initialize() async {
    final stats = _statisticsRepository.load();
    state = GameState.initial(bestStreak: stats.bestStreak);
    _resetRunCityQueue();
    target = _nextRunCity();
    await _statisticsRepository.recordGameStarted();
  }

  Future<void> newGame() async {
    final bestStreak =
        math.max(state.bestStreak, _statisticsRepository.load().bestStreak);
    state = GameState.initial(bestStreak: bestStreak);
    lastGuess = null;
    lastResult = null;
    _runSummary.clear();
    _resetRunCityQueue();
    target = _nextRunCity();
    status = '';
    _currentLifeChain = 0;
    await _statisticsRepository.recordGameStarted();
  }

  Future<void> submitGuess(double lat, double lng) async {
    if (state.isGameOver) return;

    final distance = haversineKm(lat, lng, target.latitude, target.longitude);
    final guessedCountry = _countryLookupService.countryFor(
      latitude: lat,
      longitude: lng,
    );
    final targetCountry =
        CountryLookupService.normalizeCountryName(target.country);
    final wrongCountry =
        guessedCountry != null && guessedCountry != targetCountry;
    final tooFar = distance > GameConstants.lifeLossDistanceKm;
    final success = !wrongCountry && !tooFar;
    final nextStreak = state.streak + 1;

    lastGuess = Guess(
      guessLat: lat,
      guessLng: lng,
      answerLat: target.latitude,
      answerLng: target.longitude,
    );
    lastResult = GuessResult(
      distanceKm: distance,
      success: success,
    );
    _runSummary.add(
      RunGuessSummary(
        target: target,
        distanceKm: distance,
        success: success,
      ),
    );

    if (success) {
      final earnsLife = distance < GameConstants.bonusLifeDistanceKm;
      final nextLives = earnsLife ? state.globeLives + 1 : state.globeLives;
      _currentLifeChain++;
      state = state.copyWith(
        streak: nextStreak,
        bestStreak: math.max(state.bestStreak, nextStreak),
        globeLives: nextLives,
      );
      status = earnsLife
          ? 'Correct! ${distance.round()} km away. Streak +1, Life +1.'
          : 'Correct! ${distance.round()} km away. Streak +1.';
    } else {
      _currentLifeChain = 0;
      final nextLives = state.globeLives - 1;
      state = state.copyWith(
        streak: nextStreak,
        bestStreak: math.max(state.bestStreak, nextStreak),
        globeLives: nextLives,
      );
      status = wrongCountry
          ? 'Missed! ${distance.round()} km away. Your guess was in another country. Life -1.'
          : 'Missed! ${distance.round()} km away. Your guess was over ${GameConstants.lifeLossDistanceKm.round()} km away. Streak +1, globe -1';
      if (nextLives <= 0) {
        status = 'Game over. Final streak: ${state.streak}.';
      }
    }

    await _statisticsRepository.recordGuess(
      distanceKm: distance,
      success: success,
      currentStreak: state.streak,
      currentLifeChain: _currentLifeChain,
    );

    if (!state.isGameOver) {
      target = _nextRunCity();
    }
  }

  void _resetRunCityQueue() {
    _remainingRunCities = List<City>.of(_cityRepository.loadCities())
      ..shuffle(_random);
  }

  City _nextRunCity() {
    if (_remainingRunCities.isEmpty) {
      throw StateError('GlobeStreak has no unguessed cities left in this run.');
    }
    return _remainingRunCities.removeLast();
  }
}
