import 'dart:io';
import 'dart:ui' show Rect;

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../models/product.dart';
import '../utils/barcode_utils.dart';

/// Draft product extracted from a paper photo before user review.
class OcrProductDraft {
  String code;
  String title;
  int requiredCount;
  String warehouseLoc;
  String color;
  String design;
  String size;
  String hallLoc;
  bool lowConfidence;

  OcrProductDraft({
    this.code = '',
    this.title = '',
    this.requiredCount = 1,
    this.warehouseLoc = '',
    this.color = '',
    this.design = '',
    this.size = '',
    this.hallLoc = '',
    this.lowConfidence = false,
  });

  Product toProduct() => Product(
        code: normalizeCode(code),
        title: title.isEmpty ? '-' : title,
        requiredCount: requiredCount < 1 ? 1 : requiredCount,
        warehouseLoc: warehouseLoc,
        color: color,
        design: design,
        size: size,
        hallLoc: hallLoc,
      );
}

class OcrImportException implements Exception {
  final String message;
  OcrImportException(this.message);
  @override
  String toString() => message;
}

/// On-device OCR for warehouse charge printouts.
class OcrImportService {
  TextRecognizer? _recognizer;

  TextRecognizer get _r =>
      _recognizer ??= TextRecognizer(script: TextRecognitionScript.latin);

  Future<void> dispose() async {
    await _recognizer?.close();
    _recognizer = null;
  }

  Future<List<OcrProductDraft>> processPages(List<String> imagePaths) async {
    if (imagePaths.isEmpty) {
      throw OcrImportException('هیچ عکسی انتخاب نشده است.');
    }
    final all = <OcrProductDraft>[];
    for (var i = 0; i < imagePaths.length; i++) {
      final page = await processPage(imagePaths[i]);
      debugPrint('OcrImport: page ${i + 1} -> ${page.length} rows');
      all.addAll(page);
    }
    return _mergeByCode(all);
  }

  Future<List<OcrProductDraft>> processPage(String imagePath) async {
    final file = File(imagePath);
    if (!await file.exists()) {
      throw OcrImportException('فایل تصویر پیدا نشد.');
    }

    final input = InputImage.fromFilePath(imagePath);
    final recognized = await _r.processImage(input);

    final blocks = <_OcrBox>[];
    for (final block in recognized.blocks) {
      for (final line in block.lines) {
        final box = line.boundingBox;
        final text = line.text.trim();
        if (text.isEmpty) continue;
        blocks.add(_OcrBox(
          text: text,
          rect: Rect.fromLTRB(
            box.left.toDouble(),
            box.top.toDouble(),
            box.right.toDouble(),
            box.bottom.toDouble(),
          ),
        ));
      }
    }

    if (blocks.isEmpty) {
      throw OcrImportException(
        'متنی در تصویر تشخیص داده نشد. عکس را واضح‌تر و روبه‌رو بگیرید.',
      );
    }

    final minX = blocks.map((b) => b.rect.left).reduce((a, b) => a < b ? a : b);
    final maxX = blocks.map((b) => b.rect.right).reduce((a, b) => a > b ? a : b);
    final width = (maxX - minX).clamp(1.0, double.infinity);

    for (final b in blocks) {
      b.nx = (b.rect.left - minX) / width;
      b.ny = b.rect.top;
      b.nCenterX = ((b.rect.left + b.rect.right) / 2 - minX) / width;
    }

    final rows = _clusterRows(blocks);
    final drafts = <OcrProductDraft>[];
    for (final row in rows) {
      final draft = _parseRow(row);
      if (draft != null && draft.code.isNotEmpty) {
        drafts.add(draft);
      }
    }
    return drafts;
  }

  List<List<_OcrBox>> _clusterRows(List<_OcrBox> blocks) {
    final sorted = List<_OcrBox>.from(blocks)
      ..sort((a, b) => a.ny.compareTo(b.ny));
    if (sorted.isEmpty) return [];

    final heights = sorted.map((b) => b.rect.height).toList()..sort();
    final medianH = heights[heights.length ~/ 2].clamp(12.0, 80.0);
    final threshold = medianH * 0.7;

    final rows = <List<_OcrBox>>[];
    var current = <_OcrBox>[sorted.first];
    var currentY = sorted.first.ny;

    for (var i = 1; i < sorted.length; i++) {
      final b = sorted[i];
      if ((b.ny - currentY).abs() <= threshold) {
        current.add(b);
      } else {
        rows.add(current);
        current = [b];
        currentY = b.ny;
      }
    }
    rows.add(current);
    return rows;
  }

