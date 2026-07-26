import 'dart:async';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../services/app_state.dart';
import '../services/sound_service.dart';
import '../theme/app_colors.dart';

/// صفحه چک کردن شارژ
/// 1. اگر فایل اکسل انتخاب نشده، اول از کاربر می‌خواهد فایل را انتخاب کند
/// 2. بارکدخوان دوربین فعال می‌شود
/// 3. بعد از هر اسکن، نتیجه نمایش داده می‌شود
class CheckChargeScreen extends StatefulWidget {
  const CheckChargeScreen({super.key});

  @override
  State<CheckChargeScreen> createState() => _CheckChargeScreenState();
}

class _CheckChargeScreenState extends State<CheckChargeScreen> {
  MobileScannerController? _scannerController;
  bool _scannerReady = false;
  bool _isProcessing = false;
  bool _torchOn = false;
  final SoundService _soundService = SoundService();

  @override
  void initState() {
    super.initState();
    // اگر فایل اکسل از قبل بارگذاری شده، بارکدخوان را فعال می‌کنیم
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && context.read<AppState>().hasFile) {
        _initScanner();
      }
    });
  }

  void _initScanner() {
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
    setState(() => _scannerReady = true);
  }

  @override
  void dispose() {
    _scannerController?.dispose();
    _soundService.dispose();
    super.dispose();
  }

  Future<void> _pickExcelFile() async {
    final state = context.read<AppState>();
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        withData: false,
      );
      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;
      final path = file.path;
      if (path == null) return;

      final ok = await state.loadExcelFile(path, fileName: file.name);
      if (!mounted) return;
      if (ok) {
        _showSnack('فایل با موفقیت بارگذاری شد (${state.products.length} کالا).',
            color: const Color(0xFF43A047));
        _initScanner();
      } else {
        _showSnack(state.error ?? 'بارگذاری فایل ناموفق بود.', color: Colors.red);
      }
    } catch (e) {
      if (!mounted) return;
      _showSnack('خطا در انتخاب فایل: $e', color: Colors.red);
    }
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final code = barcodes.first.rawValue ?? '';
    if (code.isEmpty) return;

    await _processCode(code);
  }

  /// پردازش یک کد بارکد (چه از دوربین، چه از ورود دستی)
  /// دوربین حین پردازش متوقف و بعد از آن مجدداً راه‌اندازی می‌شود؛
  /// همین کار باعث می‌شود دیگر نیازی به خروج و ورود مجدد به صفحه برای
  /// بهتر شدن کیفیت اسکن نباشد و از خواندن‌های اشتباه/ناخواسته حین
  /// نمایش نتیجه (وقتی دوربین هنوز روشن است) جلوگیری می‌کند.
  Future<void> _processCode(String code) async {
    if (_isProcessing) return;
    _isProcessing = true;

    // متوقف کردن دوربین تا زمانی که نتیجه این اسکن نمایش داده می‌شود
    try {
      await _scannerController?.stop();
    } catch (_) {}

    try {
      final state = context.read<AppState>();
      final wasComplete = state.isFullyComplete;
      final result = await state.recordScan(code);

      // صدای واقعی و قابل‌شنیدن: تن متفاوت برای موفق/رد
      if (result == ScanResult.notFound) {
        unawaited(_soundService.playError());
      } else {
        unawaited(_soundService.playSuccess());
      }

      // لرزش کوتاه برای فیدبک فیزیکی
      try {
        await Vibration.vibrate(duration: 80);
      } catch (_) {}

      if (!mounted) return;
      await _showResultDialog(context, code, result, state);

      // اگر همین اسکن باعث تکمیل شدن همه کالاها شد، پیام بزرگ تکمیل را نشان بده
      if (!wasComplete && state.isFullyComplete) {
        if (!mounted) return;
        await _showAllCompleteDialog();
      }
    } finally {
      // راه‌اندازی دوباره دوربین (ریست کامل session تشخیص) برای اسکن بعدی
      if (mounted && _scannerController != null) {
        try {
          await _scannerController!.start();
        } catch (_) {}
      }
      _isProcessing = false;
    }
  }

  /// ورود دستی (یا صوتی) کد بارکد، برای مواردی که دوربین قادر به تشخیص بارکد نیست
  Future<void> _showManualEntryDialog() async {
    // دوربین را حین باز بودن کادر ورود دستی/صوتی متوقف می‌کنیم
    try {
      await _scannerController?.stop();
    } catch (_) {}

    final entered = await showDialog<String>(
      context: context,
      builder: (_) => const _VoiceManualEntryDialog(),
    );

    final code = entered?.trim() ?? '';
    if (code.isEmpty) {
      // کاربر انصراف داد؛ دوربین را دوباره روشن کن
      if (mounted && _scannerController != null) {
        try {
          await _scannerController!.start();
        } catch (_) {}
      }
      return;
    }

    await _processCode(code);
  }

  /// پیام بزرگ تکمیل شدن همه کالاها
  Future<void> _showAllCompleteDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(28),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: const Color(0xFF43A047).withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.celebration_rounded,
                color: Color(0xFF43A047),
                size: 68,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'تکمیل شد!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Color(0xFF43A047),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'همه کالاهای شارژ سالن به تعداد لازم اسکن شدند.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                height: 1.6,
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF43A047),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(54),
              ),
              child: const Text('باشه'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showResultDialog(
    BuildContext ctx,
    String code,
    ScanResult result,
    AppState state,
  ) async {
    final product = state.findProduct(code);
    final scanned = state.scannedCountFor(code);

    String title;
    String message;
    Color color;
    IconData icon;

    switch (result) {
      case ScanResult.notFound:
        title = 'این کالا در شارژ سالن نیست';
        message = 'کد: $code';
        color = const Color(0xFFE53935);
        icon = Icons.error_outline_rounded;
        break;
      case ScanResult.scanned:
        title = 'اسکن شد';
        message = '${product?.title ?? ""}\n'
            'اسکن شده: $scanned از ${product?.requiredCount ?? 0}';
        color = const Color(0xFF1565C0);
        icon = Icons.check_circle_outline_rounded;
        break;
      case ScanResult.justCompleted:
        title = 'شارژ این کالا کامل شد';
        message = '${product?.title ?? ""}\n'
            'اسکن شده: $scanned از ${product?.requiredCount ?? 0}';
        color = const Color(0xFF43A047);
        icon = Icons.verified_rounded;
        break;
      case ScanResult.alreadyComplete:
        title = 'شارژ این کالا قبلاً کامل شده';
        message = '${product?.title ?? ""}\n'
            'اسکن شده: $scanned از ${product?.requiredCount ?? 0}';
        color = const Color(0xFF43A047);
        icon = Icons.verified_rounded;
        break;
    }

    if (!mounted) return;
    await showDialog(
      context: ctx,
      barrierDismissible: true,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 52),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                height: 1.6,
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(54),
              ),
              child: const Text('ادامه اسکن'),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnack(String message, {Color color = Colors.black87}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'Vazirmatn',
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _showResetDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ریست شمارنده‌ها'),
        content: const Text(
          'آیا مطمئن هستید که می‌خواهید شمارنده همه کالاها را صفر کنید؟ '
          'لیست کالاها باقی می‌ماند.',
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('انصراف'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('ریست'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await context.read<AppState>().resetCounters();
      _showSnack('شمارنده‌ها ریست شدند.', color: const Color(0xFF43A047));
    }
  }

  Future<void> _showReplaceFileDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('جایگزینی فایل اکسل'),
        content: const Text(
          'فایل و نتیجه‌ی اسکن‌های فعلی به‌طور کامل به «بایگانی» منتقل می‌شود و '
          'فایل جدید کاملاً از صفر شروع می‌شود (بدون هیچ شمارنده‌ی قبلی).',
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('انصراف'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('انتخاب فایل'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _pickExcelFile();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    if (state.loading && !state.hasFile) {
      return Scaffold(
        appBar: AppBar(title: const Text('چک کردن شارژ')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (!state.hasFile) {
      // مرحله 1: انتخاب فایل اکسل
      return Scaffold(
        appBar: AppBar(title: const Text('چک کردن شارژ')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.table_view_rounded,
                    size: 70,
                    color: Color(0xFF1565C0),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'ابتدا فایل اکسل شارژ سالن را انتخاب کنید',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'فرمت‌های پشتیبانی‌شده: xlsx و xls',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 70,
                  child: ElevatedButton.icon(
                    onPressed: _pickExcelFile,
                    icon: const Icon(Icons.file_upload_rounded, size: 30),
                    label: const Text('انتخاب فایل اکسل'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // مرحله 2: نمایش بارکدخوان + پنل وضعیت
    return Scaffold(
      appBar: AppBar(
        title: const Text('چک کردن شارژ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.keyboard_alt_rounded),
            tooltip: 'ورود دستی بارکد',
            onPressed: _showManualEntryDialog,
          ),
          IconButton(
            icon: Icon(_torchOn
                ? Icons.flash_on_rounded
                : Icons.flash_off_rounded),
            tooltip: 'فلش',
            onPressed: () {
              _scannerController?.toggleTorch();
              setState(() => _torchOn = !_torchOn);
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'ریست شمارنده‌ها',
            onPressed: _showResetDialog,
          ),
          IconButton(
            icon: const Icon(Icons.swap_horiz_rounded),
            tooltip: 'جایگزینی فایل اکسل',
            onPressed: _showReplaceFileDialog,
          ),
          IconButton(
            icon: const Icon(Icons.archive_outlined),
            tooltip: 'بایگانی',
            onPressed: () => Navigator.of(context).pushNamed('/archive'),
          ),
        ],
      ),
      body: Column(
        children: [
          // نوار اطلاعات فایل
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: const Color(0xFF1565C0).withOpacity(0.08),
            child: Row(
              children: [
                const Icon(Icons.table_chart_rounded,
                    color: Color(0xFF1565C0), size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    state.excelFileName ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1565C0),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${state.products.length} کالا',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),

          // بخش دوربین (بارکدخوان)
          Expanded(
            flex: 3,
            child: _scannerReady && _scannerController != null
                ? Stack(
                    children: [
                      MobileScanner(
                        controller: _scannerController!,
                        onDetect: _onDetect,
                      ),
                      // قاب اسکن در مرکز
                      Center(
                        child: Container(
                          width: 250,
                          height: 250,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFF42A5F5),
                              width: 3,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      // راهنما
                      Positioned(
                        bottom: 16,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'بارکد را داخل قاب قرار دهید',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // بنر بزرگ تکمیل شدن همه کالاها
                      if (state.isFullyComplete)
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 12),
                            color: const Color(0xFF43A047),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.verified_rounded,
                                    color: Colors.white, size: 26),
                                SizedBox(width: 8),
                                Text(
                                  'تکمیل شد',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  )
                : const Center(
                    child: CircularProgressIndicator(),
                  ),
          ),

          // پنل وضعیت کالاها
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'آخرین وضعیت کالاها',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        '${_countCompleted(state)}/${state.products.length} تکمیل‌شده',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF43A047),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _LastScannedList(state: state),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _countCompleted(AppState state) {
    int c = 0;
    for (final p in state.products) {
      final scanned = state.scannedCountFor(p.code);
      if (p.requiredCount > 0 && scanned >= p.requiredCount) {
        c++;
      }
    }
    return c;
  }
}

/// لیست آخرین کالاهای اسکن‌شده یا همه کالاها
class _LastScannedList extends StatelessWidget {
  final AppState state;
  const _LastScannedList({required this.state});

  @override
  Widget build(BuildContext context) {
    // ابتدا کالاهای اسکن‌شده، بعد بقیه
    final sorted = [...state.products]..sort((a, b) {
        final sa = state.scannedCountFor(a.code);
        final sb = state.scannedCountFor(b.code);
        if (sa > 0 && sb == 0) return -1;
        if (sa == 0 && sb > 0) return 1;
        if (sa > 0 && sb > 0) return sb.compareTo(sa);
        return 0;
      });

    if (sorted.isEmpty) {
      return const Center(
        child: Text('هنوز کالایی اسکن نشده است.'),
      );
    }

    return ListView.separated(
      itemCount: sorted.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final p = sorted[i];
        final scanned = state.scannedCountFor(p.code);
        final isComplete =
            p.requiredCount > 0 && scanned >= p.requiredCount;
        final hasProgress = scanned > 0;

        return ListTile(
          dense: true,
          leading: Icon(
            isComplete
                ? Icons.verified_rounded
                : hasProgress
                    ? Icons.pending_actions_rounded
                    : Icons.radio_button_unchecked_rounded,
            color: isComplete
                ? const Color(0xFF43A047)
                : hasProgress
                    ? const Color(0xFFFFA726)
                    : Colors.grey,
          ),
          title: Text(
            p.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            'کد: ${p.code}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isComplete
                  ? const Color(0xFF43A047).withOpacity(0.15)
                  : hasProgress
                      ? const Color(0xFFFFA726).withOpacity(0.15)
                      : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$scanned / ${p.requiredCount}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isComplete
                    ? const Color(0xFF43A047)
                    : hasProgress
                        ? const Color(0xFFFFA726)
                        : Colors.black54,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// کادر ورود دستی بارکد که هم تایپ دستی و هم ورود صوتی (گفتار به متن) را
/// پشتیبانی می‌کند. برای بارکدهایی که دوربین قادر به خواندنشان نیست.
class _VoiceManualEntryDialog extends StatefulWidget {
  const _VoiceManualEntryDialog();

  @override
  State<_VoiceManualEntryDialog> createState() =>
      _VoiceManualEntryDialogState();
}

class _VoiceManualEntryDialogState extends State<_VoiceManualEntryDialog> {
  final TextEditingController _controller = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();

  bool _speechAvailable = false;
  bool _isListening = false;
  String _statusText = 'برای گفتن کد، روی میکروفن بزنید';

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  /// راه‌اندازی موتور تشخیص گفتار (همین‌جا دسترسی میکروفن از کاربر پرسیده می‌شود)
  Future<void> _initSpeech() async {
    try {
      final available = await _speech.initialize(
        onStatus: (status) {
          if (!mounted) return;
          setState(() => _isListening = status == 'listening');
        },
        onError: (error) {
          if (!mounted) return;
          setState(() {
            _isListening = false;
            _statusText = 'خطا در تشخیص گفتار، لطفاً دستی وارد کنید';
          });
        },
      );
      if (!mounted) return;
      setState(() {
        _speechAvailable = available;
        if (!available) {
          _statusText = 'دسترسی به میکروفن/تشخیص گفتار ممکن نشد';
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _speechAvailable = false;
        _statusText = 'دسترسی به میکروفن/تشخیص گفتار ممکن نشد';
      });
    }
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      if (!mounted) return;
      setState(() => _isListening = false);
      return;
    }

    if (!_speechAvailable) {
      await _initSpeech();
      if (!_speechAvailable) return;
    }

    setState(() => _statusText = 'در حال شنیدن... کد را بگویید');

    await _speech.listen(
      localeId: 'fa_IR',
      onResult: (result) {
        if (!mounted) return;
        setState(() {
          _controller.text = result.recognizedWords;
          _controller.selection =
              TextSelection.collapsed(offset: _controller.text.length);
        });
      },
    );
  }

  @override
  void dispose() {
    _speech.stop();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('ورود دستی / صوتی بارکد'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.left,
            keyboardType: TextInputType.text,
            decoration: const InputDecoration(
              hintText: 'کد بارکد را وارد کنید',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (v) => Navigator.of(context).pop(v),
          ),
          const SizedBox(height: 18),
          GestureDetector(
            onTap: _toggleListening,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isListening ? AppColors.cyan : AppColors.teal,
                boxShadow: _isListening
                    ? [
                        BoxShadow(
                          color: AppColors.cyan.withOpacity(0.5),
                          blurRadius: 18,
                          spreadRadius: 4,
                        ),
                      ]
                    : [],
              ),
              child: Icon(
                _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _statusText,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('انصراف'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('ثبت'),
        ),
      ],
    );
  }
}
