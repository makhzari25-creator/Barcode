import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/ocr_import_service.dart';
import '../theme/app_colors.dart';
import '../utils/barcode_utils.dart';
import '../widgets/dialogs.dart';
import 'ocr_review_screen.dart';

/// Multi-page paper photo import flow.
class PaperImportScreen extends StatefulWidget {
  /// 0 = check charge (AppState), 1 = hall charge (HallChargeState)
  final int mode;
  final Color accent;

  const PaperImportScreen({
    super.key,
    required this.mode,
    required this.accent,
  });

  @override
  State<PaperImportScreen> createState() => _PaperImportScreenState();
}

class _PaperImportScreenState extends State<PaperImportScreen> {
  int _pageCount = 1;
  final List<String> _paths = [];
  bool _processing = false;
  String? _status;
  final _picker = ImagePicker();
  final _ocr = OcrImportService();

  @override
  void dispose() {
    _ocr.dispose();
    super.dispose();
  }

  Future<void> _captureNext() async {
    if (_paths.length >= _pageCount) return;
    final x = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 95,
      preferredCameraDevice: CameraDevice.rear,
    );
    if (x == null) return;
    setState(() => _paths.add(x.path));
  }

  Future<void> _pickFromGallery() async {
    if (_paths.length >= _pageCount) return;
    final x = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 95,
    );
    if (x == null) return;
    setState(() => _paths.add(x.path));
  }

  void _removeAt(int i) => setState(() => _paths.removeAt(i));

  Future<void> _process() async {
    if (_paths.length != _pageCount) {
      showAppSnack(
        context,
        'باید دقیقاً ${toFaDigits(_pageCount)} عکس بگیرید.',
        kind: SnackKind.error,
      );
      return;
    }
    setState(() {
      _processing = true;
      _status = 'در حال خواندن متن از عکس‌ها…';
    });
    try {
      final drafts = await _ocr.processPages(List<String>.from(_paths));
      if (!mounted) return;
      if (drafts.isEmpty) {
        setState(() {
          _processing = false;
          _status = null;
        });
        showAppSnack(
          context,
          'هیچ کالایی از عکس‌ها استخراج نشد. عکس واضح‌تر بگیرید.',
          kind: SnackKind.error,
        );
        return;
      }
      setState(() => _status = 'باز کردن صفحه بازبینی…');
      final confirmed = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => OcrReviewScreen(
            drafts: drafts,
            mode: widget.mode,
            accent: widget.accent,
          ),
        ),
      );
      if (!mounted) return;
      if (confirmed == true) {
        Navigator.of(context).pop(true);
      } else {
        setState(() {
          _processing = false;
          _status = null;
        });
      }
    } on OcrImportException catch (e) {
      if (!mounted) return;
      setState(() {
        _processing = false;
        _status = null;
      });
      showAppSnack(context, e.message, kind: SnackKind.error);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _processing = false;
        _status = null;
      });
      showAppSnack(context, 'خطا در پردازش: $e', kind: SnackKind.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final remaining = _pageCount - _paths.length;
    return Scaffold(
      appBar: AppBar(title: const Text('ورود از عکس کاغذ')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          const Text(
            'تعداد صفحات سند را مشخص کنید، سپس به همان تعداد عکس واضح از جدول بگیرید.',
            style: TextStyle(height: 1.7, color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          const Text('تعداد صفحات',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton.filledTonal(
                onPressed: _pageCount > 1
                    ? () => setState(() {
                          _pageCount--;
                          if (_paths.length > _pageCount) {
                            _paths.removeRange(_pageCount, _paths.length);
                          }
                        })
                    : null,
                icon: const Icon(Icons.remove),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  toFaDigits(_pageCount),
                  style: const TextStyle(
                      fontSize: 28, fontWeight: FontWeight.w800),
                ),
              ),
              IconButton.filledTonal(
                onPressed:
                    _pageCount < 15 ? () => setState(() => _pageCount++) : null,
                icon: const Icon(Icons.add),
              ),
              const Spacer(),
              Text(
                '${toFaDigits(_paths.length)} از ${toFaDigits(_pageCount)}',
                style: TextStyle(
                  color:
                      remaining == 0 ? AppColors.success : AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_paths.isNotEmpty) ...[
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _paths.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) => Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(_paths[i]),
                        width: 90,
                        height: 110,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      left: 4,
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.black54,
                        child: Text(toFaDigits(i + 1),
                            style: const TextStyle(
                                fontSize: 11, color: Colors.white)),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () => _removeAt(i),
                        icon: const Icon(Icons.cancel, color: Colors.redAccent),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (remaining > 0) ...[
            FilledButton.icon(
              onPressed: _processing ? null : _captureNext,
              style: FilledButton.styleFrom(
                backgroundColor: widget.accent,
                minimumSize: const Size(0, 56),
              ),
              icon: const Icon(Icons.photo_camera_rounded),
              label: Text(
                _paths.isEmpty
                    ? 'عکس صفحه ۱'
                    : 'عکس صفحه ${toFaDigits(_paths.length + 1)}',
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _processing ? null : _pickFromGallery,
              style: OutlinedButton.styleFrom(minimumSize: const Size(0, 52)),
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('انتخاب از گالری'),
            ),
          ] else ...[
            FilledButton.icon(
              onPressed: _processing ? null : _process,
              style: FilledButton.styleFrom(
                backgroundColor: widget.accent,
                minimumSize: const Size(0, 56),
              ),
              icon: _processing
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.document_scanner_rounded),
              label: Text(
                  _processing ? (_status ?? 'پردازش…') : 'شروع خواندن و بازبینی'),
            ),
          ],
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('راهنمای عکس خوب',
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                SizedBox(height: 8),
                Text(
                  '• کاغذ صاف و نور کافی\n'
                  '• کل جدول داخل کادر باشد\n'
                  '• از بالا روبه‌رو بگیرید (کج نباشد)\n'
                  '• بعد از OCR حتماً ردیف‌ها را در بازبینی چک کنید',
                  style: TextStyle(
                      fontSize: 13, height: 1.7, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
