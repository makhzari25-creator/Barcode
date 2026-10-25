import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../services/hall_charge_state.dart';
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
import 'paper_import_screen.dart';

/// صفحه‌ی «شارژ سالن»
/// یک فایل اکسل با ستون‌های «کد محصول» و «عنوان محصول» بارگذاری می‌شود و
/// با اسکن بارکد هر کالا، تطبیق کد با نام محصول تایید می‌شود (بدون شمارش تعداد).
class ChargeHallScreen extends StatefulWidget {
  const ChargeHallScreen({super.key});

  @override
  State<ChargeHallScreen> createState() => _ChargeHallScreenState();
}

class _ChargeHallScreenState extends State<ChargeHallScreen>
    with ScannerHost<ChargeHallScreen> {
  static const _accent = AppColors.hall;

  ScanFeedback? _feedback;
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && context.read<HallChargeState>().hasFile) {
        initScanner();
      }
    });
  }

  Future<void> _pickExcelFile() async {
    final state = context.read<HallChargeState>();
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


  Future<void> _importPaper() async {
    final ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PaperImportScreen(mode: 1, accent: _accent),
      ),
    );
    if (!mounted) return;
    if (ok == true && context.read<HallChargeState>().hasFile) {
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
    }
  }

  @override
  Future<void> handleCode(String code) async {
    final state = context.read<HallChargeState>();
    final wasComplete = state.isFullyComplete;
    final result = await state.recordScan(code);
    final product = state.findProduct(code);
    await giveFeedback(ok: result != HallScanResult.notFound);
    if (!mounted) return;

    setState(() {
      _feedback = switch (result) {
        HallScanResult.notFound => ScanFeedback(
            kind: FeedbackKind.error,
            title: 'این کالا در لیست شارژ سالن نیست',
            code: normalizeCode(code),
          ),
        HallScanResult.confirmed => ScanFeedback(
            kind: FeedbackKind.success,
            title: 'کالا در لیست شارژ سالن است',
            code: normalizeCode(code),
            product: product,
            badge: 'کد کالا تایید شد',
          ),
        HallScanResult.alreadyConfirmed => ScanFeedback(
            kind: FeedbackKind.info,
            title: 'این کالا قبلاً تایید شده بود',
            code: normalizeCode(code),
            product: product,
            badge: 'قبلاً تایید شده است',
          ),
      };
    });

    if (!wasComplete && state.isFullyComplete) {
      await showCompleteDialog(
        context,
        message: 'همه کالاهای شارژ سالن تایید شدند.',
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
      title: 'ریست تاییدها',
      message: 'همه‌ی تاییدها پاک می‌شود؛ لیست کالاها باقی می‌ماند.',
      confirmLabel: 'ریست',
      destructive: true,
    );
    if (!ok || !mounted) return;
    await context.read<HallChargeState>().resetConfirmations();
    if (!mounted) return;
    setState(() => _feedback = null);
    showAppSnack(context, 'تاییدها ریست شدند.', kind: SnackKind.success);
  }

  Future<void> _confirmReplace() async {
    final ok = await confirmDialog(
      context,
      title: 'جایگزینی فایل اکسل',
      message:
          'اگر کالایی تایید شده باشد، فایل فعلی با تاییدهایش به «بایگانی» می‌رود و فایل جدید از صفر شروع می‌شود.',
      confirmLabel: 'انتخاب فایل',
    );
    if (ok && mounted) await _pickExcelFile();
  }

  List<Product> _visibleProducts(HallChargeState state) {
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
    // کالاهای تاییدنشده اول می‌آیند تا کار باقی‌مانده دیده شود
    entries.sort((a, b) {
      final ca = state.isConfirmed(a.$2.code) ? 1 : 0;
      final cb = state.isConfirmed(b.$2.code) ? 1 : 0;
      final r = ca.compareTo(cb);
      return r != 0 ? r : a.$1.compareTo(b.$1);
    });
    return entries.map((e) => e.$2).toList();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<HallChargeState>();

    if (state.loading && !state.hasFile) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('شارژ سالن'),
          actions: [
            IconButton(
              tooltip: 'ورود از عکس کاغذ',
              onPressed: _importPaper,
              icon: const Icon(Icons.document_scanner_rounded),
            ),
          ],
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (!state.hasFile) {
      return Scaffold(
        appBar: AppBar(title: const Text('شارژ سالن')),
        body: EmptyFileState(
          title: 'فایل اکسل شارژ سالن را انتخاب کنید',
          hint: 'با اسکن هر کالا، تطابق کد و نام محصول تایید می‌شود.',
          color: _accent,
          showCountColumn: false,
          onPick: _pickExcelFile,
          onPaper: _importPaper,
        ),
      );
    }

    ensureScanner(hasFile: state.hasFile);
    final products = _visibleProducts(state);

    return Scaffold(
      appBar: AppBar(
        title: const Text('شارژ سالن'),
        actions: [
          IconButton(
            tooltip: 'ورود از عکس کاغذ',
            onPressed: _importPaper,
            icon: const Icon(Icons.document_scanner_rounded),
          ),
          PopupMenuButton<String>(
            tooltip: 'گزینه‌ها',
            onSelected: (v) {
              switch (v) {
                case 'archive':
                  Navigator.of(context).pushNamed('/archive', arguments: 1);
                case 'reset':
                  _confirmReset();
                case 'replace':
                  _confirmReplace();
                case 'paper':
                  _importPaper();
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'archive', child: Text('بایگانی')),
              PopupMenuItem(value: 'reset', child: Text('ریست تاییدها')),
              PopupMenuItem(value: 'replace', child: Text('جایگزینی فایل اکسل')),
              PopupMenuItem(value: 'paper', child: Text('ورود از عکس کاغذ')),
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
                FileCard(
                  fileName: state.fileName ?? '',
                  productCount: state.products.length,
                  onTap: _confirmReplace,
                ),
                const SizedBox(height: 10),
                ProgressHeader(
                  done: state.confirmedCount,
                  total: state.products.length,
                  progress: state.progress,
                  color: _accent,
                  doneLabel: 'کالا تایید شده',
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
                      scanned: state.isConfirmed(p.code) ? 1 : 0,
                      required: 1,
                      color: _accent,
                      showCounts: false,
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
