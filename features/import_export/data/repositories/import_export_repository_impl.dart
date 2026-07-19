// lib/features/import_export/data/repositories/import_export_repository_impl.dart
//
// پیاده‌سازی ImportExportRepository با پکیج excel
// پشتیبانی کامل از هدرهای فارسی و انگلیسی برای سیستم برداشت
//

import 'dart:io';

import 'package:excel/excel.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../barcode/domain/entities/barcode.dart';
import '../../../picking/domain/entities/picking_item.dart';
import '../../../scanner/domain/entities/scan_record.dart';
import '../../domain/repositories/import_export_repository.dart';

/// استثنای سفارشی برای خطاهای Import فایل
class ImportFileException implements Exception {
  final String message;

  const ImportFileException(this.message);

  @override
  String toString() => message;
}

/// پیاده‌سازی ImportExportRepository
class ImportExportRepositoryImpl implements ImportExportRepository {
  @override
  Future<List<Barcode>> readBarcodesFromFile(String filePath) async {
    final items = await readPickingItemsFromFile(filePath);
    // تبدیل PickingItem به Barcode (برای backward compatibility)
    return items
        .map((item) => Barcode(
              code: item.barcode,
              productName: item.productName,
              productCode: item.productCode,
              category: item.design,
              size: item.size,
              color: item.color,
              createdAt: item.createdAt,
            ))
        .toList();
  }

  /// خواندن آیتم‌های برداشت از فایل Excel/CSV
  ///
  /// ستون‌های موردنیاز (با نام‌های فارسی و انگلیسی):
  /// - بارکد (الزامی): barcode, بارکد, کد بارکد, کد
  /// - م.ف.ا: م.ف.ا, مکان_فیزیکی_انبار, location_warehouse, مکان فیزیکی انبار
  /// - م.ف.سالن: م.ف.سالن, مکان_سالن, location_hall, مکان سالن
  /// - رنگ: رنگ, color
  /// - کد محصول: کد محصول, کد کالا, product_code, sku
  /// - عنوان محصول: عنوان محصول, نام محصول, product_name, name
  /// - تعداد: تعداد, quantity, qty, count
  /// - جنسیت: جنسیت, gender
  /// - طرح: طرح, design, pattern
  /// - سایز: سایز, size
  Future<List<PickingItem>> readPickingItemsFromFile(String filePath) async {
    if (filePath.isEmpty) {
      throw const ImportFileException('مسیر فایل خالی است.');
    }

    final ext = p.extension(filePath).toLowerCase();
    if (ext == '.csv') {
      return _readPickingItemsFromCsv(filePath);
    }
    return _readPickingItemsFromExcel(filePath);
  }

  // ============ EXCEL ============

