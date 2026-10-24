import 'dart:io';
import 'package:check_hall_charge/services/app_state.dart';
import 'package:check_hall_charge/services/hall_charge_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory dir;
  late String path;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    dir = await Directory.systemTemp.createTemp('state_test_');
    path = await writeXlsx(dir, 'list.xlsx', sampleRows);
  });

  tearDown(() async {
    if (await dir.exists()) await dir.delete(recursive: true);
  });

  group('AppState (چک کردن شارژ)', () {
    test('اسکن تا تکمیل و سپس alreadyComplete', () async {
      final state = AppState();
      expect(await state.loadExcelFile(path, fileName: 'list.xlsx'), isTrue);
      expect(state.products.length, 3);

      expect(await state.recordScan('6291234567891'), ScanResult.scanned);
      expect(state.scannedCountFor('6291234567891'), 1);
      expect(await state.recordScan('6291234567891'), ScanResult.justCompleted);
      expect(await state.recordScan('6291234567891'), ScanResult.alreadyComplete);
      expect(state.scannedCountFor('6291234567891'), 2);
      expect(state.completedCount, 1);
    });

    test('کد ناشناخته notFound است و شمارنده تغییر نمی‌کند', () async {
      final state = AppState();
      await state.loadExcelFile(path);
      expect(await state.recordScan('999'), ScanResult.notFound);
      expect(state.scanCounts, isEmpty);
    });

    test('کد فارسی و کد بدون صفر ابتدایی تطبیق می‌خورد', () async {
      final state = AppState();
      await state.loadExcelFile(path);
      expect(await state.recordScan('۶۲۹۱۲۳۴۵۶۷۸۹۰'), ScanResult.scanned);
      // اکسل صفر ابتدایی را حفظ کرده؛ دوربین نسخه‌ی بدون صفر را می‌خواند
      expect(await state.recordScan('123456789012'), ScanResult.justCompleted);
      expect(state.scannedCountFor('0123456789012'), 1);
    });

    test('پیشرفت و تکمیل کل لیست', () async {
      final state = AppState();
      await state.loadExcelFile(path);
      expect(state.progress, 0);
      expect(state.isFullyComplete, isFalse);

      for (var i = 0; i < 4; i++) {
        await state.recordScan('6291234567890');
      }
      for (var i = 0; i < 2; i++) {
        await state.recordScan('6291234567891');
      }
      await state.recordScan('0123456789012');

      expect(state.completedCount, 3);
      expect(state.progress, 1);
      expect(state.isFullyComplete, isTrue);
    });

    test('جایگزینی فایل: فقط اگر اسکن بوده بایگانی می‌شود', () async {
      final state = AppState();
      await state.loadExcelFile(path, fileName: 'اول.xlsx');
      final path2 = await writeXlsx(dir, 'second.xlsx', [
        ['کد محصول', 'عنوان محصول', 'تعداد'],
        ['777', 'کالای جدید', 2],
      ]);

      // بدون اسکن: بایگانی نمی‌شود
      await state.loadExcelFile(path2, fileName: 'دوم.xlsx');
      expect(state.archives, isEmpty);

      // با اسکن: بایگانی می‌شود و فایل جدید از صفر شروع می‌شود
      await state.recordScan('777');
      await state.loadExcelFile(path, fileName: 'سوم.xlsx');
      expect(state.archives.length, 1);
      expect(state.archives.first.fileName, 'دوم.xlsx');
      expect(state.archives.first.scannedCountFor('777'), 1);
      expect(state.scanCounts, isEmpty);
      expect(state.excelFileName, 'سوم.xlsx');
    });

    test('فایل نامعتبر داده‌ی فعلی را خراب نمی‌کند', () async {
      final state = AppState();
      await state.loadExcelFile(path, fileName: 'خوب.xlsx');
      await state.recordScan('6291234567890');

      final bad = File('${dir.path}/bad.xlsx')..writeAsBytesSync([1, 2, 3]);
      expect(await state.loadExcelFile(bad.path), isFalse);
      expect(state.error, isNotNull);
      expect(state.products.length, 3);
      expect(state.scannedCountFor('6291234567890'), 1);
      expect(state.archives, isEmpty);
    });

    test('داده‌ها پس از راه‌اندازی دوباره حفظ می‌شود', () async {
      final first = AppState();
      await first.loadExcelFile(path, fileName: 'list.xlsx');
      await first.recordScan('6291234567890');

      final second = AppState();
      await second.initialize();
      expect(second.products.length, 3);
      expect(second.excelFileName, 'list.xlsx');
      expect(second.scannedCountFor('6291234567890'), 1);
    });

    test('ریست شمارنده‌ها لیست را نگه می‌دارد', () async {
      final state = AppState();
      await state.loadExcelFile(path);
      await state.recordScan('6291234567890');
      await state.resetCounters();
      expect(state.scanCounts, isEmpty);
      expect(state.products.length, 3);
    });
  });

  group('HallChargeState (شارژ سالن)', () {
    test('تایید یک‌باره هر کالا', () async {
      final state = HallChargeState();
      await state.loadExcelFile(path, fileName: 'hall.xlsx');
      expect(await state.recordScan('6291234567890'), HallScanResult.confirmed);
      expect(await state.recordScan('6291234567890'),
          HallScanResult.alreadyConfirmed);
      expect(await state.recordScan('000'), HallScanResult.notFound);
      expect(state.confirmedCount, 1);
      expect(state.isConfirmed('6291234567890'), isTrue);
    });

    test('تکمیل وقتی همه کالاها تایید شدند', () async {
      final state = HallChargeState();
      await state.loadExcelFile(path);
      await state.recordScan('6291234567890');
      await state.recordScan('6291234567891');
      expect(state.isFullyComplete, isFalse);
      await state.recordScan('123456789012');
      expect(state.isFullyComplete, isTrue);
      expect(state.progress, 1);
    });

    test('جایگزینی فایل تاییدهای قبلی را بایگانی می‌کند', () async {
      final state = HallChargeState();
      await state.loadExcelFile(path, fileName: 'اول.xlsx');
      await state.recordScan('6291234567890');

      await state.loadExcelFile(path, fileName: 'دوم.xlsx');
      expect(state.archives.length, 1);
      expect(state.archives.first.fileName, 'اول.xlsx');
      expect(state.archives.first.totalScanned, 1);
      expect(state.archives.first.totalRequired, 3);
      expect(state.confirmedCount, 0);

      // بایگانی پس از راه‌اندازی دوباره هم می‌ماند
      final again = HallChargeState();
      await again.initialize();
      expect(again.archives.length, 1);
    });
  });
}
