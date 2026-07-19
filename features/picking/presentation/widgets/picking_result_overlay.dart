// lib/features/picking/presentation/widgets/picking_result_overlay.dart
//
// Overlay تمام‌صفحه برای نمایش نتیجه اسکن برداشت
//

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/picking_item.dart';
import '../../domain/entities/picking_session.dart';

/// Overlay تمام‌صفحه برای نمایش نتیجه اسکن
class PickingResultOverlay extends StatefulWidget {
  final PickingValidationStatus status;
  final PickingItem? matchedItem;
  final PickingItem? expectedItem;
  final VoidCallback onDismiss;

  const PickingResultOverlay({
    super.key,
    required this.status,
    this.matchedItem,
    this.expectedItem,
    required this.onDismiss,
  });

  @override
  State<PickingResultOverlay> createState() => _PickingResultOverlayState();
}

class _PickingResultOverlayState extends State<PickingResultOverlay>
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
    final title = _getTitle(widget.status);
    final subtitle = _getSubtitle(widget.status);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: GestureDetector(
        onTap: widget.onDismiss,
        child: Container(
          color: colors['background']!.withOpacity(0.95),
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
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
                              color: colors['background']!.withOpacity(0.4),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          icon,
                          size: 80,
                          color: colors['background'],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // عنوان اصلی
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        fontFamily: 'Vazirmatn',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.9),
                          fontFamily: 'Vazirmatn',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],

                    // نمایش م.ف.ا آیتم مورد انتظار در صورت خطا
                    if (widget.expectedItem != null &&
                        widget.status != PickingValidationStatus.correct) ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'م.ف.ا مورد انتظار:',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.8),
                                fontFamily: 'Vazirmatn',
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.expectedItem!.locationWarehouse,
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                fontFamily: 'Vazirmatn',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Map<String, Color> _getColors(PickingValidationStatus status) {
    return switch (status) {
      PickingValidationStatus.correct => {
          'background': const Color(0xFF2E7D32), // سبز
        },
      PickingValidationStatus.wrongItem => {
          'background': const Color(0xFFC62828), // قرمز
        },
      PickingValidationStatus.notInList => {
          'background': const Color(0xFFC62828), // قرمز
        },
      PickingValidationStatus.alreadyPicked => {
          'background': const Color(0xFFF9A825), // زرد
        },
    };
  }

  IconData _getIcon(PickingValidationStatus status) {
    return switch (status) {
      PickingValidationStatus.correct => Icons.check_circle,
      PickingValidationStatus.wrongItem => Icons.error,
      PickingValidationStatus.notInList => Icons.cancel,
      PickingValidationStatus.alreadyPicked => Icons.warning,
    };
  }

  String _getTitle(PickingValidationStatus status) {
    return switch (status) {
      PickingValidationStatus.correct => 'برداشت شد ✓',
      PickingValidationStatus.wrongItem => 'بارکد اشتباه',
      PickingValidationStatus.notInList => 'بارکد در لیست نیست',
      PickingValidationStatus.alreadyPicked => 'قبلاً برداشت شده',
    };
  }

  String? _getSubtitle(PickingValidationStatus status) {
    return switch (status) {
      PickingValidationStatus.correct => 'در حال رفتن به آیتم بعدی...',
      PickingValidationStatus.wrongItem => 'این بارکد برای آیتم دیگری است',
      PickingValidationStatus.notInList => 'بارکد در لیست برداشت وجود ندارد',
      PickingValidationStatus.alreadyPicked => 'این آیتم قبلاً برداشت شده است',
    };
  }
}
