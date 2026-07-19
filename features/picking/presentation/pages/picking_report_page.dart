// lib/features/picking/presentation/pages/picking_report_page.dart
//
// صفحه گزارش نشست برداشت - نمایش آمار و خروجی Excel
//

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../injection.dart';
import '../../domain/entities/picking_item.dart';
import '../providers/picking_provider.dart';

/// صفحه گزارش نشست برداشت
class PickingReportPage extends ConsumerStatefulWidget {
  const PickingReportPage({super.key});

  @override
  ConsumerState<PickingReportPage> createState() => _PickingReportPageState();
}

class _PickingReportPageState extends ConsumerState<PickingReportPage> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pickingProvider);
    final theme = Theme.of(context);

    if (state.activeSession == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('گزارش برداشت')),
        body: const Center(child: Text('نشستی برای نمایش گزارش وجود ندارد')),
      );
    }

    final session = state.activeSession!;
    final items = state.allItems;

    // گروه‌بندی آیتم‌های از دست رفته بر اساس م.ف.ا
    final missedItems = items.where((i) => i.isMissed).toList();
    final missedByLocation = <String, List<PickingItem>>{};
    for (final item in missedItems) {
      final loc = item.locationWarehouse.isEmpty ? '—' : item.locationWarehouse;
      missedByLocation.putIfAbsent(loc, () => []).add(item);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('گزارش برداشت'),
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            tooltip: 'خروجی Excel',
            onPressed: () => _exportToExcel(items, session.name),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.paddingMd),
        children: [
          // کارت عنوان نشست
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'منبع: ${session.sourceFile}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'شروع: ${_formatDateTime(session.startedAt)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (session.completedAt != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'پایان: ${_formatDateTime(session.completedAt!)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // کارت‌های آماری
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'کل آیتم‌ها',
                  session.totalItems.toString(),
                  Icons.inventory_2,
                  AppColors.primary,
                  AppColors.primaryLight,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'برداشت شده',
                  session.pickedCount.toString(),
                  Icons.check_circle,
                  const Color(0xFF2E7D32),
                  const Color(0xFFE8F5E9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'نادیده گرفته شده',
                  session.skippedCount.toString(),
                  Icons.warning,
                  const Color(0xFFC62828),
                  const Color(0xFFFFEBEE),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'باقی‌مانده',
                  (session.totalItems -
                          session.pickedCount -
                          session.skippedCount)
                      .toString(),
                  Icons.pending,
                  AppColors.warning,
                  const Color(0xFFFFF8E1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // هشدار در صورت وجود آیتم‌های از دست رفته
          if (missedItems.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFC62828).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFC62828),
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'هشدار: ${missedItems.length} آیتم از دست رفته',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFC62828),
                            fontFamily: 'Vazirmatn',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'این آیتم‌ها برداشت نشده‌اند. لطفاً بررسی کنید.',
                          style: TextStyle(
                            fontSize: 13,
                            color: const Color(0xFFC62828).withOpacity(0.8),
                            fontFamily: 'Vazirmatn',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // لیست آیتم‌های از دست رفته گروه‌بندی شده بر اساس م.ف.ا
            Text(
              'آیتم‌های از دست رفته (گروه‌بندی بر اساس م.ف.ا)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            ...missedByLocation.entries.map((entry) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ExpansionTile(
                  title: Text(
                    'م.ف.ا: ${entry.key}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Vazirmatn',
                    ),
                  ),
                  subtitle: Text('${entry.value.length} آیتم'),
                  children: entry.value.map((item) {
                    return ListTile(
                      dense: true,
                      leading: Icon(
                        item.status == PickingStatus.wrongBarcode
                            ? Icons.error
                            : Icons.skip_next,
                        color: const Color(0xFFC62828),
                        size: 20,
                      ),
                      title: Text(
                        item.productName ?? item.barcode,
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'Vazirmatn',
                        ),
                      ),
                      subtitle: Text(
                        [
                          if (item.color != null) 'رنگ: ${item.color}',
                          if (item.size != null) 'سایز: ${item.size}',
                          'بارکد: ${item.barcode}',
                        ].join(' | '),
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'Vazirmatn',
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            }),
          ],

          const SizedBox(height: 24),

          // دکمه خروجی Excel
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _exportToExcel(items, session.name),
              icon: const Icon(Icons.file_download, size: 28),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'خروجی Excel گزارش کامل',
                  style: TextStyle(fontSize: 18, fontFamily: 'Vazirmatn'),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // دکمه بازگشت به خانه
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => context.go('/home'),
              icon: const Icon(Icons.home, size: 28),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'بازگشت به خانه',
                  style: TextStyle(fontSize: 18, fontFamily: 'Vazirmatn'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ساخت کارت آماری
  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    Color bgColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: color,
                fontFamily: 'Vazirmatn',
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
              fontFamily: 'Vazirmatn',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// خروجی Excel گزارش
  Future<void> _exportToExcel(
    List<PickingItem> items,
    String sessionName,
  ) async {
    try {
      final exportRepo = ref.read(importExportRepositoryProvider);
      final filePath = await exportRepo.writePickingSessionToFile(
        sessionName: sessionName,
        items: items,
      );

      if (filePath != null && mounted) {
        await Share.shareXFiles(
          [XFile(filePath)],
          text: 'گزارش نشست برداشت: $sessionName',
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('خطا در تولید فایل خروجی')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا: $e')),
        );
      }
    }
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
