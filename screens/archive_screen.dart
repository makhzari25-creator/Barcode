import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../services/app_state.dart';

/// صفحه‌ی بایگانی: فایل‌های اکسل قبلی به‌همراه نتیجه‌ی نهایی اسکن‌هایشان
/// این صفحه فقط نمایشی است؛ داده‌ای در آن ویرایش نمی‌شود (به‌جز حذف بایگانی)
class ArchiveScreen extends StatelessWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final archives = state.archives;

    return Scaffold(
      appBar: AppBar(
        title: const Text('بایگانی'),
        actions: [
          if (archives.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded),
              tooltip: 'خالی کردن بایگانی',
              onPressed: () => _confirmClearAll(context),
            ),
        ],
      ),
      body: archives.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.archive_outlined,
                        size: 84, color: Colors.grey[400]),
                    const SizedBox(height: 20),
                    const Text(
                      'هنوز هیچ فایلی بایگانی نشده است',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'وقتی فایل اکسل جدیدی جایگزین فایل فعلی شود، '
                      'فایل قبلی همراه نتیجه‌ی اسکن‌هایش این‌جا نگه داشته می‌شود.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: archives.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final session = archives[index];
                return _ArchiveCard(
                  session: session,
                  onDelete: () => _confirmDeleteOne(context, index),
                );
              },
            ),
    );
  }

  Future<void> _confirmDeleteOne(BuildContext context, int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف از بایگانی'),
        content: const Text('این مورد برای همیشه حذف می‌شود. ادامه می‌دهید؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('انصراف'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<AppState>().deleteArchive(index);
    }
  }

  Future<void> _confirmClearAll(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('خالی کردن بایگانی'),
        content: const Text('همه‌ی موارد بایگانی‌شده برای همیشه حذف می‌شوند. ادامه می‌دهید؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('انصراف'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('حذف همه'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<AppState>().clearArchives();
    }
  }
}

class _ArchiveCard extends StatelessWidget {
  final ArchivedSession session;
  final VoidCallback onDelete;

  const _ArchiveCard({required this.session, required this.onDelete});

  String _formatDate(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${dt.year}/${two(dt.month)}/${two(dt.day)} - ${two(dt.hour)}:${two(dt.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final complete = session.isComplete;
    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ExpansionTile(
        shape: const Border(),
        leading: CircleAvatar(
          backgroundColor:
              (complete ? const Color(0xFF43A047) : const Color(0xFFFFA726))
                  .withOpacity(0.15),
          child: Icon(
            complete ? Icons.verified_rounded : Icons.hourglass_bottom_rounded,
            color: complete ? const Color(0xFF43A047) : const Color(0xFFFFA726),
          ),
        ),
        title: Text(
          session.fileName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        subtitle: Text(
          '${_formatDate(session.archivedAt)}  •  ${session.products.length} کالا  •  '
          '${session.totalScanned}/${session.totalRequired} اسکن',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
          onPressed: onDelete,
        ),
        children: [
          const Divider(height: 1),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 300),
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
                  subtitle: Text('کد: ${p.code}',
                      style: const TextStyle(fontSize: 11)),
                  trailing: Text(
                    '$scanned / ${p.requiredCount}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: done ? const Color(0xFF43A047) : Colors.black54,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
