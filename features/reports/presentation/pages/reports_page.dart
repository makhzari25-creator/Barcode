import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../injection.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../scanner/domain/entities/scan_record.dart';
import '../providers/reports_provider.dart';

/// صفحه گزارش‌ها
class ReportsPage extends ConsumerWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reportsProvider);
    final user = ref.watch(currentUserProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.reportsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'بارگذاری مجدد',
            onPressed: () => ref.read(reportsProvider.notifier).refresh(),
          ),
          IconButton(
            icon: const Icon(Icons.file_download),
            tooltip: AppStrings.exportExcel,
            onPressed: () async {
              final exportUseCase = ref.read(exportScansUseCaseProvider);
              final filePath = await exportUseCase(
                startDate: state.startDate,
                endDate: state.endDate,
                userId: user?.role.isOperator == true ? user?.id : state.selectedUserId,
              );
              if (filePath != null && context.mounted) {
                await Share.shareXFiles([XFile(filePath)],
                    text: 'گزارش اسکن‌های اپلیکیشن تأیید بارکد انبار');
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('خطا در تولید فایل خروجی')),
                );
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(reportsProvider.notifier).refresh(),
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppDimensions.paddingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // فیلتر تاریخ
                    _buildDateFilters(context, ref, state),
                    const SizedBox(height: AppDimensions.spacingMd),

                    // کارت‌های آماری
                    _buildStatsGrid(state.stats, theme),
                    const SizedBox(height: AppDimensions.spacingLg),

                    // عنوان جدول
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'آخرین اسکن‌ها',
                          style: theme.textTheme.titleLarge,
                        ),
                        Text(
                          '${state.scans.length} رکورد',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.spacingSm),

                    // جدول اسکن‌ها
                    if (state.scans.isEmpty)
                      _buildEmptyState(theme)
                    else
                      _buildScansList(state.scans, theme),
                  ],
                ),
              ),
      ),
    );
  }

  /// ساخت فیلترهای تاریخ
  Widget _buildDateFilters(BuildContext context, WidgetRef ref, ReportsState state) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('فیلتر گزارش', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppDimensions.spacingSm),
            Row(
              children: [
                Expanded(
                  child: _DateFilterField(
                    label: AppStrings.fromDate,
                    value: state.startDate,
                    onClear: () => ref.read(reportsProvider.notifier).setStartDate(null),
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingSm),
                Expanded(
                  child: _DateFilterField(
                    label: AppStrings.toDate,
                    value: state.endDate,
                    onClear: () => ref.read(reportsProvider.notifier).setEndDate(null),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => ref.read(reportsProvider.notifier).clearFilters(),
                icon: const Icon(Icons.clear, size: 16),
                label: const Text('پاک کردن فیلتر'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ساخت کارت‌های آماری
  Widget _buildStatsGrid(ScanStats? stats, ThemeData theme) {
    final total = stats?.total ?? 0;
    final valid = stats?.valid ?? 0;
    final invalid = stats?.invalid ?? 0;
    final duplicate = stats?.duplicate ?? 0;

    return LayoutBuilder(
      builder: (context, constraints) {
        // تعیین تعداد ستون‌ها بر اساس عرض
        final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: AppDimensions.spacingSm,
          mainAxisSpacing: AppDimensions.spacingSm,
          childAspectRatio: 1.2,
          children: [
            _StatCard(
              title: AppStrings.totalScans,
              value: _toPersian(total),
              icon: Icons.qr_code_scanner,
              color: AppColors.primary,
              bgColor: AppColors.primaryLight,
            ),
            _StatCard(
              title: AppStrings.validCount,
              value: _toPersian(valid),
              icon: Icons.check_circle,
              color: ScanResultColors.validBg,
              bgColor: ScanResultColors.validBg.withOpacity(0.1),
            ),
            _StatCard(
              title: AppStrings.invalidCount,
              value: _toPersian(invalid),
              icon: Icons.cancel,
              color: ScanResultColors.invalidBg,
              bgColor: ScanResultColors.invalidBg.withOpacity(0.1),
            ),
            _StatCard(
              title: AppStrings.duplicateCount,
              value: _toPersian(duplicate),
              icon: Icons.warning,
              color: ScanResultColors.duplicateBg,
              bgColor: ScanResultColors.duplicateBg.withOpacity(0.1),
            ),
          ],
        );
      },
    );
  }

  /// ساخت لیست اسکن‌ها
  Widget _buildScansList(List<ScanRecord> scans, ThemeData theme) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: scans.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final scan = scans[index];
          return _ScanTile(scan: scan);
        },
      ),
    );
  }

  /// ساخت حالت خالی
  Widget _buildEmptyState(ThemeData theme) {
    return Card(
      margin: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.spacingXxl),
        child: Column(
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: AppColors.gray400),
            const SizedBox(height: AppDimensions.spacingMd),
            Text(
              AppStrings.noData,
              style: theme.textTheme.titleMedium?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
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

/// کارت آماری
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMd),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: color,
                fontFamily: 'Vazirmatn',
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
              fontFamily: 'Vazirmatn',
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}

/// آیتم لیست اسکن
class _ScanTile extends StatelessWidget {
  final ScanRecord scan;

  const _ScanTile({required this.scan});

  @override
  Widget build(BuildContext context) {
    final colors = _getColors(scan.status);
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: colors.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(_getIcon(scan.status), color: colors, size: 20),
      ),
      title: Text(
        scan.barcode,
        style: const TextStyle(
          fontFamily: 'JetBrains Mono',
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        '${scan.dateOnly} - ${scan.timeOnly}',
        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: colors.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          scan.status.label,
          style: TextStyle(
            color: colors,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            fontFamily: 'Vazirmatn',
          ),
        ),
      ),
    );
  }

  Color _getColors(ScanStatus status) {
    return switch (status) {
      ScanStatus.valid => ScanResultColors.validBg,
      ScanStatus.invalid => ScanResultColors.invalidBg,
      ScanStatus.duplicate => ScanResultColors.duplicateBg,
    };
  }

  IconData _getIcon(ScanStatus status) {
    return switch (status) {
      ScanStatus.valid => Icons.check_circle,
      ScanStatus.invalid => Icons.cancel,
      ScanStatus.duplicate => Icons.warning,
    };
  }
}

/// فیلد فیلتر تاریخ
class _DateFilterField extends StatelessWidget {
  final String label;
  final String? value;
  final VoidCallback onClear;

  const _DateFilterField({
    required this.label,
    required this.value,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        border: Border.all(color: AppColors.gray300),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                Text(
                  value ?? 'همه',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: value != null ? AppColors.textPrimary : AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
          if (value != null)
            IconButton(
              icon: const Icon(Icons.clear, size: 14),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: onClear,
            ),
        ],
      ),
    );
  }
}
