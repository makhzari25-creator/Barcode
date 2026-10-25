import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';
import '../services/hall_charge_state.dart';
import '../services/ocr_import_service.dart';
import '../theme/app_colors.dart';
import '../utils/barcode_utils.dart';
import '../widgets/dialogs.dart';

/// Review and edit OCR results before committing to charge flow.
class OcrReviewScreen extends StatefulWidget {
  final List<OcrProductDraft> drafts;
  final int mode;
  final Color accent;

  const OcrReviewScreen({
    super.key,
    required this.drafts,
    required this.mode,
    required this.accent,
  });

  @override
  State<OcrReviewScreen> createState() => _OcrReviewScreenState();
}

class _OcrReviewScreenState extends State<OcrReviewScreen> {
  late List<OcrProductDraft> _items;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _items = List<OcrProductDraft>.from(widget.drafts);
  }

  int get _lowCount => _items.where((e) => e.lowConfidence).length;

  Future<void> _edit(int index) async {
    final d = _items[index];
    final codeCtrl = TextEditingController(text: d.code);
    final titleCtrl = TextEditingController(text: d.title);
    final qtyCtrl = TextEditingController(text: '${d.requiredCount}');
    final whCtrl = TextEditingController(text: d.warehouseLoc);
    final colorCtrl = TextEditingController(text: d.color);
    final designCtrl = TextEditingController(text: d.design);
    final sizeCtrl = TextEditingController(text: d.size);
    final hallCtrl = TextEditingController(text: d.hallLoc);

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('ویرایش ردیف ${toFaDigits(index + 1)}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: codeCtrl,
                decoration: const InputDecoration(labelText: 'کد محصول'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'عنوان'),
                maxLines: 2,
              ),
              TextField(
                controller: qtyCtrl,
                decoration: const InputDecoration(labelText: 'تعداد'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: whCtrl,
                decoration: const InputDecoration(labelText: 'م.ف. انبار'),
              ),
              TextField(
                controller: colorCtrl,
                decoration: const InputDecoration(labelText: 'رنگ'),
              ),
              TextField(
                controller: designCtrl,
                decoration: const InputDecoration(labelText: 'طرح'),
              ),
              TextField(
                controller: sizeCtrl,
                decoration: const InputDecoration(labelText: 'سایز'),
              ),
              TextField(
                controller: hallCtrl,
                decoration: const InputDecoration(
                    labelText: 'م.ف. سالن (۳ رقم، مثل ۰۳۱)'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('انصراف')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('ذخیره')),
        ],
      ),
    );

    if (ok == true && mounted) {
      setState(() {
        d.code = toEnDigits(codeCtrl.text.trim());
        d.title = titleCtrl.text.trim();
        d.requiredCount = int.tryParse(toEnDigits(qtyCtrl.text.trim())) ?? 1;
        if (d.requiredCount < 1) d.requiredCount = 1;
        d.warehouseLoc = whCtrl.text.trim();
        d.color = colorCtrl.text.trim();
        d.design = designCtrl.text.trim();
        d.size = sizeCtrl.text.trim();
        d.hallLoc = toEnDigits(hallCtrl.text.trim());
        if (d.hallLoc.length > 3) d.hallLoc = d.hallLoc.substring(0, 3);
        d.lowConfidence = d.code.length < 12 || d.title.isEmpty;
      });
    }
  }

  Future<void> _confirm() async {
    final valid = _items
        .where((e) => normalizeCode(e.code).length >= 8)
        .map((e) => e.toProduct())
        .toList();
    if (valid.isEmpty) {
      showAppSnack(context, 'هیچ ردیف معتبری برای ذخیره نیست.',
          kind: SnackKind.error);
      return;
    }
    final ok = await confirmDialog(
      context,
      title: 'تأیید لیست',
      message:
          '${toFaDigits(valid.length)} کالا وارد می‌شود. ردیف‌های علامت‌دار را حتماً چک کرده باشید.',
      confirmLabel: 'ورود به شارژ',
    );
    if (!ok || !mounted) return;

    setState(() => _saving = true);
    final label = 'عکس کاغذ (${toFaDigits(valid.length)} کالا)';
    bool success;
    if (widget.mode == 0) {
      success = await context
          .read<AppState>()
          .loadProductsList(valid, fileName: label);
    } else {
      success = await context
          .read<HallChargeState>()
          .loadProductsList(valid, fileName: label);
    }
    if (!mounted) return;
    setState(() => _saving = false);
    if (success) {
      showAppSnack(context, 'لیست با موفقیت بارگذاری شد.',
          kind: SnackKind.success);
      Navigator.of(context).pop(true);
    } else {
      final err = widget.mode == 0
          ? context.read<AppState>().error
          : context.read<HallChargeState>().error;
      showAppSnack(context, err ?? 'ذخیره ناموفق بود.', kind: SnackKind.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('بازبینی (${toFaDigits(_items.length)} ردیف)'),
        actions: [
          if (_lowCount > 0)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Center(
                child: Text(
                  '${toFaDigits(_lowCount)} مشکوک',
                  style: const TextStyle(
                      color: Colors.orange, fontWeight: FontWeight.w700),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          if (_lowCount > 0)
            Material(
              color: Colors.orange.shade50,
              child: const ListTile(
                dense: true,
                leading:
                    Icon(Icons.warning_amber_rounded, color: Colors.orange),
                title: Text(
                  'ردیف‌های نارنجی را ویرایش کنید. دقت OCR روی فارسی کامل نیست.',
                  style: TextStyle(fontSize: 13, height: 1.5),
                ),
              ),
            ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              itemCount: _items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final d = _items[i];
                return Material(
                  color: d.lowConfidence
                      ? Colors.orange.shade50
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => _edit(i),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: d.lowConfidence
                              ? Colors.orange.shade200
                              : AppColors.border,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(toFaDigits(i + 1),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w800)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  d.code,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'monospace'),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: widget.accent.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '×${toFaDigits(d.requiredCount)}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: widget.accent),
                                ),
                              ),
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                onPressed: () =>
                                    setState(() => _items.removeAt(i)),
                                icon: const Icon(Icons.delete_outline,
                                    color: AppColors.danger),
                              ),
                            ],
                          ),
                          Text(
                            d.title.isEmpty ? '—' : d.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style:
                                const TextStyle(fontSize: 13.5, height: 1.4),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            [
                              if (d.color.isNotEmpty) d.color,
                              if (d.size.isNotEmpty) d.size,
                              if (d.design.isNotEmpty) d.design,
                              if (d.warehouseLoc.isNotEmpty) d.warehouseLoc,
                              if (d.hallLoc.isNotEmpty) 'سالن ${d.hallLoc}',
                            ].join(' · '),
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: FilledButton.icon(
                onPressed: _saving ? null : _confirm,
                style: FilledButton.styleFrom(
                  backgroundColor: widget.accent,
                  minimumSize: const Size(double.infinity, 56),
                ),
                icon: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.check_circle_outline),
                label:
                    Text(_saving ? 'در حال ذخیره…' : 'تأیید و ورود به شارژ'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
