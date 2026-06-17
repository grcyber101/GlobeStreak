import 'package:flutter/material.dart';

import '../../../core/services/country_lookup_service.dart';
import '../../../data/models/geo_point.dart';
import '../../../data/models/globe_geometry.dart';
import '../../../data/repositories/city_repository.dart';
import '../../../data/repositories/globe_geometry_repository.dart';
import '../../../shared/layouts/responsive_game_layout.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../stats/controllers/statistics_repository.dart';
import '../controllers/game_controller.dart';
import '../widgets/game_hud.dart';
import '../widgets/game_prompt.dart';
import '../widgets/globe_guess_widget.dart';
import '../widgets/result_panel.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    required this.cityRepository,
    required this.globeGeometryRepository,
    required this.statisticsRepository,
  });

  final CityRepository cityRepository;
  final GlobeGeometryRepository globeGeometryRepository;
  final StatisticsRepository statisticsRepository;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameController _controller;
  late final GlobeGeometry _globeGeometry;
  GeoPoint? _pendingGuess;
  var _initialized = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    _globeGeometry = await widget.globeGeometryRepository.loadGeometry();
    _controller = GameController(
      cityRepository: widget.cityRepository,
      statisticsRepository: widget.statisticsRepository,
      countryLookupService: CountryLookupService(_globeGeometry.countries),
    );
    await _controller.initialize();
    if (!mounted) return;
    setState(() => _initialized = true);
  }

  void _selectGuess(double lat, double lng) {
    setState(() {
      _pendingGuess = GeoPoint(latitude: lat, longitude: lng);
    });
  }

  Future<void> _confirmGuess() async {
    final pendingGuess = _pendingGuess;
    if (pendingGuess == null) return;

    await _controller.submitGuess(
      pendingGuess.latitude,
      pendingGuess.longitude,
    );
    if (!mounted) return;
    setState(() {
      _pendingGuess = null;
    });
  }

  Future<void> _newGame() async {
    await _controller.newGame();
    if (!mounted) return;
    setState(() {
      _pendingGuess = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const LoadingView();
    }

    final gameOver = _controller.state.isGameOver;
    final status = _pendingGuess == null ? _controller.status : '';
    return Scaffold(
      body: ResponsiveGameLayout(
        prompt: GamePrompt(target: _controller.target, gameOver: gameOver),
        hud: GameHud(state: _controller.state),
        globe: GlobeGuessWidget(
          geometry: _globeGeometry,
          enabled: !gameOver,
          pendingGuess: _pendingGuess,
          lastGuess: _pendingGuess == null ? _controller.lastGuess : null,
          onGuessSelected: _selectGuess,
        ),
        results: ResultPanel(
          status: status,
          gameOver: gameOver,
          hasPendingGuess: _pendingGuess != null,
          runSummary: _controller.runSummary,
          onConfirmGuess: _confirmGuess,
          onNewGame: _newGame,
        ),
      ),
    );
  }
}
