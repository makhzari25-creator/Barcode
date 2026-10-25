/// ابزارهای کمکی برای نرمال‌سازی کد بارکد و نمایش اعداد فارسی

const _faDigits = '۰۱۲۳۴۵۶۷۸۹';
const _arDigits = '٠١٢٣٤٥٦٧٨٩';

/// تبدیل ارقام فارسی و عربی به ارقام انگلیسی
String toEnDigits(String input) {
  final buffer = StringBuffer();
  for (final rune in input.runes) {
    final ch = String.fromCharCode(rune);
    final faIdx = _faDigits.indexOf(ch);
    if (faIdx != -1) {
      buffer.write(faIdx);
      continue;
    }
    final arIdx = _arDigits.indexOf(ch);
    if (arIdx != -1) {
      buffer.write(arIdx);
      continue;
    }
    buffer.write(ch);
  }
  return buffer.toString();
}

/// تبدیل عدد یا متن به ارقام فارسی برای نمایش
String toFaDigits(Object value) {
  final s = value.toString();
  final buffer = StringBuffer();
  for (final rune in s.runes) {
    final ch = String.fromCharCode(rune);
    final idx = '0123456789'.indexOf(ch);
    buffer.write(idx == -1 ? ch : _faDigits[idx]);
  }
  return buffer.toString();
}

final _sciPattern = RegExp(r'^[0-9]+(\.[0-9]+)?[eE]\+?[0-9]+$');
final _trailingZeroPattern = RegExp(r'^[0-9]+\.0+$');
final _invisiblePattern = RegExp(r'[\s‌‍‎‏ ]');

/// نرمال‌سازی کد بارکد:
/// - حذف فاصله و کاراکترهای نامرئی
/// - تبدیل ارقام فارسی/عربی به انگلیسی
/// - تبدیل نماد علمی اکسل (مثل 6.29123456789E+12) به عدد کامل
/// - حذف ".0" انتهایی
String normalizeCode(String raw) {
  var s = toEnDigits(raw).replaceAll(_invisiblePattern, '');
  if (_sciPattern.hasMatch(s)) {
    final d = double.tryParse(s);
    if (d != null && d.abs() < 1e15) {
      s = d.round().toString();
    }
  }
  if (_trailingZeroPattern.hasMatch(s)) {
    s = s.split('.').first;
  }
  return s;
}

/// کلید جایگزین برای تطبیق کدهایی که اکسل صفرهای ابتدایی آن‌ها را حذف کرده
/// (مثل UPC-A در برابر EAN-13)
String codeLooseKey(String normalized) {
  if (!RegExp(r'^[0-9]+$').hasMatch(normalized)) return normalized;
  final stripped = normalized.replaceFirst(RegExp(r'^0+'), '');
  return stripped.isEmpty ? '0' : stripped;
}
