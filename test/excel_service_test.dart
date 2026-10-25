import 'dart:io';
import 'package:check_hall_charge/services/excel_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'test_helpers.dart';

void main() {
  late Directory dir;
  final service = ExcelService();

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('excel_test_');
  });

  tearDown(() async {
    if (await dir.exists()) await dir.delete(recursive: true);
  });

  test('ستون‌ها از روی نام خوانده می‌شوند', () async {
    final path = await writeXlsx(dir, 'a.xlsx', sampleRows);
    final products = await service.readProducts(path);
    expect(products.length, 3);
    expect(products.first.code, '6291234567890');
    expect(products.first.title, 'بسته شکلات');
    expect(products.first.requiredCount, 4);
    expect(products.first.imageUrl, '');
  });

  test('فایل با sharedStrings خوانده می‌شود', () async {
    final path = await writeXlsx(dir, 'b.xlsx', sampleRows, shared: true);
    final products = await service.readProducts(path);
    expect(products.length, 3);
    expect(products[1].title, 'بطری آب معدنی');
    expect(products[1].requiredCount, 2);
  });

  test('ردیف هدر می‌تواند پایین‌تر از ردیف اول باشد', () async {
    final path = await writeXlsx(dir, 'c.xlsx', [
      ['گزارش شارژ سالن'],
      [],
      ['کد محصول', 'عنوان محصول', 'تعداد'],
      ['111', 'کالای الف', 3],
    ]);
    final products = await service.readProducts(path);
    expect(products.length, 1);
    expect(products.single.code, '111');
  });

  test('ستون عکس اختیاری خوانده می‌شود', () async {
    final path = await writeXlsx(dir, 'd.xlsx', [
      ['کد محصول', 'عنوان محصول', 'تعداد', 'عکس'],
      ['111', 'کالای الف', 2, 'https://example.com/a.jpg'],
      ['222', 'کالای ب', 1],
    ]);
    final products = await service.readProducts(path);
    expect(products[0].imageUrl, 'https://example.com/a.jpg');
    expect(products[1].imageUrl, '');
  });

  test('تعداد خالی، صفر یا نامعتبر یعنی یک عدد', () async {
    final path = await writeXlsx(dir, 'e.xlsx', [
      ['کد محصول', 'عنوان محصول', 'تعداد'],
      ['1', 'الف'],
      ['2', 'ب', 0],
      ['3', 'ج', 'abc'],
      ['4', 'د', '۵'],
    ]);
    final products = await service.readProducts(path);
    expect(products.map((p) => p.requiredCount).toList(), [1, 1, 1, 5]);
  });

  test('فایل بدون ستون تعداد هم خوانده می‌شود', () async {
    final path = await writeXlsx(dir, 'f.xlsx', [
      ['کد محصول', 'عنوان محصول'],
      ['1', 'الف'],
    ]);
    final products = await service.readProducts(path);
    expect(products.single.requiredCount, 1);
  });

  test('کدهای تکراری ادغام و تعدادها جمع می‌شود', () async {
    final path = await writeXlsx(dir, 'g.xlsx', [
      ['کد محصول', 'عنوان محصول', 'تعداد'],
      ['1', 'الف', 2],
      ['2', 'ب', 1],
      ['1', 'الف دوباره', 3],
    ]);
    final products = await service.readProducts(path);
    expect(products.length, 2);
    final first = products.firstWhere((p) => p.code == '1');
    expect(first.requiredCount, 5);
    expect(first.title, 'الف');
  });

  test('کد عددی و نماد علمی اکسل نرمال می‌شود', () async {
    final path = await writeXlsx(dir, 'h.xlsx', [
      ['کد محصول', 'عنوان محصول', 'تعداد'],
      [6291234567890, 'عددی', 1],
      ['6.29123456789E12', 'علمی', 1],
      ['۶۲۹۱۲۳۴۵۶۷۸۹۱', 'فارسی', 1],
    ]);
    final products = await service.readProducts(path);
    expect(products[0].code, '6291234567890');
    // دو ردیف اول کد یکسان دارند و ادغام می‌شوند
    expect(products.firstWhere((p) => p.code == '6291234567890').requiredCount,
        2);
    expect(products.any((p) => p.code == '6291234567891'), isTrue);
  });

  test('ردیف بدون کد نادیده گرفته می‌شود', () async {
    final path = await writeXlsx(dir, 'i.xlsx', [
      ['کد محصول', 'عنوان محصول', 'تعداد'],
      ['', 'بدون کد', 1],
      ['5', 'با کد', 1],
    ]);
    final products = await service.readProducts(path);
    expect(products.single.code, '5');
  });

  test('نبودن ستون‌های لازم خطای فارسی می‌دهد', () async {
    final path = await writeXlsx(dir, 'j.xlsx', [
      ['نام', 'قیمت'],
      ['الف', 10],
    ]);
    expect(service.readProducts(path), throwsA(isA<ExcelException>()));
  });

  test('فرمت xls رد می‌شود', () async {
    final file = File('${dir.path}/old.xls');
    await file.writeAsBytes([1, 2, 3]);
    expect(service.readProducts(file.path), throwsA(isA<ExcelException>()));
  });

  test('فایل خراب خطای کنترل‌شده می‌دهد', () async {
    final file = File('${dir.path}/bad.xlsx');
    await file.writeAsBytes([1, 2, 3, 4]);
    expect(service.readProducts(file.path), throwsA(isA<ExcelException>()));
  });
}
