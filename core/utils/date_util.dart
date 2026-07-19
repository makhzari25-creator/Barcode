import 'package:shamsi_date/shamsi_date.dart';

/// ابزار کار با تاریخ شمسی
class DateUtil {
  DateUtil._();

  /// تبدیل میلادی به شمسی
  static Jalali toJalali(DateTime gregorian) {
    return Jalali(gregorian.year, gregorian.month, gregorian.day);
  }

  /// تبدیل شمسی به میلادی
  static DateTime toGregorian(Jalali jalali) {
    return jalali.toDateTime();
  }

  /// تاریخ فعلی شمسی
  static Jalali now() {
    return Jalali.now();
  }

  /// فرمت کوتاه: ۱۴۰۵/۰۴/۲۵
  static String formatShort(DateTime gregorian) {
    final jalali = toJalali(gregorian);
    return '${_toPersian(jalali.year)}/${_pad(jalali.month)}/${_pad(jalali.day)}';
  }

  /// فرمت کامل: ۲۵ تیر ۱۴۰۵
  static String formatFull(DateTime gregorian) {
    final jalali = toJalali(gregorian);
    return '${_toPersian(jalali.day)} ${_monthName(jalali.month)} ${_toPersian(jalali.year)}';
  }

  /// فرمت با زمان: ۱۴۰۵/۰۴/۲۵ - ۱۰:۳۲:۰۵
  static String formatWithTime(DateTime gregorian) {
    final date = formatShort(gregorian);
    final time = formatTime(gregorian);
    return '$date - $time';
  }

  /// فقط زمان: ۱۰:۳۲:۰۵
  static String formatTime(DateTime gregorian) {
    return '${_pad(gregorian.hour)}:${_pad(gregorian.minute)}:${_pad(gregorian.second)}';
  }

  /// فقط ساعت:دقیقه: ۱۰:۳۲
  static String formatHourMinute(DateTime gregorian) {
    return '${_pad(gregorian.hour)}:${_pad(gregorian.minute)}';
  }

  /// فقط تاریخ (YYYY-MM-DD) برای ذخیره در دیتابیس
  static String dateOnly(DateTime gregorian) {
    final jalali = toJalali(gregorian);
    return '${jalali.year.toString().padLeft(4, '0')}-${_pad(jalali.month)}-${_pad(jalali.day)}';
  }

  /// فقط زمان (HH:MM:SS) برای ذخیره
  static String timeOnly(DateTime gregorian) {
    return '${_pad(gregorian.hour)}:${_pad(gregorian.minute)}:${_pad(gregorian.second)}';
  }

  /// تاریخ ISO 8601 میلادی
  static String toIso8601(DateTime gregorian) {
    return gregorian.toIso8601String();
  }

  /// پارس از ISO 8601
  static DateTime fromIso8601(String iso) {
    return DateTime.parse(iso);
  }

  /// نام ماه شمسی
  static String _monthName(int month) {
    const names = [
      'فروردین', 'اردیبهشت', 'خرداد', 'تیر', 'مرداد', 'شهریور',
      'مهر', 'آبان', 'آذر', 'دی', 'بهمن', 'اسفند'
    ];
    if (month < 1 || month > 12) return '';
    return names[month - 1];
  }

  /// پد کردن عدد با صفر
  static String _pad(int n) => n.toString().padLeft(2, '0');

  /// تبدیل اعداد انگلیسی به فارسی
  static String _toPersian(int n) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const persian = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    String s = n.toString();
    for (int i = 0; i < english.length; i++) {
      s = s.replaceAll(english[i], persian[i]);
    }
    return s;
  }

  /// تبدیل رشته اعداد به فارسی
  static String toPersianDigits(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const persian = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    String s = input;
    for (int i = 0; i < english.length; i++) {
      s = s.replaceAll(english[i], persian[i]);
    }
    return s;
  }

  /// تبدیل اعداد فارسی به انگلیسی
  static String toEnglishDigits(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const persian = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    String s = input;
    for (int i = 0; i < english.length; i++) {
      s = s.replaceAll(persian[i], english[i]);
      s = s.replaceAll(arabic[i], english[i]);
    }
    return s;
  }
}