  OcrProductDraft? _parseRow(List<_OcrBox> row) {
    final sorted = List<_OcrBox>.from(row)
      ..sort((a, b) => b.nCenterX.compareTo(a.nCenterX));

    final fullText = sorted.map((b) => b.text).join(' ');
    final fullEn = toEnDigits(fullText);

    final codeMatch =
        RegExp(r'(?<![0-9])([0-9]{12,14})(?![0-9])').firstMatch(fullEn);
    if (codeMatch == null) return null;
    final code = codeMatch.group(1)!;

    final hasRowNumber = RegExp(r'(?<![0-9])([1-9][0-9]{0,2})(?![0-9])')
        .hasMatch(toEnDigits(sorted.take(2).map((e) => e.text).join(' ')));

    String pickInRange(double x0, double x1) {
      final parts = sorted
          .where((b) => b.nCenterX >= x0 && b.nCenterX < x1)
          .map((b) => b.text.trim())
          .where((t) => t.isNotEmpty)
          .toList();
      return parts.join(' ').trim();
    }

    final warehouseRaw = pickInRange(0.78, 0.92);
    final colorRaw = pickInRange(0.68, 0.80);
    final titleRaw = pickInRange(0.28, 0.58);
    final countRaw = pickInRange(0.20, 0.30);
    final designRaw = pickInRange(0.12, 0.22);
    final sizeRaw = pickInRange(0.06, 0.14);
    final hallRaw = pickInRange(0.0, 0.10);

    var qty = 1;
    final countEn = toEnDigits(countRaw);
    final qtyMatch =
        RegExp(r'(?<![0-9])([1-9][0-9]{0,2})(?![0-9])').firstMatch(countEn);
    if (qtyMatch != null) {
      qty = int.tryParse(qtyMatch.group(1)!) ?? 1;
    } else {
      for (final b in sorted) {
        final t = toEnDigits(b.text);
        if (RegExp(r'^[1-9][0-9]{0,2}$').hasMatch(t.trim()) &&
            b.nCenterX < 0.55 &&
            b.nCenterX > 0.15) {
          qty = int.tryParse(t.trim()) ?? 1;
          break;
        }
      }
    }

    var size = sizeRaw;
    final sizeEn = toEnDigits(sizeRaw);
    final sizeMatch = RegExp(
      r'\b(XXXL|XXL|3XL|4XL|5XL|XL|L|M|S|XS|Free|FREE|free|[0-9]{2,3})\b',
      caseSensitive: false,
    ).firstMatch('$sizeEn $fullEn');
    if (sizeMatch != null) size = sizeMatch.group(1)!;

    var warehouse = warehouseRaw;
    final whMatch = RegExp(r'\b\d{1,2}-\d{1,2}-\d{1,2}-\d{1,2}\b')
        .firstMatch(toEnDigits('$warehouseRaw $fullText'));
    if (whMatch != null) warehouse = whMatch.group(0)!;

    final hallLoc = _extractHallLoc(hallRaw.isNotEmpty ? hallRaw : fullText);

    var title = titleRaw;
    if (title.length < 4) {
      final candidates = sorted
          .where((b) => !toEnDigits(b.text).contains(code))
          .map((b) => b.text)
          .where((t) => t.length > 4)
          .toList()
        ..sort((a, b) => b.length.compareTo(a.length));
      if (candidates.isNotEmpty) title = candidates.first;
    }

    var color = colorRaw.replaceAll(RegExp(r'[0-9\-]+'), '').trim();
    if (color.length > 20) color = color.substring(0, 20);

    var design = designRaw;
    if (design.isEmpty && fullText.contains('طرح')) {
      final dm = RegExp(r'طرح\s*([0-9۰-۹]+)').firstMatch(fullText);
      if (dm != null) design = 'طرح ${toEnDigits(dm.group(1)!)}';
    }

    final low = !hasRowNumber ||
        title.length < 3 ||
        code.length < 12 ||
        warehouse.isEmpty;

    return OcrProductDraft(
      code: code,
      title: title,
      requiredCount: qty,
      warehouseLoc: warehouse,
      color: color,
      design: design,
      size: size,
      hallLoc: hallLoc.length >= 3 ? hallLoc.substring(0, 3) : hallLoc,
      lowConfidence: low,
    );
  }

  static String _extractHallLoc(String raw) {
    final en = toEnDigits(raw);
    final m = RegExp(r'\)?\s*([0-9]{3})').firstMatch(en);
    if (m != null) return m.group(1)!;
    final digits = en.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length >= 3) return digits.substring(0, 3);
    return digits;
  }

  List<OcrProductDraft> _mergeByCode(List<OcrProductDraft> list) {
    final map = <String, OcrProductDraft>{};
    for (final d in list) {
      final key = normalizeCode(d.code);
      if (key.isEmpty) continue;
      final existing = map[key];
      if (existing == null) {
        map[key] = d..code = key;
      } else {
        existing.requiredCount += d.requiredCount;
        if (existing.title.length < d.title.length) existing.title = d.title;
        if (existing.warehouseLoc.isEmpty) {
          existing.warehouseLoc = d.warehouseLoc;
        }
        if (existing.color.isEmpty) existing.color = d.color;
        if (existing.design.isEmpty) existing.design = d.design;
        if (existing.size.isEmpty) existing.size = d.size;
        if (existing.hallLoc.isEmpty) existing.hallLoc = d.hallLoc;
        existing.lowConfidence = existing.lowConfidence || d.lowConfidence;
      }
    }
    return map.values.toList();
  }
}

class _OcrBox {
  final String text;
  final Rect rect;
  double nx = 0;
  double ny = 0;
  double nCenterX = 0;

  _OcrBox({required this.text, required this.rect});
}
