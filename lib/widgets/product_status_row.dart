import 'package:flutter/material.dart';
import '../models/product.dart';
import '../theme/app_colors.dart';
import '../utils/barcode_utils.dart';
import 'product_avatar.dart';

/// فیلد جستجوی کالا بر اساس عنوان یا کد
class ProductSearchField extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const ProductSearchField({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'جستجوی کالا با نام یا کد',
        prefixIcon: const Icon(Icons.search_rounded),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}

/// یک ردیف از لیست وضعیت کالاها
/// [required] برابر ۱ و [scanned] صفر یا ۱ یعنی حالت «تایید» (شارژ سالن)
class ProductStatusRow extends StatelessWidget {
  final Product product;
  final int scanned;
  final int required;
  final Color color;
  final bool showCounts;

  const ProductStatusRow({
    super.key,
    required this.product,
    required this.scanned,
    required this.required,
    required this.color,
    this.showCounts = true,
  });

  @override
  Widget build(BuildContext context) {
    final done = required > 0 && scanned >= required;
    final started = scanned > 0;
    final statusColor = done
        ? AppColors.success
        : started
            ? AppColors.warning
            : AppColors.textMuted;
    final statusSoft = done
        ? AppColors.successSoft
        : started
            ? AppColors.warningSoft
            : AppColors.surfaceAlt;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          ProductAvatar(product: product, size: 44, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      product.code,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textMuted),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: statusSoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: showCounts
                ? Text(
                    '${toFaDigits(scanned)} / ${toFaDigits(required)}',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: statusColor),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        done
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,
                        size: 16,
                        color: statusColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        done ? 'تایید شد' : 'در انتظار',
                        style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: statusColor),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
