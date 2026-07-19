/// ابعاد و فاصله‌های استاندارد اپلیکیشن
class AppDimensions {
  AppDimensions._();

  // Spacing
  static const double spacingXs = 4;
  static const double spacingSm = 8;
  static const double spacingMd = 16;
  static const double spacingLg = 24;
  static const double spacingXl = 32;
  static const double spacingXxl = 48;

  // Padding
  static const double paddingSm = 12;
  static const double paddingMd = 16;
  static const double paddingLg = 20;
  static const double paddingXl = 24;

  // Border Radius
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;
  static const double radiusFull = 999;

  // Button sizes - حداقل 56dp برای محیط انبار
  static const double buttonHeight = 56;
  static const double buttonHeightLg = 72;
  static const double buttonHeightSm = 44;
  static const double buttonMinWidth = 120;

  // Input
  static const double inputHeight = 56;
  static const double inputBorderRadius = 12;

  // App Bar
  static const double appBarHeight = 56;

  // Card
  static const double cardElevation = 2;
  static const double cardBorderRadius = 12;

  // Icon sizes
  static const double iconSm = 16;
  static const double iconMd = 24;
  static const double iconLg = 32;
  static const double iconXl = 48;
  static const double iconXxl = 80;

  // Result overlay
  static const double resultIconSize = 120;
  static const double resultTitleSize = 28;
  static const double resultOverlayDurationMs = 1500;

  // Scanner
  static const double scannerCooldownMs = 1000;
  static const double scannerFrameSize = 250;

  // Performance
  static const int bloomFilterCapacity = 1000000;
  static const double bloomFilterFpRate = 0.001;
  static const int scanHistoryLimit = 50;
  static const int reportPageSize = 100;
}
