import 'package:check_hall_charge/utils/barcode_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('normalizeCode', () {
    test('ارقام فارسی و عربی به انگلیسی تبدیل می‌شوند', () {
      expect(normalizeCode('۶۲۹۱۲۳۴۵۶۷۸۹۰'), '6291234567890');
      expect(normalizeCode('٦٢٩١٢٣٤٥٦٧٨٩٠'), '6291234567890');
    });

    test('فاصله و کاراکترهای نامرئی حذف می‌شوند', () {
      expect(normalizeCode(' 6291 2345‌67890 \n'), '6291234567890');
    });

    test('نماد علمی اکسل به عدد کامل تبدیل می‌شود', () {
      expect(normalizeCode('6.29123456789E12'), '6291234567890');
      expect(normalizeCode('6.29123456789E+12'), '6291234567890');
    });

    test('نقطه‌صفر انتهایی حذف می‌شود', () {
      expect(normalizeCode('6291234567890.0'), '6291234567890');
    });

    test('کد متنی دست‌نخورده می‌ماند', () {
      expect(normalizeCode('AB-123'), 'AB-123');
    });
  });

  test('codeLooseKey صفرهای ابتدایی را نادیده می‌گیرد', () {
    expect(codeLooseKey('0123456789012'), codeLooseKey('123456789012'));
    expect(codeLooseKey('000'), '0');
    expect(codeLooseKey('AB-0'), 'AB-0');
  });

  test('toFaDigits فقط ارقام را عوض می‌کند', () {
    expect(toFaDigits(128), '۱۲۸');
    expect(toFaDigits('3/6'), '۳/۶');
  });
}
