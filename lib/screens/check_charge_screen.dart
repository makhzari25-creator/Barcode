import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../services/app_state.dart';
import '../theme/app_colors.dart';
import '../utils/barcode_utils.dart';
import '../widgets/dialogs.dart';
import '../widgets/file_widgets.dart';
import '../widgets/manual_entry_dialog.dart';
import '../widgets/product_status_row.dart';
import '../widgets/progress_header.dart';
import '../widgets/scan_actions.dart';
import '../widgets/scan_result_card.dart';
import '../widgets/scanner_host.dart';
import '../widgets/scanner_panel.dart';

/// صفحه چک کردن شارژ
/// 1. اگر فایل اکسل انتخاب نشده، اول از کاربر می‌خواهد فایل را انتخاب کند
/// 2. بارکدخوان دوربین فعال می‌شود
/// 3. بعد از هر اسکن، نتیجه زیر دوربین نمایش داده می‌شود
class CheckChargeScreen extends StatefulWidget {
  const CheckChargeScreen({super.key});

  @override
  State<CheckChargeScreen> createState() => _CheckChargeScreenState();
}

class _CheckChargeScreenState extends State<CheckChargeScreen>
    with ScannerHost<CheckChargeScreen> {
  static const _accent = AppColors.primary;

  ScanFeedback? _feedback;
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && context.read<AppState>().hasFile) {
        initScanner();
      }
    });
  }

  Future<void> _pickExcelFile() async {
    final state = context.read<AppState>();
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        withData: false,
      );
      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;
      final path = file.path;
      if (path == null) return;

      final ok = await state.loadExcelFile(path, fileName: file.name);
      if (!mounted) return;
      if (ok) {
        showAppSnack(
          context,
          'فایل با موفقیت بارگذاری شد (${toFaDigits(state.products.length)} کالا).',
          kind: SnackKind.success,
        );
        setState(() {
          _feedback = null;
          _query = '';
          scanPaused = false;
        });
        if (scannerController == null) {
          initScanner();
        } else {
          await resumeScanner();
        }
      } else {
        showAppSnack(context, state.error ?? 'بارگذاری فایل ناموفق بود.',
            kind: SnackKind.error);
      }
    } catch (e) {
      if (!mounted) return;
      showAppSnack(context, 'خطا در انتخاب فایل: $e', kind: SnackKind.error);
    }
  }

  @override
  Future<void> handleCode(String code) async {
    final state = context.read<AppState>();
    final wasComplete = state.isFullyComplete;
    final result = await state.recordScan(code);
    final product = state.findProduct(code);
    await giveFeedback(ok: result != ScanResult.notFound);
    if (!mounted) return;

    final scanned = product == null ? null : state.scannedCountFor(product.code);
    setState(() {
      _feedback = switch (result) {
        ScanResult.notFound => ScanFeedback(
            kind: FeedbackKind.error,
            title: 'این کالا در شارژ سالن نیست',
            code: normalizeCode(code),
          ),
        ScanResult.scanned => ScanFeedback(
            kind: FeedbackKind.success,
            title: 'اسکن شد',
            code: normalizeCode(code),
            product: product,
            scanned: scanned,
            required: product?.requiredCount,
          ),
        ScanResult.justCompleted => ScanFeedback(
            kind: FeedbackKind.success,
            title: 'شارژ این کالا کامل شد',
            code: normalizeCode(code),
            product: product,
            scanned: scanned,
            required: product?.requiredCount,
          ),
        ScanResult.alreadyComplete => ScanFeedback(
            kind: FeedbackKind.info,
            title: 'شارژ این کالا قبلاً کامل شده است',
            code: normalizeCode(code),
            product: product,
            scanned: scanned,
            required: product?.requiredCount,
          ),
      };
    });

    if (!wasComplete && state.isFullyComplete) {
      await showCompleteDialog(
        context,
        message: 'همه کالاها به تعداد لازم اسکن شدند.',
      );
    }
  }

  Future<void> _manualEntry() async {
    final wasPaused = scanPaused;
    await pauseScanner();
    if (!mounted) return;
    final code = await showManualEntryDialog(context);
    if (!mounted) return;
    if (code == null || normalizeCode(code).isEmpty) {
      if (!wasPaused) await resumeScanner();
      return;
    }
    await processCode(code);
  }

  Future<void> _confirmReset() async {
    final ok = await confirmDialog(
      context,
      title: 'ریست شمارنده‌ها',
      message: 'همه‌ی شمارنده‌ها صفر می‌شود؛ لیست کالاها باقی می‌ماند.',
      confirmLabel: 'ریست',
      destructive: true,
    );
    if (!ok || !mounted) return;
    await context.read<AppState>().resetCounters();
    if (!mounted) return;
    setState(() => _feedback = null);
    showAppSnack(context, 'شمارنده‌ها ریست شدند.', kind: SnackKind.success);
  }

  Future<void> _confirmReplace() async {
    final ok = await confirmDialog(
      context,
      title: 'جایگزینی فایل اکسل',
      message:
          'اگر اسکنی ثبت شده باشد، فایل فعلی با نتیجه‌ی اسکن‌هایش به «بایگانی» می‌رود و فایل جدید از صفر شروع می‌شود.',
      confirmLabel: 'انتخاب فایل',
    );
    if (ok && mounted) await _pickExcelFile();
  }

  List<Product> _visibleProducts(AppState state) {
    final q = toEnDigits(_query.trim().toLowerCase());
    final entries = <(int, Product)>[];
    for (var i = 0; i < state.products.length; i++) {
      final p = state.products[i];
      if (q.isEmpty ||
          p.title.toLowerCase().contains(q) ||
          p.code.contains(q)) {
        entries.add((i, p));
      }
    }
    int rank(Product p) {
      if (state.isProductComplete(p)) return 2;
      return state.scannedCountFor(p.code) > 0 ? 0 : 1;
    }

    entries.sort((a, b) {
      final r = rank(a.$2).compareTo(rank(b.$2));
      return r != 0 ? r : a.$1.compareTo(b.$1);
    });
    return entries.map((e) => e.$2).toList();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    if (state.loading && !state.hasFile) {
      return Scaffold(
        appBar: AppBar(title: const Text('چک کردن شارژ')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (!state.hasFile) {
      return Scaffold(
        appBar: AppBar(title: const Text('چک کردن شارژ')),
        body: EmptyFileState(
          title: 'ابتدا فایل اکسل شارژ سالن را انتخاب کنید',
          hint: 'برای هر کالا تعداد لازم از ستون «تعداد» خوانده می‌شود.',
          color: _accent,
          showCountColumn: true,
          onPick: _pickExcelFile,
        ),
      );
    }

    ensureScanner(hasFile: state.hasFile);
    final products = _visibleProducts(state);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('چک کردن شارژ'),
            Text(
              state.excelFileName ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textMuted),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'گزینه‌ها',
            onSelected: (v) {
              switch (v) {
                case 'archive':
                  Navigator.of(context).pushNamed('/archive', arguments: 0);
                case 'reset':
                  _confirmReset();
                case 'replace':
                  _confirmReplace();
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'archive', child: Text('بایگانی')),
              PopupMenuItem(value: 'reset', child: Text('ریست شمارنده‌ها')),
              PopupMenuItem(value: 'replace', child: Text('جایگزینی فایل اکسل')),
            ],
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                ProgressHeader(
                  done: state.completedCount,
                  total: state.products.length,
                  progress: state.progress,
                  color: _accent,
                ),
                const SizedBox(height: 12),
                ScannerPanel(
                  controller: scannerController,
                  ready: scannerReady,
                  paused: scanPaused,
                  onDetect: onDetect,
                  onResume: resumeScanner,
                ),
                const SizedBox(height: 12),
                ScanResultCard(
                  feedback: _feedback,
                  accent: _accent,
                  onNext: scanPaused ? resumeScanner : null,
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ScanActionButton(
                      icon: torchOn
                          ? Icons.flashlight_on_rounded
                          : Icons.flashlight_off_rounded,
                      label: 'چراغ قوه',
                      active: torchOn,
                      color: _accent,
                      onTap: toggleTorch,
                    ),
                    ScanActionButton(
                      icon: Icons.keyboard_alt_outlined,
                      label: 'ورود دستی',
                      color: _accent,
                      onTap: _manualEntry,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('وضعیت کالاها',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                    const Spacer(),
                    Text('${toFaDigits(products.length)} کالا',
                        style: const TextStyle(
                            fontSize: 12.5, color: AppColors.textMuted)),
                  ],
                ),
                const SizedBox(height: 10),
                ProductSearchField(
                  onChanged: (v) => setState(() => _query = v),
                ),
                const SizedBox(height: 12),
              ]),
            ),
          ),
          if (products.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text('کالایی با این مشخصات پیدا نشد.',
                      style: TextStyle(color: AppColors.textMuted)),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final p = products[i];
                    return ProductStatusRow(
                      product: p,
                      scanned: state.scannedCountFor(p.code),
                      required: p.requiredCount,
                      color: _accent,
                    );
                  },
                  childCount: products.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
