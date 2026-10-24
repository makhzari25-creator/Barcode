import 'package:flutter/foundation.dart';
import '../models/product.dart';
import 'excel_service.dart';
import 'product_index.dart';
import 'storage_service.dart';

/// مدیریت central state بخش «چک کردن شارژ»
/// - نگهداری لیست کالاها
/// - نگهداری شمارنده‌های اسکن
/// - عملیات: بارگذاری فایل، اسکن، ریست، بایگانی
class AppState extends ChangeNotifier {
  AppState({ExcelService? excelService, StorageService? storageService})
      : _excelService = excelService ?? ExcelService(),
        _storageService = storageService ?? StorageService();

  final ExcelService _excelService;
  final StorageService _storageService;

  List<Product> _products = [];
  Map<String, int> _scanCounts = {};
  String? _excelFileName;
  bool _loading = false;
  String? _error;
  List<ArchivedSession> _archives = [];

  final ProductIndex _index = ProductIndex();

  List<Product> get products => List.unmodifiable(_products);
  Map<String, int> get scanCounts => Map.unmodifiable(_scanCounts);
  String? get excelFileName => _excelFileName;
  bool get loading => _loading;
  String? get error => _error;
  bool get hasFile => _products.isNotEmpty;
  List<ArchivedSession> get archives => List.unmodifiable(_archives);

  /// تعداد کالاهایی که شارژشان کامل شده است
  int get completedCount {
    var n = 0;
    for (final p in _products) {
      if (isProductComplete(p)) n++;
    }
    return n;
  }

  /// نسبت کالاهای کامل‌شده به کل کالاها (بین ۰ و ۱)
  double get progress =>
      _products.isEmpty ? 0 : completedCount / _products.length;

  /// آیا همه کالاها به تعداد لازم اسکن شده‌اند؟
  bool get isFullyComplete =>
      _products.isNotEmpty && completedCount == _products.length;

  bool isProductComplete(Product p) =>
      p.requiredCount > 0 && scannedCountFor(p.code) >= p.requiredCount;

  /// بارگذاری وضعیت ذخیره‌شده در ابتدای برنامه
  Future<void> initialize() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _products = await _storageService.loadProducts();
      _scanCounts = await _storageService.loadScanStates();
      _excelFileName = await _storageService.getExcelFileName();
      _archives = await _storageService.loadArchive();
      _index.rebuild(_products);
    } catch (e) {
      _error = 'خطا در بارگذاری داده‌ها: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// بارگذاری فایل اکسل جدید (جایگزین فایل قبلی)
  /// اگر فایل قبلی اسکنی داشت، ابتدا به‌طور کامل در بایگانی ذخیره می‌شود
  /// و سپس صفحه‌ی فعلی با فایل جدید از صفر شروع می‌شود
  /// (هیچ شمارنده‌ای از فایل قبلی به فایل جدید منتقل نمی‌شود)
  Future<bool> loadExcelFile(String filePath, {String? fileName}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      // اول فایل جدید خوانده می‌شود تا در صورت خطا هیچ چیز تغییر نکند
      final products = await _excelService.readProducts(filePath);

      if (_products.isNotEmpty && _scanCounts.values.any((c) => c > 0)) {
        _archives.insert(
          0,
          ArchivedSession(
            fileName: _excelFileName ?? 'فایل بدون نام',
            archivedAt: DateTime.now(),
            products: List<Product>.from(_products),
            scanCounts: Map<String, int>.from(_scanCounts),
          ),
        );
        await _storageService.saveArchive(_archives);
      }

      _products = products;
      _scanCounts = {};
      _excelFileName = fileName ?? filePath.split('/').last;
      _index.rebuild(_products);

      await _storageService.saveProducts(_products, fileName: _excelFileName);
      await _storageService.saveScanStates(_scanCounts);
      _loading = false;
      notifyListeners();
      return true;
    } on ExcelException catch (e) {
      _error = e.message;
      _loading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'خطا در بارگذاری فایل: $e';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  /// حذف یک مورد از بایگانی
  Future<void> deleteArchive(int index) async {
    if (index < 0 || index >= _archives.length) return;
    _archives.removeAt(index);
    await _storageService.saveArchive(_archives);
    notifyListeners();
  }

  /// خالی کردن کامل بایگانی
  Future<void> clearArchives() async {
    _archives = [];
    await _storageService.saveArchive(_archives);
    notifyListeners();
  }

  /// جستجوی کالا با کد (فارسی/انگلیسی، با یا بدون صفر ابتدایی)
  Product? findProduct(String code) => _index.find(code);

  /// ثبت یک اسکن برای کالای مشخص
  Future<ScanResult> recordScan(String code) async {
    final product = findProduct(code);
    if (product == null) {
      return ScanResult.notFound;
    }

    final key = product.code;
    final required = product.requiredCount;
    final current = _scanCounts[key] ?? 0;

    if (required > 0 && current >= required) {
      return ScanResult.alreadyComplete;
    }

    final newCount = current + 1;
    _scanCounts[key] = newCount;
    await _storageService.saveScanStates(_scanCounts);
    notifyListeners();

    if (required > 0 && newCount >= required) {
      return ScanResult.justCompleted;
    }
    return ScanResult.scanned;
  }

  /// تعداد اسکن‌شده برای یک کالا
  int scannedCountFor(String code) => _scanCounts[code] ?? 0;

  /// ریست شمارنده‌ها (لیست کالاها باقی می‌ماند)
  Future<void> resetCounters() async {
    _scanCounts.clear();
    await _storageService.resetScanStates();
    notifyListeners();
  }

  /// حذف لیست کالاها و شمارنده‌های فعلی (بایگانی باقی می‌ماند)
  Future<void> clearAll() async {
    _products = [];
    _scanCounts = {};
    _excelFileName = null;
    _index.clear();
    await _storageService.clearAll();
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

/// نتیجه عملیات اسکن
enum ScanResult {
  /// کالا پیدا نشد
  notFound,

  /// اسکن شد و شمارنده افزایش یافت
  scanned,

  /// این اسکن باعث تکمیل شارژ شد
  justCompleted,

  /// شارژ این کالا قبلاً کامل شده و افزایش نمی‌یابد
  alreadyComplete,
}
