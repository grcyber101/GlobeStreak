import 'dart:math' as math;

import '../models/city.dart';
import '../seed/city_seed_data.dart';

class CityRepository {
  CityRepository({
    List<City> cities = citySeedData,
    math.Random? random,
  })  : _cities = List.unmodifiable(cities),
        _random = random ?? math.Random();

  final List<City> _cities;
  final math.Random _random;

  List<City> loadCities() => _cities;

  City randomCity({List<City>? from}) {
    final source = from ?? _cities;
    if (source.isEmpty) {
      throw StateError('Cannot select a random city from an empty list.');
    }
    return source[_random.nextInt(source.length)];
  }

  List<City> filterByDifficulty({
    int? minDifficulty,
    int? maxDifficulty,
  }) {
    return _cities.where((city) {
      final aboveMin =
          minDifficulty == null || city.difficulty >= minDifficulty;
      final belowMax =
          maxDifficulty == null || city.difficulty <= maxDifficulty;
      return aboveMin && belowMax;
    }).toList(growable: false);
  }

  List<City> filterByPopulation({
    int? minPopulation,
    int? maxPopulation,
  }) {
    return _cities.where((city) {
      final aboveMin =
          minPopulation == null || city.population >= minPopulation;
      final belowMax =
          maxPopulation == null || city.population <= maxPopulation;
      return aboveMin && belowMax;
    }).toList(growable: false);
  }
}
