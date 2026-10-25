import 'package:flutter/material.dart';
import '../models/product.dart';
import '../theme/app_colors.dart';
import '../utils/barcode_utils.dart';
import 'product_avatar.dart';

enum FeedbackKind { success, info, error }

/// نتیجه‌ی آخرین اسکن برای نمایش زیر دوربین
class ScanFeedback {
  final FeedbackKind kind;
  final String title;
  final String code;
  final Product? product;

  /// فقط در «چک کردن شارژ» مقدار دارد
  final int? scanned;
  final int? required;

  /// برچسب سبز زیر کارت کالا (مثلاً «کد کالا تایید شد»)
  final String? badge;

  const ScanFeedback({
    required this.kind,
    required this.title,
    required this.code,
    this.product,
    this.scanned,
    this.required,
    this.badge,
  });
}

/// بنر رنگی نتیجه + کارت مشخصات کالا؛ پیش از اولین اسکن کارت راهنما دیده می‌شود
class ScanResultCard extends StatelessWidget {
  final ScanFeedback? feedback;
  final Color accent;
  final VoidCallback? onNext;

  const ScanResultCard({
    super.key,
    required this.feedback,
    required this.accent,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final fb = feedback;
    if (fb == null) return _IdleCard(accent: accent);

    final (Color color, Color soft, IconData icon) = switch (fb.kind) {
      FeedbackKind.success => (
          AppColors.success,
          AppColors.successSoft,
          Icons.check_circle_rounded
        ),
      FeedbackKind.info => (
          AppColors.hall,
          AppColors.hallSoft,
          Icons.info_rounded
        ),
      FeedbackKind.error => (
          AppColors.danger,
          AppColors.dangerSoft,
          Icons.error_rounded
        ),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  fb.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  ProductAvatar(product: fb.product, size: 60, color: color),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fb.product?.title ?? 'کالای نامشخص',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Text('کد کالا: ',
                                style: TextStyle(
                                    fontSize: 13, color: AppColors.textMuted)),
                            Flexible(
                              child: Directionality(
                                textDirection: TextDirection.ltr,
                                child: Text(
                                  fb.product?.code ?? fb.code,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (fb.scanned != null && fb.required != null) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),
                Row(
                  children: [
                    Expanded(
                      child: _Stat(
                        label: 'اسکن‌شده',
                        value:
                            '${toFaDigits(fb.scanned!)} از ${toFaDigits(fb.required!)}',
                        color: color,
                      ),
                    ),
                    Container(width: 1, height: 40, color: AppColors.border),
                    Expanded(
                      child: _Stat(
                        label: 'تعداد مورد نیاز',
                        value: toFaDigits(fb.required!),
                        color: AppColors.text,
                      ),
                    ),
                  ],
                ),
              ],
              if (fb.badge != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: soft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_rounded, color: color, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        fb.badge!,
                        style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w700,
                            fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
              if (fb.product == null) ...[
                const SizedBox(height: 10),
                Text(
                  'این کد در فایل اکسل پیدا نشد. کد را بررسی کنید یا کالای دیگری را اسکن کنید.',
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textMuted, height: 1.7),
                ),
              ],
            ],
          ),
        ),
        if (onNext != null) ...[
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: onNext,
            style: FilledButton.styleFrom(backgroundColor: accent),
            icon: const Icon(Icons.qr_code_scanner_rounded),
            label: const Text('اسکن بعدی'),
          ),
        ],
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _Stat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.w900, color: color),
        ),
      ],
    );
  }
}

class _IdleCard extends StatelessWidget {
  final Color accent;
  const _IdleCard({required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.qr_code_2_rounded, color: accent, size: 28),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'بارکد کالا را اسکن کنید تا مشخصات و نتیجه این‌جا نمایش داده شود.',
              style: TextStyle(
                  fontSize: 14, color: AppColors.textMuted, height: 1.7),
            ),
          ),
        ],
      ),
    );
  }
}
