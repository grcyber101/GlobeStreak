class GameSettings {
  const GameSettings({
    required this.soundEnabled,
    required this.hapticsEnabled,
  });

  const GameSettings.defaults()
      : soundEnabled = true,
        hapticsEnabled = true;

  final bool soundEnabled;
  final bool hapticsEnabled;
}
