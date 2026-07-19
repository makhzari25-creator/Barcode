import 'package:persian_number_utility/persian_number_utility.dart';

/// اعتبارسنجی ورودی‌ها
class Validators {
  Validators._();

  /// اعتبارسنجی نام کاربری
  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'نام کاربری الزامی است';
    }
    if (value.trim().length < 3) {
      return 'نام کاربری حداقل ۳ کاراکتر باشد';
    }
    if (value.trim().length > 50) {
      return 'نام کاربری حداکثر ۵۰ کاراکتر';
    }
    if (!RegExp(r'^[a-zA-Z0-9_\u0600-\u06FF]+$').hasMatch(value.trim())) {
      return 'نام کاربری فقط شامل حروف، اعداد و _ باشد';
    }
    return null;
  }

  /// اعتبارسنجی رمز عبور
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'رمز عبور الزامی است';
    }
    if (value.length < 6) {
      return 'رمز عبور حداقل ۶ کاراکتر باشد';
    }
    return null;
  }

  /// اعتبارسنجی رمز عبور قوی
  static String? validateStrongPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'رمز عبور الزامی است';
    }
    if (value.length < 8) {
      return 'رمز عبور حداقل ۸ کاراکتر باشد';
    }
    if (!RegExp(r'[A-Za-z]').hasMatch(value)) {
      return 'رمز عبور باید شامل حروف باشد';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'رمز عبور باید شامل عدد باشد';
    }
    return null;
  }

  /// اعتبارسنجی بارکد
  static String? validateBarcode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'بارکد الزامی است';
    }
    final normalized = value.toEnglishDigit().trim();
    if (normalized.length < 4) {
      return 'بارکد حداقل ۴ کاراکتر باشد';
    }
    if (normalized.length > 50) {
      return 'بارکد حداکثر ۵۰ کاراکتر';
    }
    return null;
  }

  /// تطابق رمز عبور
  static String? validatePasswordMatch(String? value, String original) {
    if (value == null || value.isEmpty) {
      return 'تکرار رمز عبور الزامی است';
    }
    if (value != original) {
      return 'رمز عبور و تکرار آن یکسان نیستند';
    }
    return null;
  }

  /// اعتبارسنجی نام فارسی
  static String? validatePersianName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'این فیلد الزامی است';
    }
    if (value.trim().length < 2) {
      return 'حداقل ۲ کاراکتر';
    }
    if (value.trim().length > 100) {
      return 'حداکثر ۱۰۰ کاراکتر';
    }
    return null;
  }

  /// اعتبارسنجی عدد مثبت
  static String? validatePositiveInt(String? value) {
    if (value == null || value.isEmpty) {
      return 'این فیلد الزامی است';
    }
    final num = int.tryParse(value.toEnglishDigit());
    if (num == null) {
      return 'عدد نامعتبر است';
    }
    if (num <= 0) {
      return 'عدد باید مثبت باشد';
    }
    return null;
  }
}
