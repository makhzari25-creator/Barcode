import 'package:flutter_test/flutter_test.dart';
import 'package:barcode_warehouse/features/barcode/data/datasources/bloom_filter.dart';

void main() {
  group('BloomFilter Tests', () {
    test('should return false for non-added elements', () {
      final bf = BloomFilter();
      expect(bf.contains('not_added'), false);
    });

    test('should return true for added elements', () {
      final bf = BloomFilter();
      bf.add('test_barcode_123');
      expect(bf.contains('test_barcode_123'), true);
    });

    test('should handle multiple additions', () {
      final bf = BloomFilter();
      final codes = ['code1', 'code2', 'code3', 'code4', 'code5'];
      bf.addAll(codes);

      for (final code in codes) {
        expect(bf.contains(code), true);
      }
    });

    test('should clear correctly', () {
      final bf = BloomFilter();
      bf.add('test');
      expect(bf.contains('test'), true);
      bf.clear();
      expect(bf.contains('test'), false);
    });

    test('should persist to bytes and restore', () {
      final bf1 = BloomFilter();
      bf1.add('barcode_xyz');
      bf1.add('barcode_abc');

      final bytes = bf1.toBytes();
      final bf2 = BloomFilter.fromBytes(bytes);

      expect(bf2.contains('barcode_xyz'), true);
      expect(bf2.contains('barcode_abc'), true);
    });

    test('should handle 1000 barcodes with low false positive rate', () {
      final bf = BloomFilter();
      final addedCodes = List.generate(1000, (i) => 'code_$i');
      bf.addAll(addedCodes);

      int truePositives = 0;
      for (final code in addedCodes) {
        if (bf.contains(code)) truePositives++;
      }
      expect(truePositives, 1000);

      int falsePositives = 0;
      for (int i = 1000; i < 2000; i++) {
        if (bf.contains('code_$i')) falsePositives++;
      }
      expect(falsePositives / 1000 < 0.05, true,
          reason: 'False positive rate too high: ${falsePositives / 10}%');
    });

    test('should handle EAN-13 style barcodes', () {
      final bf = BloomFilter();
      final ean13Barcodes = [
        '6289345678901',
        '6289345678902',
        '6289345678903',
        '4006381333931',
      ];
      bf.addAll(ean13Barcodes);

      for (final b in ean13Barcodes) {
        expect(bf.contains(b), true);
      }
      expect(bf.contains('6289345678999'), false);
    });
  });

  group('BloomFilter Performance Tests', () {
    test('should add and check 100k barcodes in reasonable time', () {
      final bf = BloomFilter();
      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 100000; i++) {
        bf.add('barcode_$i');
      }
      stopwatch.stop();

      stopwatch.reset();
      stopwatch.start();
      for (int i = 0; i < 1000; i++) {
        bf.contains('barcode_${i * 100}');
      }
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds < 100, true);
    });
  });
}
