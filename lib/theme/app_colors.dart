import 'package:flutter/material.dart';

/// پالت رنگی برند (MA LABS - Built on Trust) با تم روشن
class AppColors {
  AppColors._();

  // ---- رنگ‌های اصلی برند (اسپلش و جزئیات اسکنر) ----

  /// آبی فیروزه‌ای روشن - رنگ اصلی برند
  static const Color cyan = Color(0xFF00E6FF);

  /// آبی-سبز تیره - رنگ ثانویه برند
  static const Color teal = Color(0xFF007C8A);

  /// خاکستری خیلی تیره
  static const Color darkGray = Color(0xFF0D0D0D);

  /// مشکی کامل
  static const Color black = Color(0xFF000000);

  // ---- پالت تم روشن ----

  /// پس‌زمینه صفحه‌ها (سفید مایل به فیروزه‌ای)
  static const Color background = Color(0xFFF2F8FA);

  /// سطح کارت‌ها
  static const Color surface = Color(0xFFFFFFFF);

  /// سطح ثانویه (چیپ‌ها، ورودی‌ها)
  static const Color surfaceAlt = Color(0xFFE6F1F4);

  /// رنگ اصلی دکمه‌ها و تاکیدها در «چک کردن شارژ»
  static const Color primary = Color(0xFF007C8A);

  /// نسخه تیره‌تر رنگ اصلی برای متن روی زمینه روشن
  static const Color primaryDark = Color(0xFF005A66);

  /// رنگ اصلی بخش «شارژ سالن»
  static const Color hall = Color(0xFF1F5FD6);

  static const Color hallSoft = Color(0xFFE4EDFC);
  static const Color primarySoft = Color(0xFFDDF2F5);

  /// متن اصلی و ثانویه
  static const Color text = Color(0xFF0F2A30);
  static const Color textMuted = Color(0xFF58747C);

  /// خطوط و حاشیه‌ها
  static const Color border = Color(0xFFD3E3E8);

  // ---- رنگ‌های معنایی ----
  static const Color success = Color(0xFF2E7D32);
  static const Color successSoft = Color(0xFFE4F4E6);
  static const Color warning = Color(0xFFC77700);
  static const Color warningSoft = Color(0xFFFFF1D6);
  static const Color danger = Color(0xFFC62828);
  static const Color dangerSoft = Color(0xFFFDE8E8);
}
