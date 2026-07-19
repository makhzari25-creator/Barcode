import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart' show ThemeMode;

/// وضعیت تنظیمات
@immutable
class SettingsState {
  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool autoFlashEnabled;
  final ThemeMode themeMode;
  final int resultDurationMs;
  final bool autoClearEnabled;
  final int autoClearDays;

  const SettingsState({
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.autoFlashEnabled = false,
    this.themeMode = ThemeMode.system,
    this.resultDurationMs = 1500,
    this.autoClearEnabled = true,
    this.autoClearDays = 90,
  });

  SettingsState copyWith({
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? autoFlashEnabled,
    ThemeMode? themeMode,
    int? resultDurationMs,
    bool? autoClearEnabled,
    int? autoClearDays,
  }) {
    return SettingsState(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      autoFlashEnabled: autoFlashEnabled ?? this.autoFlashEnabled,
      themeMode: themeMode ?? this.themeMode,
      resultDurationMs: resultDurationMs ?? this.resultDurationMs,
      autoClearEnabled: autoClearEnabled ?? this.autoClearEnabled,
      autoClearDays: autoClearDays ?? this.autoClearDays,
    );
  }
}

/// State Notifier برای تنظیمات
class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState());

  void toggleSound(bool value) => state = state.copyWith(soundEnabled: value);
  void toggleVibration(bool value) => state = state.copyWith(vibrationEnabled: value);
  void toggleAutoFlash(bool value) => state = state.copyWith(autoFlashEnabled: value);
  void setThemeMode(ThemeMode mode) => state = state.copyWith(themeMode: mode);
  void setResultDuration(int ms) => state = state.copyWith(resultDurationMs: ms);
  void toggleAutoClear(bool value) => state = state.copyWith(autoClearEnabled: value);
  void setAutoClearDays(int days) => state = state.copyWith(autoClearDays: days);
}

/// Provider برای تنظیمات
final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});

/// Provider سریع برای ThemeMode
final themeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(settingsProvider).themeMode;
});
