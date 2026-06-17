import '../../../core/constants/storage_keys.dart';
import '../../../core/services/local_storage_service.dart';
import '../models/game_settings.dart';

class SettingsRepository {
  const SettingsRepository(this._storage);

  final LocalStorageService _storage;

  GameSettings load() {
    return GameSettings(
      soundEnabled: _storage.getBool('${StorageKeys.settingsPrefix}sound',
          fallback: true),
      hapticsEnabled: _storage.getBool(
        '${StorageKeys.settingsPrefix}haptics',
        fallback: true,
      ),
    );
  }

  Future<void> save(GameSettings settings) async {
    await Future.wait([
      _storage.setBool(
          '${StorageKeys.settingsPrefix}sound', settings.soundEnabled),
      _storage.setBool(
          '${StorageKeys.settingsPrefix}haptics', settings.hapticsEnabled),
    ]);
  }
}
