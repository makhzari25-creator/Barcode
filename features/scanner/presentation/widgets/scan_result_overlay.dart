import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../domain/entities/scan_record.dart';

/// Overlay تمام‌صفحه برای نمایش نتیجه اسکن
class ScanResultOverlay extends StatefulWidget {
  final ScanStatus status;
  final String barcode;
  final String? productName;
  final VoidCallback onDismiss;

  const ScanResultOverlay({
    super.key,
    required this.status,
    required this.barcode,
    this.productName,
    required this.onDismiss,
  });

  @override
  State<ScanResultOverlay> createState() => _ScanResultOverlayState();
}

class _ScanResultOverlayState extends State<ScanResultOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = _getColors(widget.status);
    final icon = _getIcon(widget.status);
    final message = _getMessage(widget.status);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: GestureDetector(
        onTap: widget.onDismiss,
        child: Container(
          color: colors.background.withOpacity(0.95),
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // آیکون بزرگ
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: colors.background.withOpacity(0.4),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        icon,
                        size: 80,
                        color: colors.background,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingXl),

                  // پیام اصلی
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingLg),
                    child: Text(
                      message,
                      style: const TextStyle(
                        fontSize: AppDimensions.resultTitleSize,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        fontFamily: 'Vazirmatn',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingMd),

                  // بارکد اسکن‌شده
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingXl),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingMd,
                      vertical: AppDimensions.spacingSm,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    ),
                    child: Text(
                      widget.barcode,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontFamily: 'JetBrains Mono',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  // نام محصول (در صورت موجود بودن)
                  if (widget.productName != null && widget.productName!.isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.spacingSm),
                    Text(
                      widget.productName!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                        fontFamily: 'Vazirmatn',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],

                  const SizedBox(height: AppDimensions.spacingXxl),

                  // راهنما
                  Text(
                    'برای ادامه، صفحه را لمس کنید',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.6),
                      fontFamily: 'Vazirmatn',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// رنگ‌های مناسب وضعیت
  _OverlayColors _getColors(ScanStatus status) {
    return switch (status) {
      ScanStatus.valid => const _OverlayColors(
          background: ScanResultColors.validBg,
          accent: ScanResultColors.validAccent,
        ),
      ScanStatus.invalid => const _OverlayColors(
          background: ScanResultColors.invalidBg,
          accent: ScanResultColors.invalidAccent,
        ),
      ScanStatus.duplicate => const _OverlayColors(
          background: ScanResultColors.duplicateBg,
          accent: ScanResultColors.duplicateAccent,
        ),
    };
  }

  /// آیکون مناسب وضعیت
  IconData _getIcon(ScanStatus status) {
    return switch (status) {
      ScanStatus.valid => Icons.check_circle,
      ScanStatus.invalid => Icons.cancel,
      ScanStatus.duplicate => Icons.warning,
    };
  }

  /// پیام مناسب وضعیت
  String _getMessage(ScanStatus status) {
    return switch (status) {
      ScanStatus.valid => AppStrings.validBarcode,
      ScanStatus.invalid => AppStrings.invalidBarcode,
      ScanStatus.duplicate => AppStrings.duplicateBarcode,
    };
  }
}

/// کلاس کمکی برای رنگ‌های Overlay
class _OverlayColors {
  final Color background;
  final Color accent;

  const _OverlayColors({required this.background, required this.accent});
}
