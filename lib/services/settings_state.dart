import 'package:flutter/foundation.dart';
import 'storage_service.dart';

/// تنظیمات برنامه: صدا و لرزش هنگام اسکن
class SettingsState extends ChangeNotifier {
  final StorageService _storage;

  SettingsState({StorageService? storage}) : _storage = storage ?? StorageService();

  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  bool get soundEnabled => _soundEnabled;
  bool get vibrationEnabled => _vibrationEnabled;

  Future<void> initialize() async {
    _soundEnabled = await _storage.loadSoundEnabled();
    _vibrationEnabled = await _storage.loadVibrationEnabled();
    notifyListeners();
  }

  Future<void> setSoundEnabled(bool value) async {
    _soundEnabled = value;
    notifyListeners();
    await _storage.saveSoundEnabled(value);
  }

  Future<void> setVibrationEnabled(bool value) async {
    _vibrationEnabled = value;
    notifyListeners();
    await _storage.saveVibrationEnabled(value);
  }
}