  Future<List<PickingItem>> _readPickingItemsFromExcel(String filePath) async {
    // ۱. خواندن فایل
    final List<int> bytes;
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw ImportFileException(
          'فایل پیدا نشد. لطفاً فایل را مجدداً انتخاب کنید.\nمسیر: $filePath',
        );
      }
      bytes = file.readAsBytesSync();
    } catch (e) {
      if (e is ImportFileException) rethrow;
      throw ImportFileException('خطا در خواندن فایل: $e');
    }

    // ۲. decode
    final Excel excel;
    try {
      excel = Excel.decodeBytes(bytes);
    } catch (e) {
      throw ImportFileException(
        'فرمت فایل اکسل نامعتبر است. فقط فایل‌های xlsx یا xls پشتیبانی می‌شوند.\nخطا: $e',
      );
    }

    if (excel.tables.isEmpty) {
      throw const ImportFileException('فایل اکسل هیچ شیتی ندارد.');
    }

    // ۳. پیدا کردن اولین شیت غیرخالی
    final String? sheetName = _findFirstNonEmptySheet(excel);
    if (sheetName == null) {
      throw const ImportFileException(
        'هیچ شیت با داده در فایل پیدا نشد. لطفاً مطمئن شوید فایل شامل حداقل یک سطر هدر و یک سطر داده است.',
      );
    }

    final Sheet? table = excel.tables[sheetName];
    if (table == null) {
      throw ImportFileException('شیت «$sheetName» در فایل پیدا نشد.');
    }

    if (table.rows.isEmpty) {
      throw ImportFileException(
        'شیت «$sheetName» خالی است. حداقل یک سطر هدر و یک سطر داده لازم است.',
      );
    }
    if (table.rows.length < 2) {
      throw ImportFileException(
        'فقط یک سطر در شیت «$sheetName» پیدا شد. حداقل یک سطر هدر و یک سطر داده لازم است.',
      );
    }

    // ۴. پیدا کردن سطر هدر
    final _HeaderResult? headerResult = _findHeaderRow(table);
    if (headerResult == null) {
      final sampleHeaders = _collectAllHeaderCandidates(table);
      throw ImportFileException(
        'ستون «بارکد» در فایل پیدا نشد.\n'
        'ستون‌های پیدا شده: ${sampleHeaders.isEmpty ? "هیچ" : sampleHeaders.join("، ")}\n\n'
        'ستون‌های موردنیاز:\n'
        '• بارکد (الزامی): barcode, بارکد, کد بارکد, کد\n'
        '• م.ف.ا (مکان فیزیکی انبار)\n'
        '• م.ف.سالن (مکان سالن)\n'
        '• رنگ\n'
        '• کد محصول\n'
        '• عنوان محصول\n'
        '• تعداد\n'
        '• جنسیت\n'
        '• طرح\n'
        '• سایز',
      );
    }

    final Map<String, int> columnMap = headerResult.columnMap;
    final int headerRowIndex = headerResult.rowIndex;

    // بررسی ستون barcode (الزامی)
    final int? barcodeColNullable = columnMap['barcode'];
    if (barcodeColNullable == null) {
      throw const ImportFileException('ستون بارکد در فایل پیدا نشد.');
    }
    final int barcodeCol = barcodeColNullable;

    // ۵. خواندن سطرهای داده
    final List<PickingItem> items = [];
    int skippedRows = 0;

    for (int i = headerRowIndex + 1; i < table.rows.length; i++) {
      try {
        final List<Data?> row = table.rows[i];

        if (_isRowEmpty(row)) {
          skippedRows++;
          continue;
        }

        // خواندن بارکد
        final String? barcode = _safeReadCell(row, barcodeCol);
        if (barcode == null || barcode.isEmpty) {
          skippedRows++;
          continue;
        }

        final String normalizedBarcode = _normalizeDigits(barcode.trim());

        // خواندن سایر ستون‌ها
        final String? locationWarehouse =
            _readOptionalCell(row, columnMap, 'location_warehouse');
        final String? locationHall =
            _readOptionalCell(row, columnMap, 'location_hall');
        final String? color = _readOptionalCell(row, columnMap, 'color');
        final String? productCode =
            _readOptionalCell(row, columnMap, 'product_code');
        final String? productName =
            _readOptionalCell(row, columnMap, 'product_name');
        final int quantity =
            _parseInt(_readOptionalCell(row, columnMap, 'quantity')) ?? 1;
        final String? gender = _readOptionalCell(row, columnMap, 'gender');
        final String? design = _readOptionalCell(row, columnMap, 'design');
        final String? size = _readOptionalCell(row, columnMap, 'size');

        items.add(PickingItem(
          locationWarehouse: locationWarehouse ?? '',
          locationHall: locationHall,
          color: color,
          productCode: productCode,
          productName: productName,
          quantity: quantity,
          gender: gender,
          design: design,
          size: size,
          barcode: normalizedBarcode,
          createdAt: DateTime.now(),
        ));
      } catch (e) {
        skippedRows++;
      }
    }

    if (items.isEmpty) {
      throw const ImportFileException(
        'هیچ آیتم معتبری در فایل پیدا نشد. لطفاً مطمئن شوید ستون «بارکد» حاوی داده است.',
      );
    }

    // ۶. مرتب‌سازی بر اساس م.ف.ا (صعودی)
    items.sort((a, b) {
      final locA = a.locationWarehouse.trim();
      final locB = b.locationWarehouse.trim();
      return locA.compareTo(locB);
    });

    // ۷. تنظیم sortOrder پس از مرتب‌سازی
    for (int i = 0; i < items.length; i++) {
      items[i] = items[i].copyWith(sortOrder: i);
    }

    return items;
  }

  // ============ CSV ============

  Future<List<PickingItem>> _readPickingItemsFromCsv(String filePath) async {
    final String content;
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw ImportFileException('فایل CSV پیدا نشد.\nمسیر: $filePath');
      }
      content = file.readAsStringSync();
    } catch (e) {
      if (e is ImportFileException) rethrow;
      throw ImportFileException('خطا در خواندن فایل CSV: $e');
    }

    String cleanedContent = content;
    if (cleanedContent.startsWith('\uFEFF')) {
      cleanedContent = cleanedContent.substring(1);
    }

    final String delimiter = _detectCsvDelimiter(cleanedContent);

    final List<String> lines = cleanedContent
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    if (lines.isEmpty) {
      throw const ImportFileException('فایل CSV خالی است.');
    }
    if (lines.length < 2) {
      throw const ImportFileException(
        'فقط یک سطر در فایل CSV پیدا شد. حداقل یک سطر هدر و یک سطر داده لازم است.',
      );
    }

    final List<String> headers = _parseCsvLine(lines.first, delimiter);
    final Map<String, int> columnMap = _buildColumnMapFromHeaders(headers);

    if (!columnMap.containsKey('barcode')) {
      throw ImportFileException(
        'ستون «بارکد» در فایل CSV پیدا نشد.\n'
        'ستون‌های پیدا شده: ${headers.join("، ")}',
      );
    }

    final int barcodeCol = columnMap['barcode']!;
    final List<PickingItem> items = [];

    for (int i = 1; i < lines.length; i++) {
      try {
        final List<String> cells = _parseCsvLine(lines[i], delimiter);
        if (cells.every((c) => c.trim().isEmpty)) continue;

        if (barcodeCol >= cells.length) continue;
        final String barcode = cells[barcodeCol].trim();
        if (barcode.isEmpty) continue;

        items.add(PickingItem(
          locationWarehouse:
              _readCsvOptionalCell(cells, columnMap, 'location_warehouse') ??
                  '',
          locationHall: _readCsvOptionalCell(cells, columnMap, 'location_hall'),
          color: _readCsvOptionalCell(cells, columnMap, 'color'),
          productCode: _readCsvOptionalCell(cells, columnMap, 'product_code'),
          productName: _readCsvOptionalCell(cells, columnMap, 'product_name'),
          quantity:
              _parseInt(_readCsvOptionalCell(cells, columnMap, 'quantity')) ??
                  1,
          gender: _readCsvOptionalCell(cells, columnMap, 'gender'),
          design: _readCsvOptionalCell(cells, columnMap, 'design'),
          size: _readCsvOptionalCell(cells, columnMap, 'size'),
          barcode: _normalizeDigits(barcode),
          createdAt: DateTime.now(),
        ));
      } catch (_) {}
    }

    if (items.isEmpty) {
      throw const ImportFileException('هیچ آیتم معتبری در فایل CSV پیدا نشد.');
    }

    // مرتب‌سازی بر اساس م.ف.ا
    items.sort((a, b) =>
        a.locationWarehouse.trim().compareTo(b.locationWarehouse.trim()));

    for (int i = 0; i < items.length; i++) {
      items[i] = items[i].copyWith(sortOrder: i);
    }

    return items;
  }

  // ============ WRITING ============

  @override
  Future<String?> writeBarcodesToFile(List<Barcode> barcodes) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Barcodes'];

      sheet.appendRow([
        TextCellValue('barcode'),
        TextCellValue('product_name'),
        TextCellValue('product_code'),
        TextCellValue('category'),
        TextCellValue('size'),
        TextCellValue('color'),
      ]);

      for (final b in barcodes) {
        sheet.appendRow([
          TextCellValue(b.code),
          TextCellValue(b.productName ?? ''),
          TextCellValue(b.productCode ?? ''),
          TextCellValue(b.category ?? ''),
          TextCellValue(b.size ?? ''),
          TextCellValue(b.color ?? ''),
        ]);
      }

      if (excel.sheets.containsKey('Sheet1')) {
        excel.delete('Sheet1');
      }

      final bytes = excel.save();
      if (bytes == null) return null;

      return await _saveFile(bytes, 'barcodes_export.xlsx');
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String?> writeScansToFile(List<ScanRecord> scans) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Scans'];

      sheet.appendRow([
        TextCellValue('id'),
        TextCellValue('user_id'),
        TextCellValue('barcode'),
        TextCellValue('status'),
        TextCellValue('date'),
        TextCellValue('time'),
      ]);

      for (final s in scans) {
        sheet.appendRow([
          IntCellValue(s.id ?? 0),
          IntCellValue(s.userId),
          TextCellValue(s.barcode),
          TextCellValue(s.status.label),
          TextCellValue(s.dateOnly),
          TextCellValue(s.timeOnly),
        ]);
      }

      if (excel.sheets.containsKey('Sheet1')) {
        excel.delete('Sheet1');
      }

      final bytes = excel.save();
      if (bytes == null) return null;

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      return await _saveFile(bytes, 'scans_export_$timestamp.xlsx');
    } catch (e) {
      return null;
    }
  }

  /// نوشتن گزارش نشست برداشت به فایل Excel
  Future<String?> writePickingSessionToFile({
    required String sessionName,
    required List<PickingItem> items,
  }) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['PickingReport'];

      // Headers
      sheet.appendRow([
        TextCellValue('ردیف'),
        TextCellValue('م.ف.ا'),
        TextCellValue('م.ف.سالن'),
        TextCellValue('کد محصول'),
        TextCellValue('عنوان محصول'),
        TextCellValue('رنگ'),
        TextCellValue('سایز'),
        TextCellValue('طرح'),
        TextCellValue('جنسیت'),
        TextCellValue('تعداد'),
        TextCellValue('بارکد'),
        TextCellValue('وضعیت'),
        TextCellValue('بارکد اسکن شده'),
        TextCellValue('زمان برداشت'),
      ]);

      int rowIdx = 1;
      for (final item in items) {
        sheet.appendRow([
          IntCellValue(rowIdx++),
          TextCellValue(item.locationWarehouse),
          TextCellValue(item.locationHall ?? ''),
          TextCellValue(item.productCode ?? ''),
          TextCellValue(item.productName ?? ''),
          TextCellValue(item.color ?? ''),
          TextCellValue(item.size ?? ''),
          TextCellValue(item.design ?? ''),
          TextCellValue(item.gender ?? ''),
          IntCellValue(item.quantity),
          TextCellValue(item.barcode),
          TextCellValue(item.status.label),
          TextCellValue(item.scannedBarcode ?? ''),
          TextCellValue(item.pickedAt != null
              ? '${item.pickedAt!.hour.toString().padLeft(2, '0')}:'
                  '${item.pickedAt!.minute.toString().padLeft(2, '0')}:'
                  '${item.pickedAt!.second.toString().padLeft(2, '0')}'
              : ''),
        ]);
      }

      if (excel.sheets.containsKey('Sheet1')) {
        excel.delete('Sheet1');
      }

      final bytes = excel.save();
      if (bytes == null) return null;

      // نام فایل با timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final safeName = sessionName.replaceAll(RegExp(r'[^\w\u0600-\u06FF]'), '_');
      return await _saveFile(bytes, 'picking_${safeName}_$timestamp.xlsx');
    } catch (e) {
      return null;
    }
  }

  Future<String> _saveFile(List<int> bytes, String fileName) async {
    final dir = await getTemporaryDirectory();
    final file = File(p.join(dir.path, fileName));
    await file.writeAsBytes(bytes);
    return file.path;
  }

  // ============ HEADER PARSING — هدرهای فارسی و انگلیسی ============

  /// نقشه نام ستون‌های ممکن به کلید استاندارد
  static const Map<String, List<String>> _columnAliases = {
    'barcode': [
      'barcode', 'barcodes', 'code', 'کد', 'بارکد', 'کد بارکد', 'کدبارکد',
      'شماره بارکد', 'بارکد محصول', 'ean', 'ean13', 'ean-13', 'upc', 'qr', 'qrcode',
    ],
    'location_warehouse': [
      'م.ف.ا', 'م.ف.ا.', 'م ف ا', 'مکان_فیزیکی_انبار', 'مکان فیزیکی انبار',
      'مکان فیزیکی', 'location_warehouse', 'location', 'warehouse', 'loc',
      'مکان', 'فیزیکی', 'قفسه', 'رف', 'بایگانی',
    ],
    'location_hall': [
      'م.ف.سالن', 'م.ف.سالن.', 'م ف سالن', 'مکان_سالن', 'مکان سالن',
      'سالن', 'location_hall', 'hall', 'zone',
    ],
    'color': [
      'color', 'colors', 'colour', 'رنگ', 'رنگ‌بندی', 'رنگ بندی',
    ],
    'product_code': [
      'product_code', 'productcode', 'product code', 'sku', 'item_code',
      'کد محصول', 'کدمحصول', 'کد کالا', 'کدکالا', 'کد', 'شناسه محصول', 'شناسه',
    ],
    'product_name': [
      'product_name', 'productname', 'product name', 'name', 'title', 'product',
      'نام محصول', 'نام', 'نام کالا', 'شرح', 'شرح محصول', 'عنوان', 'عنوان محصول', 'کالا',
    ],
    'quantity': [
      'quantity', 'qty', 'count', 'amount', 'تعداد', 'تعداد مورد نیاز',
      'مقدار', 'شماره',
    ],
    'gender': [
      'gender', 'جنسیت', 'جنسیت محصول', 'جنسی',
    ],
    'design': [
      'design', 'pattern', 'model', 'طرح', 'مدل', 'طرح محصول',
    ],
    'size': [
      'size', 'sizes', 'measurement', 'سایز', 'اندازه', 'قد', 'سایزینگ',
    ],
  };

  /// تشخیص کلید استاندارد از نام هدر
  String? _normalizeHeader(String? header) {
    if (header == null || header.isEmpty) return null;

    // نرمال‌سازی
    final String normalized = header
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[\u200c\u200d]'), '') // ZWNJ, ZWJ
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'[\u064b-\u0652]'), ''); // اعراب

    if (normalized.isEmpty) return null;

    for (final entry in _columnAliases.entries) {
      final String key = entry.key;
      final List<String> aliases = entry.value;

      // تطابق دقیق
      if (aliases.contains(normalized)) {
        return key;
      }

      // تطابق با حذف فاصله
      final String noSpaceNormalized = normalized.replaceAll(' ', '');
      for (final alias in aliases) {
        final String noSpaceAlias = alias.toLowerCase().replaceAll(' ', '');
        if (noSpaceNormalized == noSpaceAlias) {
          return key;
        }
      }

      // تطابق با حذف نقطه (برای م.ف.ا → مفا)
      final String noDotNormalized = normalized.replaceAll('.', '');
      for (final alias in aliases) {
        final String noDotAlias = alias.toLowerCase().replaceAll('.', '');
        if (noDotNormalized == noDotAlias) {
          return key;
        }
      }
    }

    return null;
  }

  Map<String, int> _buildColumnMapFromHeaders(List<String> headers) {
    final Map<String, int> map = <String, int>{};

    for (int i = 0; i < headers.length; i++) {
      final String? key = _normalizeHeader(headers[i]);
      if (key != null && !map.containsKey(key)) {
        map[key] = i;
      }
    }

    return map;
  }

  // ============ HEADER ROW FINDING ============

  _HeaderResult? _findHeaderRow(Sheet table) {
    final int rowCount = table.rows.length;
    if (rowCount == 0) return null;

    final int maxRowsToCheck = rowCount < 10 ? rowCount : 10;

    for (int i = 0; i < maxRowsToCheck; i++) {
      final List<Data?> row = table.rows[i];

      if (_isRowEmpty(row)) continue;

      // ساخت لیست هدرها
      final List<String> headers = <String>[];
      for (final cell in row) {
        final value = cell?.value;
        headers.add(value?.toString() ?? '');
      }

      final Map<String, int> columnMap = _buildColumnMapFromHeaders(headers);

      if (columnMap.containsKey('barcode')) {
        return _HeaderResult(i, columnMap);
      }
    }

    return null;
  }

  List<String> _collectAllHeaderCandidates(Sheet table) {
    final Set<String> candidates = <String>{};
    final int rowCount = table.rows.length;
    final int maxRowsToCheck = rowCount < 3 ? rowCount : 3;

    for (int i = 0; i < maxRowsToCheck; i++) {
      final List<Data?> row = table.rows[i];
      for (final cell in row) {
        final v = cell?.value;
        if (v != null) {
          final s = v.toString().trim();
          if (s.isNotEmpty) {
            candidates.add(s);
          }
        }
      }
    }

    return candidates.take(20).toList();
  }

  // ============ UTILITIES ============

  String? _findFirstNonEmptySheet(Excel excel) {
    if (excel.tables.isEmpty) return null;

    const List<String> preferredNames = [
      'Barcodes', 'barcodes', 'Sheet1', 'صفحه۱', 'Data', 'data', 'Picking',
    ];

    for (final name in preferredNames) {
      final Sheet? table = excel.tables[name];
      if (table == null) continue;
      if (table.rows.isNotEmpty && !_isTableEmpty(table)) {
        return name;
      }
    }

    for (final entry in excel.tables.entries) {
      final Sheet table = entry.value;
      if (table.rows.isNotEmpty && !_isTableEmpty(table)) {
        return entry.key;
      }
    }

    if (excel.tables.keys.isNotEmpty) {
      return excel.tables.keys.first;
    }
    return null;
  }

  bool _isTableEmpty(Sheet table) {
    for (final row in table.rows) {
      if (!_isRowEmpty(row)) {
        return false;
      }
    }
    return true;
  }

  bool _isRowEmpty(List<Data?> row) {
    if (row.isEmpty) return true;
    for (final cell in row) {
      final v = cell?.value;
      if (v != null) {
        final s = v.toString().trim();
        if (s.isNotEmpty) {
          return false;
        }
      }
    }
    return true;
  }

  String? _safeReadCell(List<Data?> row, int colIndex) {
    if (colIndex < 0 || colIndex >= row.length) return null;

    final Data? cell = row[colIndex];
    if (cell == null) return null;

    final value = cell.value;
    if (value == null) return null;

    final String s = value.toString().trim();
    return s.isEmpty ? null : s;
  }

  String? _readOptionalCell(
    List<Data?> row,
    Map<String, int> columnMap,
    String key,
  ) {
    final int? col = columnMap[key];
    if (col == null) return null;
    final String? value = _safeReadCell(row, col);
    return (value == null || value.isEmpty) ? null : value;
  }

  String? _readCsvOptionalCell(
    List<String> cells,
    Map<String, int> columnMap,
    String key,
  ) {
    final int? col = columnMap[key];
    if (col == null) return null;
    if (col < 0 || col >= cells.length) return null;
    final String value = cells[col].trim();
    return value.isEmpty ? null : value;
  }

  /// پارس عدد صحیح از رشته (با پشتیبانی از اعداد فارسی/عربی)
  int? _parseInt(String? value) {
    if (value == null || value.isEmpty) return null;
    final normalized = _normalizeDigits(value.trim());
    // حذف کاراکترهای غیر عددی
    final digitsOnly = normalized.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.isEmpty) return null;
    return int.tryParse(digitsOnly);
  }

  /// نرمال‌سازی اعداد فارسی/عربی به انگلیسی
  String _normalizeDigits(String input) {
    const List<String> persianDigits = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    const List<String> arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    String result = input;
    for (int i = 0; i < 10; i++) {
      result = result.replaceAll(persianDigits[i], i.toString());
      result = result.replaceAll(arabicDigits[i], i.toString());
    }
    return result;
  }

  // ============ CSV UTILITIES ============

  String _detectCsvDelimiter(String content) {
    final int firstNewline = content.indexOf('\n');
    final String firstLine =
        firstNewline == -1 ? content : content.substring(0, firstNewline);

    final int commaCount = ','.allMatches(firstLine).length;
    final int semicolonCount = ';'.allMatches(firstLine).length;
    final int tabCount = '\t'.allMatches(firstLine).length;

    if (semicolonCount > commaCount && semicolonCount > tabCount) {
      return ';';
    }
    if (tabCount > commaCount && tabCount > semicolonCount) {
      return '\t';
    }
    return ',';
  }

  List<String> _parseCsvLine(String line, [String delimiter = ',']) {
    final List<String> result = <String>[];
    final StringBuffer current = StringBuffer();
    bool inQuotes = false;

    for (int i = 0; i < line.length; i++) {
      final String char = line[i];

      if (char == '"') {
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          current.write('"');
          i++;
        } else {
          inQuotes = !inQuotes;
        }
      } else if (char == delimiter && !inQuotes) {
        result.add(current.toString().trim());
        current.clear();
      } else {
        current.write(char);
      }
    }
    result.add(current.toString().trim());
    return result;
  }
}

/// نتیجه پیدا کردن سطر هدر
class _HeaderResult {
  final int rowIndex;
  final Map<String, int> columnMap;

  _HeaderResult(this.rowIndex, this.columnMap);
}
