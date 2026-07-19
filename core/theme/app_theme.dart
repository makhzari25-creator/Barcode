import 'package:flutter/material.dart';
import 'light_theme.dart';
import 'dark_theme.dart';

/// مدیریت تم اپلیکیشن
class AppTheme {
  AppTheme._();

  static ThemeData get light => buildLightTheme();
  static ThemeData get dark => buildDarkTheme();

  /// انتخاب تم بر اساس وضعیت
  static ThemeData of(Brightness brightness) {
    return brightness == Brightness.dark ? dark : light;
  }
}
