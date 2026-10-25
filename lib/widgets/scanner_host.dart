import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';
import '../services/settings_state.dart';
import '../services/sound_service.dart';

/// منطق مشترک صفحه‌های اسکن (چک کردن شارژ و شارژ سالن):
/// - ساخت و نابودی کنترلر دوربین
/// - توقف دوربین پس از هر اسکن تا نتیجه دیده شود، و ادامه‌ی اسکن
/// - صدا و لرزش با توجه به تنظیمات
mixin ScannerHost<T extends StatefulWidget> on State<T> {
  MobileScannerController? scannerController;
  bool scannerReady = false;
  bool torchOn = false;

  /// دوربین پس از اسکن متوقف شده و منتظر «اسکن بعدی» است
  bool scanPaused = false;

  bool _busy = false;
  DateTime _ignoreUntil = DateTime.fromMillisecondsSinceEpoch(0);
  final SoundService soundService = SoundService();

  /// پردازش یک کد (از دوربین یا ورود دستی). پیاده‌سازی در هر صفحه.
  Future<void> handleCode(String code);

  void initScanner() {
    if (scannerController != null) {
      setState(() => scannerReady = true);
      return;
    }
    scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
    setState(() => scannerReady = true);
  }

  /// اگر فایل بعد از باز شدن صفحه بارگذاری شد (مثلاً داده‌ی ذخیره‌شده دیر
  /// خوانده شد)، اسکنر هم باید ساخته شود؛ در غیر این صورت قاب دوربین همیشه
  /// در حال بارگذاری می‌ماند. این تابع را در build صدا بزنید.
  void ensureScanner({required bool hasFile}) {
    if (!hasFile || scannerController != null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && scannerController == null) initScanner();
    });
  }

  Future<void> toggleTorch() async {
    try {
      await scannerController?.toggleTorch();
      if (mounted) setState(() => torchOn = !torchOn);
    } catch (_) {}
  }

  Future<void> pauseScanner() async {
    try {
      await scannerController?.stop();
    } catch (_) {}
  }

  /// ادامه‌ی اسکن؛ تا نیم‌ثانیه تشخیص‌ها نادیده گرفته می‌شود تا همان بارکدِ
  /// هنوز مقابل دوربین دوباره شمرده نشود.
  Future<void> resumeScanner() async {
    _ignoreUntil = DateTime.now().add(const Duration(milliseconds: 600));
    try {
      await scannerController?.start();
    } catch (_) {}
    if (mounted) setState(() => scanPaused = false);
  }

  Future<void> onDetect(BarcodeCapture capture) async {
    if (_busy || scanPaused) return;
    if (DateTime.now().isBefore(_ignoreUntil)) return;
    if (capture.barcodes.isEmpty) return;
    final code = capture.barcodes.first.rawValue ?? '';
    if (code.trim().isEmpty) return;
    await processCode(code);
  }

  /// ورودی مشترک برای دوربین و ورود دستی
  Future<void> processCode(String code) async {
    if (_busy) return;
    _busy = true;
    try {
      await pauseScanner();
      if (mounted) setState(() => scanPaused = true);
      await handleCode(code);
    } finally {
      _busy = false;
    }
  }

  /// صدا و لرزش تایید/رد بر اساس تنظیمات
  Future<void> giveFeedback({required bool ok}) async {
    if (!mounted) return;
    final settings = context.read<SettingsState>();
    if (settings.soundEnabled) {
      unawaited(ok ? soundService.playSuccess() : soundService.playError());
    }
    if (settings.vibrationEnabled) {
      try {
        await Vibration.vibrate(duration: ok ? 80 : 200);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    scannerController?.dispose();
    soundService.dispose();
    super.dispose();
  }
}
