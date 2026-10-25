import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/barcode_utils.dart';

/// کارت پیشرفت بالای صفحه‌ی اسکن: «۳۶ از ۱۲۸ کالا» + نوار + درصد
class ProgressHeader extends StatelessWidget {
  final int done;
  final int total;
  final double progress;
  final Color color;
  final String doneLabel;

  const ProgressHeader({
    super.key,
    required this.done,
    required this.total,
    required this.progress,
    this.color = AppColors.primary,
    this.doneLabel = 'کالا',
  });

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).floor();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.inventory_2_rounded, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${toFaDigits(done)} از ${toFaDigits(total)} $doneLabel',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress.clamp(0.0, 1.0),
                          minHeight: 8,
                          color: color,
                          backgroundColor: AppColors.surfaceAlt,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${toFaDigits(percent)}٪',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
