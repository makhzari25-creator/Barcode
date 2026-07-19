import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../injection.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../domain/entities/scan_record.dart';
import '../../domain/usecases/scan_usecases.dart';

/// وضعیت صفحه اسکنر
@immutable
class ScannerState {
  final bool isFlashOn;
  final bool isScanning;
  final ScanStatus? lastResult;
  final String? lastBarcode;
  final String? lastProductName;
  final int todayCount;
  final String? errorMessage;

  const ScannerState({
    this.isFlashOn = false,
    this.isScanning = true,
    this.lastResult,
    this.lastBarcode,
    this.lastProductName,
    this.todayCount = 0,
    this.errorMessage,
  });

  ScannerState copyWith({
    bool? isFlashOn,
    bool? isScanning,
    ScanStatus? lastResult,
    String? lastBarcode,
    String? lastProductName,
    int? todayCount,
    String? errorMessage,
  }) {
    return ScannerState(
      isFlashOn: isFlashOn ?? this.isFlashOn,
      isScanning: isScanning ?? this.isScanning,
      lastResult: lastResult ?? this.lastResult,
      lastBarcode: lastBarcode ?? this.lastBarcode,
      lastProductName: lastProductName ?? this.lastProductName,
      todayCount: todayCount ?? this.todayCount,
      errorMessage: errorMessage,
    );
  }

  factory ScannerState.initial() => const ScannerState();
}

/// State Notifier برای اسکنر
class ScannerNotifier extends StateNotifier<ScannerState> {
  final ValidateBarcodeUseCase _validateBarcodeUseCase;
  final SaveScanUseCase _saveScanUseCase;
  final GetScanStatsUseCase _getScanStatsUseCase;
  final AuthState _authState;
  final SettingsState _settings;

  DateTime? _lastScanTime;
  static const _cooldownMs = 1000;

  ScannerNotifier(
    this._validateBarcodeUseCase,
    this._saveScanUseCase,
    this._getScanStatsUseCase,
    this._authState,
    this._settings,
  ) : super(ScannerState.initial()) {
    _loadTodayCount();
  }

  /// بارگذاری تعداد اسکن‌های امروز
  Future<void> _loadTodayCount() async {
    try {
      final today = _todayDate();
      final result = await _getScanStatsUseCase(startDate: today, endDate: today);
      result.fold(
        (_) {},
        (stats) => state = state.copyWith(todayCount: stats.total),
      );
    } catch (_) {}
  }

  /// روشن/خاموش کردن فلش
  void toggleFlash() {
    state = state.copyWith(isFlashOn: !state.isFlashOn);
  }

  /// شروع/توقف اسکن
  void toggleScanning() {
    state = state.copyWith(isScanning: !state.isScanning);
  }

  /// پردازش بارکد اسکن‌شده
  /// این متد از طرف صفحه اسکنر فراخوانی می‌شود
  Future<ScanStatus> processScannedBarcode(String code) async {
    // Cooldown - جلوگیری از اسکن تکراری
    final now = DateTime.now();
    if (_lastScanTime != null) {
      final diff = now.difference(_lastScanTime!).inMilliseconds;
      if (diff < _cooldownMs) {
        return state.lastResult ?? ScanStatus.invalid;
      }
    }
    _lastScanTime = now;

    if (!_authState.isAuthenticated || _authState.user == null) {
      state = state.copyWith(errorMessage: 'کاربر وارد نشده است');
      return ScanStatus.invalid;
    }

    try {
      // اعتبارسنجی بارکد
      final result = await _validateBarcodeUseCase(code);

      // ثبت اسکن در دیتابیس
      final scan = ScanRecord(
        userId: _authState.user!.id!,
        barcode: code,
        status: result.status,
        scannedAt: now,
        dateOnly: _todayDate(),
        timeOnly: _formatTime(now),
        deviceInfo: null,
      );

      await _saveScanUseCase(scan);

      // به‌روزرسانی وضعیت
      state = state.copyWith(
        lastResult: result.status,
        lastBarcode: code,
        lastProductName: result.barcode?.productName,
        todayCount: state.todayCount + 1,
      );

      return result.status;
    } catch (e) {
      state = state.copyWith(errorMessage: 'خطا در پردازش: $e');
      return ScanStatus.invalid;
    }
  }

  /// پاک کردن نتیجه آخر
  void clearLastResult() {
    state = state.copyWith(
      lastResult: null,
      lastBarcode: null,
      lastProductName: null,
    );
  }

  String _todayDate() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}:'
        '${dt.second.toString().padLeft(2, '0')}';
  }
}

/// Provider برای ScannerNotifier
final scannerProvider = StateNotifierProvider<ScannerNotifier, ScannerState>((ref) {
  return ScannerNotifier(
    ref.watch(validateBarcodeUseCaseProvider),
    ref.watch(saveScanUseCaseProvider),
    ref.watch(getScanStatsUseCaseProvider),
    ref.watch(authStateProvider),
    ref.watch(settingsProvider),
  );
});
