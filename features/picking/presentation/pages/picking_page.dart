// lib/features/picking/presentation/pages/picking_page.dart
//
// صفحه اصلی برداشت - نمایش یک آیتم در هر لحظه + اسکنر بارکد
//

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/services/feedback_service.dart';
import '../../domain/entities/picking_item.dart';
import '../../domain/entities/picking_session.dart';
import '../providers/picking_provider.dart';
import '../widgets/picking_result_overlay.dart';

// تعریف محلی FeedbackType برای جلوگیری از conflict
// (در صورت نیاز می‌توان مستقیماً از FeedbackType در core/services استفاده کرد)

/// صفحه اصلی برداشت
class PickingPage extends ConsumerStatefulWidget {
  const PickingPage({super.key});

  @override
  ConsumerState<PickingPage> createState() => _PickingPageState();
}

class _PickingPageState extends ConsumerState<PickingPage> {
  late MobileScannerController _scannerController;
  bool _isOverlayVisible = false;
  PickingValidationStatus? _overlayStatus;
  PickingItem? _overlayMatchedItem;
  PickingItem? _overlayExpectedItem;
  bool _isFlashOn = false;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  /// پردازش بارکد اسکن‌شده
  Future<void> _handleBarcode(BarcodeCapture capture) async {
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final code = barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;

    // اگر Overlay نمایش داده می‌شود، اسکن نکن
    if (_isOverlayVisible) return;

    final notifier = ref.read(pickingProvider.notifier);
    final feedback = ref.read(feedbackServiceProvider);
    final currentItem = ref.read(pickingProvider).currentItem;

    // پردازش بارکد
    final status = await notifier.processScannedBarcode(code);

    // پخش صدا و لرزش
    await feedback.playFeedbackByType(_mapToFeedbackType(status));

    // نمایش Overlay
    if (mounted) {
      _showOverlay(status, currentItem);
    }
  }

  /// نگاشت PickingValidationStatus به FeedbackType
  FeedbackType _mapToFeedbackType(PickingValidationStatus status) {
    return switch (status) {
      PickingValidationStatus.correct => FeedbackType.success,
      PickingValidationStatus.wrongItem => FeedbackType.error,
      PickingValidationStatus.notInList => FeedbackType.error,
      PickingValidationStatus.alreadyPicked => FeedbackType.warning,
    };
  }

  /// نمایش Overlay نتیجه
  void _showOverlay(
    PickingValidationStatus status,
    PickingItem? expectedItem,
  ) {
    setState(() {
      _isOverlayVisible = true;
      _overlayStatus = status;
      _overlayExpectedItem = expectedItem;
    });

    // مدت نمایش بسته به وضعیت
    final duration = status == PickingValidationStatus.correct
        ? 1200 // موفقیت - کوتاه‌تر (auto-advance)
        : 2000; // خطا - طولانی‌تر برای خواندن

    Future.delayed(Duration(milliseconds: duration), () {
      if (mounted) {
        setState(() => _isOverlayVisible = false);
      }
    });
  }

