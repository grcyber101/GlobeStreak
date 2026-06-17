import 'package:flutter/material.dart';

import 'core/services/local_storage_service.dart';
import 'core/theme/geo_streak_theme.dart';
import 'data/repositories/city_repository.dart';
import 'data/repositories/globe_geometry_repository.dart';
import 'features/game/screens/game_screen.dart';
import 'features/stats/controllers/statistics_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = await LocalStorageService.create();
  runApp(
    GeoStreakApp(
      cityRepository: CityRepository(),
      globeGeometryRepository: const GlobeGeometryRepository(),
      statisticsRepository: StatisticsRepository(storage),
    ),
  );
}

class GeoStreakApp extends StatelessWidget {
  const GeoStreakApp({
    super.key,
    required this.cityRepository,
    required this.globeGeometryRepository,
    required this.statisticsRepository,
  });

  final CityRepository cityRepository;
  final GlobeGeometryRepository globeGeometryRepository;
  final StatisticsRepository statisticsRepository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GlobeStreak',
      debugShowCheckedModeBanner: false,
      theme: GeoStreakTheme.dark(),
      home: GameScreen(
        cityRepository: cityRepository,
        globeGeometryRepository: globeGeometryRepository,
        statisticsRepository: statisticsRepository,
      ),
    );
  }
}
