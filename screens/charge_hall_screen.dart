import 'dart:async';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';
import '../services/hall_charge_state.dart';
import '../services/sound_service.dart';

/// صفحه‌ی «شارژ سالن»
/// یک فایل اکسل با ستون‌های «کد محصول» و «عنوان محصول» بارگذاری می‌شود و
/// با اسکن بارکد هر کالا، تطبیق کد با نام محصول تایید می‌شود (بدون شمارش تعداد).
class ChargeHallScreen extends StatefulWidget {
  const ChargeHallScreen({super.key});

  @override
  State<ChargeHallScreen> createState() => _ChargeHallScreenState();
}

class _ChargeHallScreenState extends State<ChargeHallScreen> {
  MobileScannerController? _scannerController;
  bool _scannerReady = false;
  bool _isProcessing = false;
  bool _torchOn = false;
  final SoundService _soundService = SoundService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && context.read<HallChargeState>().hasFile) {
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
    final state = context.read<HallChargeState>();
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

  Future<void> _processCode(String code) async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      await _scannerController?.stop();
    } catch (_) {}

    try {
      final state = context.read<HallChargeState>();
      final wasComplete = state.isFullyComplete;
      final result = await state.recordScan(code);

      if (result == HallScanResult.notFound) {
        unawaited(_soundService.playError());
      } else {
        unawaited(_soundService.playSuccess());
      }
      try {
        await Vibration.vibrate(duration: 80);
      } catch (_) {}

      if (!mounted) return;
      await _showResultDialog(code, result, state);

      if (!wasComplete && state.isFullyComplete) {
        if (!mounted) return;
        await _showAllCompleteDialog();
      }
    } finally {
      if (mounted && _scannerController != null) {
        try {
          await _scannerController!.start();
        } catch (_) {}
      }
      _isProcessing = false;
    }
  }

  Future<void> _showManualEntryDialog() async {
    final controller = TextEditingController();
    try {
      await _scannerController?.stop();
    } catch (_) {}

    final entered = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('ورود دستی بارکد'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.left,
          decoration: const InputDecoration(
            hintText: 'کد بارکد را وارد کنید',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (v) => Navigator.of(ctx).pop(v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('انصراف'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            child: const Text('ثبت'),
          ),
        ],
      ),
    );

    final code = entered?.trim() ?? '';
    if (code.isEmpty) {
      if (mounted && _scannerController != null) {
        try {
          await _scannerController!.start();
        } catch (_) {}
      }
      return;
    }
    await _processCode(code);
  }

  Future<void> _showResultDialog(
    String code,
    HallScanResult result,
    HallChargeState state,
  ) async {
    final product = state.findProduct(code);

    String title;
    String message;
    Color color;
    IconData icon;

    switch (result) {
      case HallScanResult.notFound:
        title = 'این کد در لیست شارژ سالن نیست';
        message = 'کد: $code';
        color = const Color(0xFFE53935);
        icon = Icons.error_outline_rounded;
        break;
      case HallScanResult.confirmed:
        title = 'تطبیق تایید شد';
        message = 'کد: ${product?.code ?? code}\nنام کالا: ${product?.title ?? ""}';
        color = const Color(0xFF43A047);
        icon = Icons.check_circle_outline_rounded;
        break;
      case HallScanResult.alreadyConfirmed:
        title = 'قبلاً تایید شده بود';
        message = 'کد: ${product?.code ?? code}\nنام کالا: ${product?.title ?? ""}';
        color = const Color(0xFF1565C0);
        icon = Icons.info_outline_rounded;
        break;
    }

    if (!mounted) return;
    await showDialog(
      context: context,
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
                  fontSize: 20, fontWeight: FontWeight.w900, color: color),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.6),
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

  Future<void> _showAllCompleteDialog() async {
    await showDialog(
      context: context,
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
              child: const Icon(Icons.celebration_rounded,
                  color: Color(0xFF43A047), size: 68),
            ),
            const SizedBox(height: 20),
            const Text(
              'تکمیل شد!',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 30, fontWeight: FontWeight.w900, color: Color(0xFF43A047)),
            ),
            const SizedBox(height: 10),
            const Text(
              'همه کالاهای شارژ سالن تایید شدند.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black87, height: 1.6),
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

  void _showSnack(String message, {Color color = Colors.black87}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _showResetDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ریست تاییدها'),
        content: const Text('همه‌ی تاییدها صفر می‌شود؛ لیست کالاها باقی می‌ماند.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('انصراف')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('ریست'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await context.read<HallChargeState>().resetConfirmations();
      _showSnack('تاییدها ریست شدند.', color: const Color(0xFF43A047));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<HallChargeState>();

    if (state.loading && !state.hasFile) {
      return Scaffold(
        appBar: AppBar(title: const Text('شارژ سالن')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (!state.hasFile) {
      return Scaffold(
        appBar: AppBar(title: const Text('شارژ سالن')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 130,
                  height: 130,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF3E0),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.inventory_2_rounded,
                      size: 70, color: Color(0xFFFF9800)),
                ),
                const SizedBox(height: 32),
                const Text(
                  'فایل اکسل شارژ سالن را انتخاب کنید',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                const Text(
                  'فقط ستون‌های «کد محصول» و «عنوان محصول» لازم است.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.black54),
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
                      backgroundColor: const Color(0xFFFF9800),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('شارژ سالن'),
        actions: [
          IconButton(
            icon: const Icon(Icons.keyboard_alt_rounded),
            tooltip: 'ورود دستی بارکد',
            onPressed: _showManualEntryDialog,
          ),
          IconButton(
            icon: Icon(_torchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded),
            tooltip: 'فلش',
            onPressed: () {
              _scannerController?.toggleTorch();
              setState(() => _torchOn = !_torchOn);
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'ریست تاییدها',
            onPressed: _showResetDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: const Color(0xFFFF9800).withOpacity(0.10),
            child: Row(
              children: [
                const Icon(Icons.table_chart_rounded,
                    color: Color(0xFFFF9800), size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    state.fileName ?? '',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFFFF9800)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text('${state.confirmedCount}/${state.products.length} تایید‌شده',
                    style: const TextStyle(fontSize: 13, color: Colors.black54)),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                if (_scannerReady && _scannerController != null)
                  MobileScanner(
                    controller: _scannerController!,
                    onDetect: _onDetect,
                  )
                else
                  Container(color: Colors.black),
                Center(
                  child: Container(
                    width: 240,
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFFF9800), width: 3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'بارکد را داخل قاب قرار دهید',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                  ),
                ),
                if (state.isFullyComplete)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      color: const Color(0xFF43A047),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.verified_rounded, color: Colors.white, size: 26),
                          SizedBox(width: 8),
                          Text('تکمیل شد',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('وضعیت کالاها',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Expanded(child: _HallProductList(state: state)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HallProductList extends StatelessWidget {
  final HallChargeState state;
  const _HallProductList({required this.state});

  @override
  Widget build(BuildContext context) {
    final sorted = [...state.products]..sort((a, b) {
        final ca = state.isConfirmed(a.code);
        final cb = state.isConfirmed(b.code);
        if (ca == cb) return 0;
        return ca ? -1 : 1;
      });

    if (sorted.isEmpty) {
      return const Center(child: Text('کالایی وجود ندارد.'));
    }

    return ListView.separated(
      itemCount: sorted.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final p = sorted[i];
        final confirmed = state.isConfirmed(p.code);
        return ListTile(
          dense: true,
          leading: Icon(
            confirmed ? Icons.verified_rounded : Icons.radio_button_unchecked_rounded,
            color: confirmed ? const Color(0xFF43A047) : Colors.grey,
          ),
          title: Text(p.title, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text('کد: ${p.code}', style: const TextStyle(fontSize: 12)),
          trailing: confirmed
              ? const Icon(Icons.check_circle_rounded, color: Color(0xFF43A047))
              : null,
        );
      },
    );
  }
}