  /// نمایش دیالوگ تأیید پایان برداشت
  Future<void> _showEndPickingDialog() async {
    final state = ref.read(pickingProvider);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('پایان برداشت'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('آیا از پایان نشست برداشت اطمینان دارید؟'),
            const SizedBox(height: 16),
            _buildSummaryRow('کل آیتم‌ها', state.totalItems),
            _buildSummaryRow('برداشت شده', state.pickedCount,
                color: const Color(0xFF2E7D32)),
            _buildSummaryRow('باقی‌مانده', state.remainingCount,
                color: const Color(0xFFC62828)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('ادامه برداشت'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('پایان و گزارش'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(pickingProvider.notifier).completeSession();
      if (mounted) {
        context.go('/picking/report');
      }
    }
  }

  Widget _buildSummaryRow(String label, int value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pickingProvider);
    final theme = Theme.of(context);

    // اگر نشست فعالی وجود ندارد
    if (state.activeSession == null && !state.isLoading) {
      return _buildNoSessionView(theme);
    }

    // اگر در حال بارگذاری
    if (state.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('برداشت')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // اگر نشست تکمیل شده
    if (state.isCompleted && state.currentItem == null) {
      return _buildCompletedView(theme, state);
    }

    // نمایش آیتم فعلی + اسکنر
    return Scaffold(
      body: Stack(
        children: [
          // محتوای اصلی
          SafeArea(
            child: Column(
              children: [
                // هدر با پیشرفت
                _buildProgressHeader(state, theme),

                // کارت آیتم فعلی
                Expanded(
                  flex: 3,
                  child: state.currentItem != null
                      ? _buildItemCard(state.currentItem!, theme, state)
                      : _buildNoMoreItemsView(theme),
                ),

                // نوار اسکنر
                Expanded(
                  flex: 2,
                  child: _buildScannerArea(),
                ),
              ],
            ),
          ),

          // Overlay نتیجه
          if (_isOverlayVisible && _overlayStatus != null)
            PickingResultOverlay(
              status: _overlayStatus!,
              matchedItem: _overlayMatchedItem,
              expectedItem: _overlayExpectedItem,
              onDismiss: () {
                setState(() => _isOverlayVisible = false);
              },
            ),
        ],
      ),
    );
  }

  /// ساخت هدر با نوار پیشرفت
  Widget _buildProgressHeader(PickingState state, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMd),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // دکمه بازگشت
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => _showEndPickingDialog(),
                tooltip: 'پایان برداشت',
              ),

              // شماره آیتم فعلی
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'آیتم ${state.displayCurrentNumber} از ${state.totalItems}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                        fontFamily: 'Vazirmatn',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'برداشت شده: ${state.pickedCount} | باقی‌مانده: ${state.remainingCount}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontFamily: 'Vazirmatn',
                      ),
                    ),
                  ],
                ),
              ),

              // دکمه فلش
              IconButton(
                icon: Icon(_isFlashOn ? Icons.flash_on : Icons.flash_off),
                onPressed: () {
                  _scannerController.toggleTorch();
                  setState(() => _isFlashOn = !_isFlashOn);
                },
                tooltip: _isFlashOn ? 'خاموش کردن فلش' : 'روشن کردن فلش',
              ),
            ],
          ),
          const SizedBox(height: 12),
          // نوار پیشرفت
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: state.progress,
              minHeight: 12,
              backgroundColor: AppColors.gray200,
              valueColor: AlwaysStoppedAnimation<Color>(
                state.progress == 1.0
                    ? const Color(0xFF2E7D32)
                    : AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${(state.progress * 100).toInt()}٪',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// ساخت کارت آیتم فعلی - نمایش تمام اطلاعات با م.ف.ا در بزرگترین فونت
  Widget _buildItemCard(
    PickingItem item,
    ThemeData theme,
    PickingState state,
  ) {
    return Container(
      margin: const EdgeInsets.all(AppDimensions.paddingMd),
      padding: const EdgeInsets.all(AppDimensions.paddingLg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // م.ف.ا - بزرگترین فونت در بالا
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    'م.ف.ا',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.8),
                      fontFamily: 'Vazirmatn',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.locationWarehouse.isEmpty
                        ? '—'
                        : item.locationWarehouse,
                    style: const TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      fontFamily: 'Vazirmatn',
                      height: 1.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // م.ف.سالن (در صورت وجود)
            if (item.locationHall != null && item.locationHall!.isNotEmpty) ...[
              _buildInfoRow('م.ف.سالن', item.locationHall!, icon: Icons.warehouse),
              const SizedBox(height: 8),
            ],

            // عنوان محصول
            if (item.productName != null && item.productName!.isNotEmpty) ...[
              _buildInfoRow(
                'عنوان محصول',
                item.productName!,
                icon: Icons.inventory_2,
                isLarge: true,
              ),
              const SizedBox(height: 8),
            ],

            // کد محصول
            if (item.productCode != null && item.productCode!.isNotEmpty) ...[
              _buildInfoRow('کد محصول', item.productCode!, icon: Icons.qr_code),
              const SizedBox(height: 8),
            ],

            // ردیف رنگ، سایز، طرح، جنسیت
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (item.color != null && item.color!.isNotEmpty)
                  _buildChip('رنگ', item.color!, Icons.palette),
                if (item.size != null && item.size!.isNotEmpty)
                  _buildChip('سایز', item.size!, Icons.straighten),
                if (item.design != null && item.design!.isNotEmpty)
                  _buildChip('طرح', item.design!, Icons.style),
                if (item.gender != null && item.gender!.isNotEmpty)
                  _buildChip('جنسیت', item.gender!, Icons.person),
              ],
            ),

            const SizedBox(height: 16),

            // تعداد
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFFFC107).withOpacity(0.5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_cart, color: Color(0xFFE65100)),
                  const SizedBox(width: 8),
                  Text(
                    'تعداد: ${item.quantity}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFE65100),
                      fontFamily: 'Vazirmatn',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // بارکد مورد انتظار
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'بارکد مورد انتظار',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontFamily: 'Vazirmatn',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.barcode,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      fontFamily: 'JetBrains Mono',
                      letterSpacing: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // دکمه Skip (دستی)
            OutlinedButton.icon(
              onPressed: state.isProcessing
                  ? null
                  : () => ref.read(pickingProvider.notifier).skipCurrentItem(),
              icon: const Icon(Icons.skip_next, size: 28),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'نادیده گرفتن این آیتم',
                  style: TextStyle(fontSize: 16, fontFamily: 'Vazirmatn'),
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.warning,
                side: BorderSide(color: AppColors.warning.withOpacity(0.5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ساخت ردیف اطلاعات
  Widget _buildInfoRow(
    String label,
    String value, {
    IconData? icon,
    bool isLarge = false,
  }) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 8),
        ],
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: isLarge ? 16 : 14,
            color: AppColors.textSecondary,
            fontFamily: 'Vazirmatn',
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: isLarge ? 20 : 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              fontFamily: 'Vazirmatn',
            ),
          ),
        ),
      ],
    );
  }

  /// ساخت Chip اطلاعات
  Widget _buildChip(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.primaryDark,
              fontFamily: 'Vazirmatn',
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
              fontFamily: 'Vazirmatn',
            ),
          ),
        ],
      ),
    );
  }

  /// ساخت ناحیه اسکنر
  Widget _buildScannerArea() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMd,
        vertical: AppDimensions.paddingSm,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.primary, width: 3),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        child: Stack(
          children: [
            // دوربین
            MobileScanner(
              controller: _scannerController,
              onDetect: _handleBarcode,
            ),

            // فریم راهنما
            Center(
              child: Container(
                width: 250,
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white.withOpacity(0.7),
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            // متن راهنما
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.black54,
                child: const Text(
                  'بارکد را در کادر قرار دهید',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'Vazirmatn',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ساخت نمای بدون نشست
  Widget _buildNoSessionView(ThemeData theme) {
    return Scaffold(
      appBar: AppBar(title: const Text('برداشت')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingLg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 80,
                color: AppColors.gray400,
              ),
              const SizedBox(height: 16),
              Text(
                'نشست برداشتی فعال نیست',
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'برای شروع، ابتدا فایل اکسل لیست برداشت را وارد کنید',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => context.go('/import'),
                icon: const Icon(Icons.file_upload),
                label: const Text('وارد کردن فایل اکسل'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ساخت نمای اتمام همه آیتم‌ها
  Widget _buildNoMoreItemsView(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(AppDimensions.paddingLg),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              size: 80,
              color: const Color(0xFF2E7D32),
            ),
            const SizedBox(height: 16),
            Text(
              'همه آیتم‌ها پردازش شدند',
              style: theme.textTheme.titleLarge?.copyWith(
                color: const Color(0xFF2E7D32),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showEndPickingDialog,
              icon: const Icon(Icons.assignment_turned_in),
              label: const Text('مشاهده گزارش'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ساخت نمای تکمیل شده
  Widget _buildCompletedView(ThemeData theme, PickingState state) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('برداشت تکمیل شد'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingLg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.celebration,
                size: 80,
                color: Color(0xFF2E7D32),
              ),
              const SizedBox(height: 16),
              Text(
                'نشست برداشت با موفقیت تکمیل شد',
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _buildSummaryRow('کل آیتم‌ها', state.totalItems),
              _buildSummaryRow('برداشت شده', state.pickedCount,
                  color: const Color(0xFF2E7D32)),
              _buildSummaryRow('نادیده گرفته شده',
                  state.activeSession?.skippedCount ?? 0,
                  color: const Color(0xFFC62828)),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context.go('/home'),
                      icon: const Icon(Icons.home),
                      label: const Text('خانه'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => context.go('/picking/report'),
                      icon: const Icon(Icons.assessment),
                      label: const Text('گزارش کامل'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
