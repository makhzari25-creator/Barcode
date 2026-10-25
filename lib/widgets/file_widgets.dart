import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/barcode_utils.dart';

/// کارت فایل بارگذاری‌شده با نام فایل و تعداد کالا
class FileCard extends StatelessWidget {
  final String fileName;
  final int productCount;
  final VoidCallback onTap;

  const FileCard({
    super.key,
    required this.fileName,
    required this.productCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              const _ExcelBadge(size: 46),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${toFaDigits(productCount)} کالا · برای تعویض فایل بزنید',
                      style: const TextStyle(
                          fontSize: 12.5, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.swap_horiz_rounded, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExcelBadge extends StatelessWidget {
  final double size;
  const _ExcelBadge({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF1D7A45),
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Icon(Icons.table_chart_rounded,
          color: Colors.white, size: size * 0.55),
    );
  }
}

/// حالت اولیه وقتی هنوز فایل انتخاب نشده
class EmptyFileState extends StatelessWidget {
  final String title;
  final String hint;
  final Color color;
  final bool showCountColumn;
  final VoidCallback onPick;
  final VoidCallback? onPaper;

  const EmptyFileState({
    super.key,
    required this.title,
    required this.hint,
    required this.color,
    required this.showCountColumn,
    required this.onPick,
    this.onPaper,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.upload_file_rounded, size: 56, color: color),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              hint,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 14, color: AppColors.textMuted, height: 1.8),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ستون‌های مهم',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  const _ColumnRow(name: 'کد محصول', note: 'الزامی'),
                  const _ColumnRow(name: 'عنوان محصول', note: 'الزامی'),
                  if (showCountColumn)
                    const _ColumnRow(
                        name: 'تعداد', note: 'اختیاری، پیش‌فرض ۱'),
                  const _ColumnRow(name: 'م.ف. انبار', note: 'محل فیزیکی انبار'),
                  const _ColumnRow(name: 'رنگ / طرح / سایز', note: 'اختیاری'),
                  const _ColumnRow(
                      name: 'م.ف. سالن', note: '۳ رقم اول مثل ۰۳۱'),
                ],
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onPick,
                style: FilledButton.styleFrom(
                  backgroundColor: color,
                  minimumSize: const Size(0, 58),
                ),
                icon: const Icon(Icons.file_upload_rounded),
                label: const Text('انتخاب فایل اکسل'),
              ),
            ),
            if (onPaper != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonalIcon(
                  onPressed: onPaper,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 56),
                  ),
                  icon: const Icon(Icons.document_scanner_rounded),
                  label: const Text('ورود از عکس کاغذ'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ColumnRow extends StatelessWidget {
  final String name;
  final String note;
  const _ColumnRow({required this.name, required this.note});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(name,
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(note,
                style: const TextStyle(
                    fontSize: 12.5, color: AppColors.textMuted, height: 1.6)),
          ),
        ],
      ),
    );
  }
}
