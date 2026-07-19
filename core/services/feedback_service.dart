import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibration/vibration.dart';

import '../../features/scanner/domain/entities/scan_record.dart';
import '../../features/settings/presentation/providers/settings_provider.dart';

/// نوع بازخورد
enum FeedbackType {
  /// موفقیت (سبز)
  success,
  /// خطا (قرمز)
  error,
  /// هشدار (زرد)
  warning,
}

/// سرویس بازخورد (صدا و لرزش)
class FeedbackService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final bool _soundEnabled;
  final bool _vibrationEnabled;

  FeedbackService(this._soundEnabled, this._vibrationEnabled);

  /// پخش بازخورد بر اساس وضعیت اسکن (برای backward compatibility)
  Future<void> playFeedback(ScanStatus status) async {
    final type = switch (status) {
      ScanStatus.valid => FeedbackType.success,
      ScanStatus.invalid => FeedbackType.error,
      ScanStatus.duplicate => FeedbackType.warning,
    };
    await playFeedbackByType(type);
  }

  /// پخش بازخورد بر اساس نوع
  Future<void> playFeedbackByType(FeedbackType type) async {
    if (_soundEnabled) {
      await _playSound(type);
    }
    if (_vibrationEnabled) {
      await _vibrate(type);
    }
  }

  Future<void> _playSound(FeedbackType type) async {
    try {
      final soundFile = switch (type) {
        FeedbackType.success => 'sounds/success.mp3',
        FeedbackType.error => 'sounds/error.mp3',
        FeedbackType.warning => 'sounds/duplicate.mp3',
      };
      await _audioPlayer.play(AssetSource(soundFile));
    } catch (_) {}
  }

  Future<void> _vibrate(FeedbackType type) async {
    try {
      final pattern = switch (type) {
        FeedbackType.success => const [100],
        FeedbackType.error => const [200, 100, 200],
        FeedbackType.warning => const [150, 80, 150],
      };
      await Vibration.vibrate(pattern: pattern);
    } catch (_) {}
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}

/// Provider برای FeedbackService
final feedbackServiceProvider = Provider<FeedbackService>((ref) {
  final settings = ref.watch(settingsProvider);
  final service = FeedbackService(settings.soundEnabled, settings.vibrationEnabled);
  ref.onDispose(service.dispose);
  return service;
});
