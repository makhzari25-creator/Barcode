import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';

String _esc(String s) =>
    s.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;');

String _colLetter(int i) => String.fromCharCode(65 + i);

/// ساخت یک فایل xlsx کوچک در حافظه برای تست.
/// مقدارهای String به‌صورت inlineStr (یا sharedStrings اگر [shared] باشد)
/// و مقدارهای عددی به‌صورت سلول عددی نوشته می‌شوند.
List<int> buildXlsx(List<List<Object?>> rows, {bool shared = false}) {
  final sharedStrings = <String>[];
  final sheet = StringBuffer(
      '<?xml version="1.0" encoding="UTF-8"?>'
      '<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">'
      '<sheetData>');
  for (var r = 0; r < rows.length; r++) {
    sheet.write('<row r="${r + 1}">');
    for (var c = 0; c < rows[r].length; c++) {
      final v = rows[r][c];
      if (v == null) continue;
      final ref = '${_colLetter(c)}${r + 1}';
      if (v is num) {
        sheet.write('<c r="$ref"><v>$v</v></c>');
      } else if (shared) {
        var idx = sharedStrings.indexOf(v as String);
        if (idx == -1) {
          sharedStrings.add(v);
          idx = sharedStrings.length - 1;
        }
        sheet.write('<c r="$ref" t="s"><v>$idx</v></c>');
      } else {
        sheet.write(
            '<c r="$ref" t="inlineStr"><is><t>${_esc(v as String)}</t></is></c>');
      }
    }
    sheet.write('</row>');
  }
  sheet.write('</sheetData></worksheet>');

  final archive = Archive();
  void add(String name, String content) {
    final data = utf8.encode(content);
    archive.addFile(ArchiveFile(name, data.length, data));
  }

  add(
    'xl/workbook.xml',
    '<?xml version="1.0" encoding="UTF-8"?>'
    '<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" '
    'xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">'
    '<sheets><sheet name="Sheet1" sheetId="1" r:id="rId1"/></sheets></workbook>',
  );
  add(
    'xl/_rels/workbook.xml.rels',
    '<?xml version="1.0" encoding="UTF-8"?>'
    '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
    '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/>'
    '</Relationships>',
  );
  add('xl/worksheets/sheet1.xml', sheet.toString());
  if (shared) {
    final sst = StringBuffer(
        '<?xml version="1.0" encoding="UTF-8"?>'
        '<sst xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">');
    for (final s in sharedStrings) {
      sst.write('<si><t>${_esc(s)}</t></si>');
    }
    sst.write('</sst>');
    add('xl/sharedStrings.xml', sst.toString());
  }

  final encoded = ZipEncoder().encode(archive);
  return encoded as List<int>;
}

/// نوشتن یک xlsx تستی در پوشه‌ی موقت و برگرداندن مسیر آن
Future<String> writeXlsx(
  Directory dir,
  String name,
  List<List<Object?>> rows, {
  bool shared = false,
}) async {
  final file = File('${dir.path}/$name');
  await file.writeAsBytes(buildXlsx(rows, shared: shared));
  return file.path;
}

/// جدول نمونه‌ی استاندارد: کد، عنوان، تعداد
const sampleRows = <List<Object?>>[
  ['کد محصول', 'عنوان محصول', 'تعداد'],
  ['6291234567890', 'بسته شکلات', 4],
  ['6291234567891', 'بطری آب معدنی', 2],
  ['0123456789012', 'کالای با صفر ابتدایی', 1],
];
