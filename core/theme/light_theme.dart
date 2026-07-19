import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

/// تم روشن اپلیکیشن
ThemeData buildLightTheme() {
  final ColorScheme colorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    primary: AppColors.primary,
    onPrimary: AppColors.textOnPrimary,
    primaryContainer: AppColors.primaryLight,
    onPrimaryContainer: AppColors.primaryDark,
    secondary: AppColors.accent,
    onSecondary: AppColors.primaryDark,
    secondaryContainer: Color(0xFFFFF8E1),
    onSecondaryContainer: AppColors.accentDark,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    error: AppColors.error,
    onError: Colors.white,
    brightness: Brightness.light,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: 'Vazirmatn',
    textTheme: _buildTextTheme(AppColors.textPrimary, AppColors.textSecondary),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(AppDimensions.buttonMinWidth, AppDimensions.buttonHeight),
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingLg, vertical: AppDimensions.paddingMd),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMd)),
        elevation: 2,
        textStyle: const TextStyle(
          fontFamily: 'Vazirmatn',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        minimumSize: const Size(AppDimensions.buttonMinWidth, AppDimensions.buttonHeight),
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMd)),
        textStyle: const TextStyle(
          fontFamily: 'Vazirmatn',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: const TextStyle(fontFamily: 'Vazirmatn', fontWeight: FontWeight.w500),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.gray100,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMd, vertical: AppDimensions.paddingMd),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.inputBorderRadius),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.inputBorderRadius),
        borderSide: const BorderSide(color: AppColors.gray300, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.inputBorderRadius),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.inputBorderRadius),
        borderSide: const BorderSide(color: AppColors.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.inputBorderRadius),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      labelStyle: const TextStyle(
        fontFamily: 'Vazirmatn',
        color: AppColors.textSecondary,
        fontSize: 14,
      ),
      hintStyle: const TextStyle(
        fontFamily: 'Vazirmatn',
        color: AppColors.textHint,
        fontSize: 14,
      ),
      errorStyle: const TextStyle(
        fontFamily: 'Vazirmatn',
        color: AppColors.error,
        fontSize: 12,
      ),
    ),
    cardTheme: CardTheme(
      color: AppColors.surface,
      elevation: AppDimensions.cardElevation,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius)),
      margin: const EdgeInsets.symmetric(vertical: AppDimensions.spacingSm),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.gray200,
      thickness: 1,
      space: 1,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.gray900,
      contentTextStyle: const TextStyle(fontFamily: 'Vazirmatn', color: Colors.white, fontSize: 14),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusSm)),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusLg)),
      titleTextStyle: const TextStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      contentTextStyle: const TextStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 14,
        color: AppColors.textSecondary,
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusLg)),
      ),
    ),
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: AppDimensions.paddingMd, vertical: AppDimensions.spacingXs),
      titleTextStyle: TextStyle(fontFamily: 'Vazirmatn', fontSize: 15, fontWeight: FontWeight.w500),
      subtitleTextStyle: TextStyle(fontFamily: 'Vazirmatn', fontSize: 13, color: AppColors.textSecondary),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected) ? Colors.white : AppColors.gray400),
      trackColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected) ? AppColors.primary : AppColors.gray300),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primary,
      linearTrackColor: AppColors.gray200,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.accent,
      foregroundColor: AppColors.primaryDark,
      elevation: 4,
    ),
  );
}

TextTheme _buildTextTheme(Color primary, Color secondary) {
  return TextTheme(
    displayLarge: TextStyle(fontFamily: 'Vazirmatn', fontSize: 32, fontWeight: FontWeight.w900, color: primary, height: 1.2),
    displayMedium: TextStyle(fontFamily: 'Vazirmatn', fontSize: 28, fontWeight: FontWeight.w800, color: primary, height: 1.25),
    displaySmall: TextStyle(fontFamily: 'Vazirmatn', fontSize: 24, fontWeight: FontWeight.w700, color: primary, height: 1.3),
    headlineLarge: TextStyle(fontFamily: 'Vazirmatn', fontSize: 22, fontWeight: FontWeight.w700, color: primary, height: 1.3),
    headlineMedium: TextStyle(fontFamily: 'Vazirmatn', fontSize: 20, fontWeight: FontWeight.w600, color: primary, height: 1.35),
    headlineSmall: TextStyle(fontFamily: 'Vazirmatn', fontSize: 18, fontWeight: FontWeight.w600, color: primary, height: 1.4),
    titleLarge: TextStyle(fontFamily: 'Vazirmatn', fontSize: 17, fontWeight: FontWeight.w700, color: primary),
    titleMedium: TextStyle(fontFamily: 'Vazirmatn', fontSize: 15, fontWeight: FontWeight.w600, color: primary),
    titleSmall: TextStyle(fontFamily: 'Vazirmatn', fontSize: 13, fontWeight: FontWeight.w600, color: primary),
    bodyLarge: TextStyle(fontFamily: 'Vazirmatn', fontSize: 16, fontWeight: FontWeight.w400, color: primary, height: 1.8),
    bodyMedium: TextStyle(fontFamily: 'Vazirmatn', fontSize: 14, fontWeight: FontWeight.w400, color: primary, height: 1.8),
    bodySmall: TextStyle(fontFamily: 'Vazirmatn', fontSize: 12, fontWeight: FontWeight.w400, color: secondary, height: 1.7),
    labelLarge: TextStyle(fontFamily: 'Vazirmatn', fontSize: 14, fontWeight: FontWeight.w600, color: primary),
    labelMedium: TextStyle(fontFamily: 'Vazirmatn', fontSize: 12, fontWeight: FontWeight.w500, color: primary),
    labelSmall: TextStyle(fontFamily: 'Vazirmatn', fontSize: 11, fontWeight: FontWeight.w500, color: secondary),
  );
}
