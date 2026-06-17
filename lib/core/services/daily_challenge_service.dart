import 'dart:math' as math;

import '../../data/models/city.dart';
import '../../data/repositories/city_repository.dart';

class DailyChallengeService {
  const DailyChallengeService(this._cityRepository);

  final CityRepository _cityRepository;

  List<City> sequenceForDate(DateTime date, {int count = 20}) {
    final seed = date.year * 10000 + date.month * 100 + date.day;
    final random = math.Random(seed);
    final cities = List<City>.of(_cityRepository.loadCities());
    final sequence = <City>[];

    while (sequence.length < count && cities.isNotEmpty) {
      sequence.add(cities.removeAt(random.nextInt(cities.length)));
      if (cities.isEmpty && sequence.length < count) {
        cities.addAll(_cityRepository.loadCities());
      }
    }

    return sequence;
  }
}
