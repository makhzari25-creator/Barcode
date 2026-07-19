import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../injection.dart';
import '../../domain/entities/import_export_entities.dart';
import '../providers/import_provider.dart';

/// صفحه Import فایل اکسل
class ImportPage extends ConsumerWidget {
  const ImportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(importProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.importTitle),
        actions: [
          // خروجی Excel بارکدها
          IconButton(
            icon: const Icon(Icons.file_download),
            tooltip: 'خروجی Excel بارکدهای فعلی',
            onPressed: () async {
              final exportUseCase = ref.read(exportBarcodesUseCaseProvider);
              final filePath = await exportUseCase();
              if (filePath != null && context.mounted) {
                await Share.shareXFiles([XFile(filePath)],
                    text: 'لیست بارکدهای انبار');
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // راهنما
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingMd),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'راهنمای فایل Excel لیست برداشت',
                        style: theme.textTheme.titleMedium?.copyWith(color: AppColors.primaryDark),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'ستون‌های پشتیبانی‌شده (فارسی یا انگلیسی):\n'
                    '• بارکد (الزامی): barcode, بارکد, کد بارکد, کد\n'
                    '• م.ف.ا: مکان فیزیکی انبار (برای مرتب‌سازی)\n'
                    '• م.ف.سالن: مکان سالن\n'
                    '• رنگ: color\n'
                    '• کد محصول: product_code, sku\n'
                    '• عنوان محصول: product_name, نام محصول\n'
                    '• تعداد: quantity, qty\n'
                    '• جنسیت: gender\n'
                    '• طرح: design\n'
                    '• سایز: size\n\n'
                    'پس از Import، لیست به‌صورت خودکار بر اساس م.ف.ا مرتب می‌شود.',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.7),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.spacingLg),

            // انتخاب فایل
            if (state.selectedFilePath == null)
              _buildFilePicker(context, ref)
            else
              _buildFileInfo(context, ref, state),

            const SizedBox(height: AppDimensions.spacingLg),

            // پیشرفت
            if (state.isLoading) ...[
              const SizedBox(height: AppDimensions.spacingLg),
              _buildProgress(state),
            ],

            // نتیجه
            if (state.result != null) ...[
              const SizedBox(height: AppDimensions.spacingLg),
              _buildResult(context, ref, state.result!, theme),
            ],

            // خطا
            if (state.errorMessage != null) ...[
              const SizedBox(height: AppDimensions.spacingLg),
              _buildError(state.errorMessage!, theme),
            ],

            // دکمه‌ها
            if (state.selectedFilePath != null && !state.isLoading) ...[
              const SizedBox(height: AppDimensions.spacingXl),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => ref.read(importProvider.notifier).clearSelection(),
                      child: const Text('انصراف'),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingSm),
                  if (state.result == null)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => ref.read(importProvider.notifier).startImport(),
                        icon: const Icon(Icons.upload_file),
                        label: const Text(AppStrings.startImport),
                      ),
                    ),
                ],
              ),
              if (state.result != null)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => context.go('/picking'),
                    icon: const Icon(Icons.play_arrow),
                    label: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'شروع برداشت',
                        style: TextStyle(fontSize: 18, fontFamily: 'Vazirmatn'),
                      ),
                    ),
                  ),
                ),
              if (state.result != null) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => context.go('/home'),
                    icon: const Icon(Icons.home),
                    label: const Text('بازگشت به خانه'),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  /// ساخت دکمه انتخاب فایل
  Widget _buildFilePicker(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () => ref.read(importProvider.notifier).pickFile(),
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.spacingXxl),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.3),
            width: 2,
            strokeAlign: BorderSide.strokeAlignOutside,
          ),
        ),
        child: Column(
          children: [
            const Icon(Icons.cloud_upload, size: 64, color: AppColors.primary),
            const SizedBox(height: AppDimensions.spacingMd),
            Text(
              AppStrings.selectFile,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            Text(
              'Excel (.xlsx, .xls) یا CSV',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  /// ساخت اطلاعات فایل انتخاب‌شده
  Widget _buildFileInfo(BuildContext context, WidgetRef ref, ImportState state) {
    final theme = Theme.of(context);
    final sizeStr = state.fileSize != null
        ? '${(state.fileSize! / 1024).toStringAsFixed(1)} KB'
        : 'نامشخص';

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMd),
        child: Row(
          children: [
            const Icon(Icons.insert_drive_file, color: AppColors.primary, size: 40),
            const SizedBox(width: AppDimensions.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.selectedFileName ?? '',
                    style: theme.textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.storage, size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        '${AppStrings.fileSize}: $sizeStr',
                        style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => ref.read(importProvider.notifier).clearSelection(),
            ),
          ],
        ),
      ),
    );
  }

  /// ساخت انتخاب حالت Import
  Widget _buildModeSelector(
      BuildContext context, WidgetRef ref, ImportState state, ThemeData theme) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.importMode, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppDimensions.spacingSm),
            RadioListTile<ImportMode>(
              title: Text(ImportMode.add.label),
              subtitle: const Text('بارکدهای جدید به لیست فعلی اضافه می‌شوند'),
              value: ImportMode.add,
              groupValue: state.mode,
              onChanged: (v) => ref.read(importProvider.notifier).setMode(v!),
            ),
            RadioListTile<ImportMode>(
              title: Text(ImportMode.replace.label),
              subtitle: const Text('تمام بارکدهای فعلی حذف و لیست جدید جایگزین می‌شود'),
              value: ImportMode.replace,
              groupValue: state.mode,
              onChanged: (v) => ref.read(importProvider.notifier).setMode(v!),
            ),
          ],
        ),
      ),
    );
  }

  /// ساخت نوار پیشرفت
  Widget _buildProgress(ImportState state) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMd),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 12),
                Text('در حال خواندن فایل و ایجاد نشست برداشت...'),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            LinearProgressIndicator(value: state.progress),
            const SizedBox(height: 8),
            Text(
              '${(state.progress * 100).toInt()}٪',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  /// ساخت نتیجه موفق
  Widget _buildResult(BuildContext context, WidgetRef ref, ImportResult result, ThemeData theme) {
    final isSuccess = result.isSuccess;
    final color = isSuccess ? ScanResultColors.validBg : ScanResultColors.invalidBg;
    final icon = isSuccess ? Icons.check_circle : Icons.error;

    return Card(
      margin: EdgeInsets.zero,
      color: isSuccess ? ScanResultColors.validBg.withOpacity(0.05) : ScanResultColors.invalidBg.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isSuccess ? 'نشست برداشت با موفقیت ایجاد شد' : AppStrings.importError,
                    style: theme.textTheme.titleMedium?.copyWith(color: color),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            _ResultRow(label: 'تعداد کل آیتم‌ها', value: _toPersian(result.totalRecords)),
            _ResultRow(label: 'ایجاد شده در نشست', value: _toPersian(result.importedCount), color: ScanResultColors.validBg),
            if (result.skippedCount > 0)
              _ResultRow(label: 'تکراری (نادیده گرفته شد)', value: _toPersian(result.skippedCount), color: ScanResultColors.duplicateBg),
            if (result.errorCount > 0)
              _ResultRow(label: 'خطا', value: _toPersian(result.errorCount), color: ScanResultColors.invalidBg),
            if (result.error != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ScanResultColors.invalidBg.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  result.error!,
                  style: TextStyle(color: ScanResultColors.invalidBg, fontSize: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// ساخت خطا
  Widget _buildError(String message, ThemeData theme) {
    return Card(
      margin: EdgeInsets.zero,
      color: ScanResultColors.invalidBg.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMd),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: ScanResultColors.invalidBg),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: theme.textTheme.bodyMedium?.copyWith(color: ScanResultColors.invalidBg)),
            ),
          ],
        ),
      ),
    );
  }

  String _toPersian(int n) {
    return n.toString().replaceAllMapped(
      RegExp(r'\d'),
      (m) => const ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'][int.parse(m.group(0)!)],
    );
  }
}

/// ردیف نتیجه
class _ResultRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _ResultRow({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: color ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
