import 'package:flutter/material.dart';

/// رنگ‌های اصلی اپلیکیشن - تم آبی شرکتی
/// مطابق سند تحلیل: Primary #1565C0, Accent #FFC107
class AppColors {
  AppColors._();

  // Primary - آبی شرکتی
  static const Color primary = Color(0xFF1565C0);
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color primaryLight = Color(0xFFE3F2FD);
  static const Color primaryContainer = Color(0xFFBBDEFB);

  // Accent - طلایی
  static const Color accent = Color(0xFFFFC107);
  static const Color accentDark = Color(0xFFFF8F00);

  // Status colors
  static const Color success = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color error = Color(0xFFC62828);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color warning = Color(0xFFF9A825);
  static const Color warningLight = Color(0xFFFFF8E1);

  // Grays
  static const Color gray50 = Color(0xFFFAFAFA);
  static const Color gray100 = Color(0xFFF5F5F5);
  static const Color gray200 = Color(0xFFEEEEEE);
  static const Color gray300 = Color(0xFFE0E0E0);
  static const Color gray400 = Color(0xFFBDBDBD);
  static const Color gray500 = Color(0xFF9E9E9E);
  static const Color gray600 = Color(0xFF757575);
  static const Color gray700 = Color(0xFF616161);
  static const Color gray800 = Color(0xFF424242);
  static const Color gray900 = Color(0xFF212121);

  // Backgrounds
  static const Color background = Color(0xFFF8F9FB);
  static const Color surface = Colors.white;
  static const Color surfaceDark = Color(0xFF1A1A2E);

  // Text
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF555555);
  static const Color textHint = Color(0xFF9E9E9E);
  static const Color textOnPrimary = Colors.white;

  // Dark theme
  static const Color darkPrimary = Color(0xFF42A5F5);
  static const Color darkBackground = Color(0xFF0F1419);
  static const Color darkSurface = Color(0xFF1A1A2E);
  static const Color darkTextPrimary = Color(0xFFECEFF1);
  static const Color darkTextSecondary = Color(0xFFB0BEC5);
}

/// رنگ‌های نتیجه اسکن
class ScanResultColors {
  ScanResultColors._();

  // معتبر - سبز
  static const Color validBg = Color(0xFF2E7D32);
  static const Color validAccent = Color(0xFF66BB6A);
  static const Color validText = Colors.white;

  // نامعتبر - قرمز
  static const Color invalidBg = Color(0xFFC62828);
  static const Color invalidAccent = Color(0xFFEF5350);
  static const Color invalidText = Colors.white;

  // تکراری - زرد
  static const Color duplicateBg = Color(0xFFF9A825);
  static const Color duplicateAccent = Color(0xFFFFB300);
  static const Color duplicateText = Colors.white;
}
