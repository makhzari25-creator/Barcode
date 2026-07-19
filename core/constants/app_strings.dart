/// تمام رشته‌های متنی اپلیکیشن به زبان فارسی
class AppStrings {
  AppStrings._();

  // App
  static const String appName = 'تأیید بارکد انبار';
  static const String appVersion = '۱.۰.۰';

  // Login
  static const String login = 'ورود به سیستم';
  static const String username = 'نام کاربری';
  static const String password = 'رمز عبور';
  static const String role = 'نقش';
  static const String roleAdmin = 'مدیر';
  static const String roleOperator = 'اپراتور';
  static const String welcome = 'خوش آمدید';
  static const String loginError = 'نام کاربری یا رمز عبور اشتباه است';
  static const String usernameRequired = 'نام کاربری الزامی است';
  static const String passwordRequired = 'رمز عبور الزامی است';
  static const String passwordTooShort = 'رمز عبور حداقل ۶ کاراکتر باشد';
  static const String logout = 'خروج';
  static const String logoutConfirm = 'آیا از خروج اطمینان دارید؟';
  static const String cancel = 'انصراف';
  static const String confirm = 'تأیید';

  // Home
  static const String home = 'صفحه اصلی';
  static const String startScan = 'شروع اسکن';
  static const String reports = 'گزارش‌ها';
  static const String importExcel = 'وارد کردن فایل اکسل';
  static const String settings = 'تنظیمات';
  static const String exit = 'خروج';
  static const String totalBarcodes = 'تعداد بارکدهای بارگذاری‌شده';

  // Scanner
  static const String scanTitle = 'اسکن بارکد';
  static const String flashOn = 'فلش روشن';
  static const String flashOff = 'فلش خاموش';
  static const String autoFocus = 'فوکوس خودکار';
  static const String stopScan = 'توقف';
  static const String resumeScan = 'ادامه';
  static const String lastScan = 'آخرین بارکد';
  static const String todayCount = 'تعداد امروز';
  static const String cameraPermissionRequired = 'دسترسی به دوربین الزامی است';
  static const String cameraPermissionDenied = 'دسترسی به دوربین رد شد. لطفاً از تنظیمات فعال کنید.';
  static const String grantPermission = 'اعطای دسترسی';

  // Scan Results
  static const String validBarcode = 'بارکد معتبر است';
  static const String invalidBarcode = 'بارکد در لیست وجود ندارد';
  static const String duplicateBarcode = 'این بارکد قبلاً ثبت شده است';
  static const String scannedAt = 'اسکن شده در';

  // Reports
  static const String reportsTitle = 'گزارش اسکن‌ها';
  static const String totalScans = 'تعداد کل اسکن‌ها';
  static const String validCount = 'معتبر';
  static const String invalidCount = 'نامعتبر';
  static const String duplicateCount = 'تکراری';
  static const String fromDate = 'از تاریخ';
  static const String toDate = 'تا تاریخ';
  static const String operator = 'اپراتور';
  static const String allOperators = 'همه اپراتورها';
  static const String exportExcel = 'خروجی Excel';
  static const String noData = 'داده‌ای برای نمایش وجود دارد';
  static const String barcode = 'بارکد';
  static const String date = 'تاریخ';
  static const String time = 'ساعت';
  static const String status = 'وضعیت';

  // Import
  static const String importTitle = 'وارد کردن فایل اکسل';
  static const String selectFile = 'انتخاب فایل';
  static const String fileName = 'فایل';
  static const String fileSize = 'سایز';
  static const String recordCount = 'تعداد رکوردها';
  static const String importMode = 'حالت Import';
  static const String addMode = 'افزودن به موجود';
  static const String replaceMode = 'جایگزینی کامل';
  static const String startImport = 'شروع Import';
  static const String importProgress = 'پیشرفت';
  static const String importSuccess = 'Import با موفقیت انجام شد';
  static const String importedCount = 'تعداد وارد شده';
  static const String skippedCount = 'تعداد تکراری';
  static const String errorCount = 'تعداد خطا';
  static const String importError = 'خطا در Import فایل';
  static const String invalidFileFormat = 'فرمت فایل نامعتبر است';
  static const String requiredColumn = 'ستون الزامی';
  static const String barcodeColumn = 'barcode';

  // Settings
  static const String settingsTitle = 'تنظیمات';
  static const String sound = 'صدا';
  static const String vibration = 'لرزش';
  static const String autoFlash = 'فلش خودکار';
  static const String darkMode = 'حالت تاریک';
  static const String themeLight = 'روشن';
  static const String themeDark = 'تاریک';
  static const String themeSystem = 'سیستم';
  static const String resultDuration = 'مدت نمایش نتیجه';
  static const String changePassword = 'تغییر رمز عبور';
  static const String oldPassword = 'رمز عبور فعلی';
  static const String newPassword = 'رمز عبور جدید';
  static const String confirmPassword = 'تکرار رمز عبور جدید';
  static const String passwordsDoNotMatch = 'رمز عبور و تکرار آن یکسان نیستند';
  static const String passwordChanged = 'رمز عبور با موفقیت تغییر کرد';
  static const String clearScans = 'پاک‌سازی اسکن‌ها';
  static const String clearScansConfirm = 'آیا تمام اسکن‌ها حذف شوند؟';
  static const String about = 'درباره اپلیکیشن';
  static const String backup = 'پشتیبان‌گیری';
  static const String restore = 'بازگردانی';

  // Validation
  static const String emptyError = 'این فیلد الزامی است';
  static const String invalidNumber = 'عدد نامعتبر است';
  static const String save = 'ذخیره';
  static const String delete = 'حذف';
  static const String edit = 'ویرایش';
  static const String add = 'افزودن';
  static const String close = 'بستن';
  static const String retry = 'تلاش مجدد';
  static const String loading = 'در حال بارگذاری...';
  static const String saving = 'در حال ذخیره...';
  static const String processing = 'در حال پردازش...';
  static const String success = 'موفقیت';
  static const String error = 'خطا';
  static const String warning = 'هشدار';
  static const String info = 'اطلاعات';

  // Errors
  static const String genericError = 'خطایی رخ داد. لطفاً دوباره تلاش کنید.';
  static const String networkError = 'خطای شبکه';
  static const String databaseError = 'خطای پایگاه داده';
  static const String fileNotFoundError = 'فایل پیدا نشد';
  static const String permissionDenied = 'دسترسی رد شد';

  // Date
  static const String today = 'امروز';
  static const String yesterday = 'دیروز';
  static const String days = 'روز';
}
