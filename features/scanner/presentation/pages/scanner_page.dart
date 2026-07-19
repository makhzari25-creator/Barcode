import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/services/feedback_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/scan_record.dart';
import '../providers/scanner_provider.dart';
import '../widgets/scan_result_overlay.dart';

/// صفحه اسکن بارکد با دوربین
class ScannerPage extends ConsumerStatefulWidget {
  const ScannerPage({super.key});

  @override
  ConsumerState<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends ConsumerState<ScannerPage> {
  late MobileScannerController _controller;
  bool _isOverlayVisible = false;
  ScanStatus? _overlayStatus;
  String? _overlayBarcode;
  String? _overlayProductName;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// پردازش بارکد شناسایی‌شده
  Future<void> _handleBarcode(BarcodeCapture capture) async {
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final code = barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;

    // اگر Overlay نمایش داده می‌شود، اسکن نکن
    if (_isOverlayVisible) return;

    final notifier = ref.read(scannerProvider.notifier);
    final feedback = ref.read(feedbackServiceProvider);

    final status = await notifier.processScannedBarcode(code);

    // پخش صدا و لرزش
    await feedback.playFeedback(status);

    // نمایش Overlay نتیجه
    if (mounted) {
      _showOverlay(status, code, notifier.state.lastProductName);
    }
  }

  /// نمایش Overlay نتیجه اسکن
  void _showOverlay(ScanStatus status, String barcode, String? productName) {
    setState(() {
      _isOverlayVisible = true;
      _overlayStatus = status;
      _overlayBarcode = barcode;
      _overlayProductName = productName;
    });

    // مخفی کردن خودکار پس از ۱.۵ ثانیه
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() => _isOverlayVisible = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(scannerProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(AppStrings.scanTitle),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          // دکمه فلش
          IconButton(
            icon: Icon(state.isFlashOn ? Icons.flash_on : Icons.flash_off),
            tooltip: state.isFlashOn ? AppStrings.flashOff : AppStrings.flashOn,
            onPressed: () {
              _controller.toggleTorch();
              ref.read(scannerProvider.notifier).toggleFlash();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // دوربین
          MobileScanner(
            controller: _controller,
            onDetect: _handleBarcode,
          ),

          // فریم راهنما
          _buildScanOverlay(),

          // نوار وضعیت پایین
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildStatusBar(state, user),
          ),

          // Overlay نتیجه
          if (_isOverlayVisible && _overlayStatus != null)
            ScanResultOverlay(
              status: _overlayStatus!,
              barcode: _overlayBarcode ?? '',
              productName: _overlayProductName,
              onDismiss: () {
                setState(() => _isOverlayVisible = false);
              },
            ),
        ],
      ),
    );
  }

  /// ساخت فریم راهنمای اسکن
  Widget _buildScanOverlay() {
    return ColorFiltered(
      colorFilter: ColorFilter.mode(
        Colors.black.withOpacity(0.5),
        BlendMode.srcOut,
      ),
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.transparent,
            ),
            child: Center(
              child: Container(
                height: AppDimensions.scannerFrameSize,
                width: AppDimensions.scannerFrameSize,
                decoration: BoxDecoration(
                  color: Colors.red, // رنگ مهم نیست چون srcOut آن را حذف می‌کند
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ساخت نوار وضعیت پایین
  Widget _buildStatusBar(ScannerState state, dynamic user) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMd),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // اپراتور
                Row(
                  children: [
                    const Icon(Icons.person, color: Colors.white70, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      user?.fullName ?? '',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
                // تعداد امروز
                Row(
                  children: [
                    const Icon(Icons.qr_code_scanner, color: AppColors.accent, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${AppStrings.todayCount}: ${_toPersian(state.todayCount)}',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
            if (state.lastBarcode != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.history, color: Colors.white70, size: 14),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${AppStrings.lastScan}: ${state.lastBarcode}',
                      style: TextStyle(
                        color: _statusColor(state.lastResult),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _statusColor(ScanStatus? status) {
    return switch (status) {
      ScanStatus.valid => ScanResultColors.validBg,
      ScanStatus.invalid => ScanResultColors.invalidBg,
      ScanStatus.duplicate => ScanResultColors.duplicateBg,
      null => Colors.white70,
    };
  }

  String _toPersian(int n) {
    return n.toString().replaceAllMapped(
      RegExp(r'\d'),
      (m) => const ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'][int.parse(m.group(0)!)],
    );
  }
}
