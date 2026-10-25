import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../services/app_state.dart';
import '../services/hall_charge_state.dart';
import '../theme/app_colors.dart';
import '../utils/barcode_utils.dart';
import '../widgets/dialogs.dart';

/// صفحه‌ی بایگانی: فایل‌های اکسل قبلی به‌همراه نتیجه‌ی نهایی اسکن‌هایشان
/// دو زبانه دارد: «چک کردن شارژ» و «شارژ سالن».
/// این صفحه فقط نمایشی است؛ داده‌ای در آن ویرایش نمی‌شود (به‌جز حذف بایگانی)
class ArchiveScreen extends StatelessWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final initial = args is int && (args == 0 || args == 1) ? args : 0;
    final check = context.watch<AppState>();
    final hall = context.watch<HallChargeState>();

    return DefaultTabController(
      length: 2,
      initialIndex: initial,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('بایگانی'),
          bottom: const TabBar(
            labelColor: AppColors.primaryDark,
            unselectedLabelColor: AppColors.textMuted,
            indicatorColor: AppColors.primary,
            labelStyle:
                TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w700),
            unselectedLabelStyle: TextStyle(fontFamily: 'Vazirmatn'),
            tabs: [
              Tab(text: 'چک کردن شارژ'),
              Tab(text: 'شارژ سالن'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ArchiveList(
              sessions: check.archives,
              unit: 'اسکن',
              color: AppColors.primary,
              onDelete: check.deleteArchive,
              onClear: check.clearArchives,
            ),
            _ArchiveList(
              sessions: hall.archives,
              unit: 'تایید',
              color: AppColors.hall,
              onDelete: hall.deleteArchive,
              onClear: hall.clearArchives,
            ),
          ],
        ),
      ),
    );
  }
}

class _ArchiveList extends StatelessWidget {
  final List<ArchivedSession> sessions;
  final String unit;
  final Color color;
  final Future<void> Function(int index) onDelete;
  final Future<void> Function() onClear;

  const _ArchiveList({
    required this.sessions,
    required this.unit,
    required this.color,
    required this.onDelete,
    required this.onClear,
  });

  Future<void> _confirmDeleteOne(BuildContext context, int index) async {
    final ok = await confirmDialog(
      context,
      title: 'حذف از بایگانی',
      message: 'این مورد برای همیشه حذف می‌شود. ادامه می‌دهید؟',
      confirmLabel: 'حذف',
      destructive: true,
    );
    if (ok) await onDelete(index);
  }

  Future<void> _confirmClearAll(BuildContext context) async {
    final ok = await confirmDialog(
      context,
      title: 'خالی کردن بایگانی',
      message: 'همه‌ی موارد این بخش برای همیشه حذف می‌شوند. ادامه می‌دهید؟',
      confirmLabel: 'حذف همه',
      destructive: true,
    );
    if (ok) await onClear();
  }

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.archive_outlined, size: 48, color: color),
              ),
              const SizedBox(height: 18),
              const Text('هنوز موردی بایگانی نشده است',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Text(
                'وقتی فایل اکسل جدیدی جایگزین فایل فعلی شود، فایل قبلی همراه نتیجه‌ی کارش این‌جا نگه داشته می‌شود.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13, color: AppColors.textMuted, height: 1.8),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: sessions.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              onPressed: () => _confirmClearAll(context),
              icon: const Icon(Icons.delete_sweep_rounded, size: 20),
              label: const Text('خالی کردن این بخش'),
              style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            ),
          );
        }
        final i = index - 1;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _ArchiveCard(
            session: sessions[i],
            unit: unit,
            color: color,
            onDelete: () => _confirmDeleteOne(context, i),
          ),
        );
      },
    );
  }
}

class _ArchiveCard extends StatelessWidget {
  final ArchivedSession session;
  final String unit;
  final Color color;
  final VoidCallback onDelete;

  const _ArchiveCard({
    required this.session,
    required this.unit,
    required this.color,
    required this.onDelete,
  });

  String _formatDate(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, '0');
    return toFaDigits(
        '${dt.year}/${two(dt.month)}/${two(dt.day)} - ${two(dt.hour)}:${two(dt.minute)}');
  }

  @override
  Widget build(BuildContext context) {
    final complete = session.isComplete;
    final statusColor = complete ? AppColors.success : AppColors.warning;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        leading: CircleAvatar(
          backgroundColor: statusColor.withValues(alpha: 0.14),
          child: Icon(
            complete ? Icons.verified_rounded : Icons.hourglass_bottom_rounded,
            color: statusColor,
          ),
        ),
        title: Text(
          session.fileName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            '${_formatDate(session.archivedAt)}  •  ${toFaDigits(session.products.length)} کالا  •  '
            '${toFaDigits(session.totalScanned)}/${toFaDigits(session.totalRequired)} $unit',
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ),
        children: [
          const Divider(height: 1),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 320),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: session.products.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final p = session.products[i];
                final scanned = session.scannedCountFor(p.code);
                final done = p.requiredCount > 0 && scanned >= p.requiredCount;
                return ListTile(
                  dense: true,
                  title: Text(p.title,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Directionality(
                    textDirection: TextDirection.ltr,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(p.code, style: const TextStyle(fontSize: 11)),
                    ),
                  ),
                  trailing: Text(
                    '${toFaDigits(scanned)} / ${toFaDigits(p.requiredCount)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: done ? AppColors.success : AppColors.textMuted,
                    ),
                  ),
                );
              },
            ),
          ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 6),
              child: TextButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded, size: 20),
                label: const Text('حذف این مورد'),
                style: TextButton.styleFrom(foregroundColor: AppColors.danger),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
