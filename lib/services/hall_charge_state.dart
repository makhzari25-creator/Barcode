import 'package:flutter/foundation.dart';
import '../models/product.dart';
import 'excel_service.dart';
import 'product_index.dart';
import 'storage_service.dart';

/// نتیجه‌ی اسکن در صفحه‌ی شارژ سالن
enum HallScanResult {
  /// کد محصول در فایل نیست
  notFound,

  /// با موفقیت تایید شد (اولین بار)
  confirmed,

  /// قبلاً همین کالا تایید شده بود
  alreadyConfirmed,
}

/// مدیریت وضعیت صفحه‌ی «شارژ سالن»
/// برخلاف «چک کردن شارژ» که تعداد مورد نیاز را رصد می‌کند، این بخش فقط
/// تطبیق «کد محصول» با «نام محصول» را از طریق اسکن انجام می‌دهد؛ یعنی هر
/// کالا فقط یک‌بار به‌عنوان «تایید شده» علامت می‌خورد (بدون شمارش تعداد).
class HallChargeState extends ChangeNotifier {
  HallChargeState({ExcelService? excelService, StorageService? storageService})
      : _excelService = excelService ?? ExcelService(),
        _storageService = storageService ?? StorageService();

  final ExcelService _excelService;
  final StorageService _storageService;

  List<Product> _products = [];
  Set<String> _confirmed = {};
  String? _fileName;
  bool _loading = false;
  String? _error;
  List<ArchivedSession> _archives = [];

  final ProductIndex _index = ProductIndex();

  List<Product> get products => List.unmodifiable(_products);
  String? get fileName => _fileName;
  bool get loading => _loading;
  String? get error => _error;
  bool get hasFile => _products.isNotEmpty;
  int get confirmedCount => _confirmed.length;
  double get progress =>
      _products.isEmpty ? 0 : _confirmed.length / _products.length;
  bool get isFullyComplete =>
      _products.isNotEmpty && _confirmed.length >= _products.length;
  List<ArchivedSession> get archives => List.unmodifiable(_archives);

  bool isConfirmed(String code) => _confirmed.contains(code);

  /// بارگذاری وضعیت ذخیره‌شده در ابتدای برنامه
  Future<void> initialize() async {
    _loading = true;
    notifyListeners();
    try {
      _products = await _storageService.loadHallProducts();
      _confirmed = await _storageService.loadHallConfirmed();
      _fileName = await _storageService.getHallFileName();
      _archives = await _storageService.loadHallArchive();
      _index.rebuild(_products);
    } catch (e) {
      _error = 'خطا در بارگذاری داده‌ها: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// بارگذاری فایل اکسل جدید. فقط ستون‌های «کد محصول» و «عنوان محصول» (و عکس)
  /// استفاده می‌شود؛ ستون تعداد نادیده گرفته می‌شود.
  /// اگر فایل قبلی تاییدی داشت، پیش از جایگزینی بایگانی می‌شود.
  Future<bool> loadExcelFile(String filePath, {String? fileName}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final products = await _excelService.readProducts(filePath);

      if (_products.isNotEmpty && _confirmed.isNotEmpty) {
        _archives.insert(
          0,
          ArchivedSession(
            fileName: _fileName ?? 'فایل بدون نام',
            archivedAt: DateTime.now(),
            products:
                _products.map((p) => p.copyWith(requiredCount: 1)).toList(),
            scanCounts: {for (final c in _confirmed) c: 1},
          ),
        );
        await _storageService.saveHallArchive(_archives);
      }

      _products = products;
      _confirmed = {};
      _fileName = fileName ?? filePath.split('/').last;
      _index.rebuild(_products);

      await _storageService.saveHallProducts(_products, fileName: _fileName);
      await _storageService.saveHallConfirmed(_confirmed);
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

  Product? findProduct(String code) => _index.find(code);

  /// ثبت یک اسکن: فقط تطبیق کد با نام محصول را بررسی و علامت می‌زند
  Future<HallScanResult> recordScan(String code) async {
    final product = findProduct(code);
    if (product == null) {
      return HallScanResult.notFound;
    }
    if (_confirmed.contains(product.code)) {
      return HallScanResult.alreadyConfirmed;
    }
    _confirmed.add(product.code);
    await _storageService.saveHallConfirmed(_confirmed);
    notifyListeners();
    return HallScanResult.confirmed;
  }

  /// ریست تاییدها (لیست کالاها باقی می‌ماند)
  Future<void> resetConfirmations() async {
    _confirmed = {};
    await _storageService.saveHallConfirmed(_confirmed);
    notifyListeners();
  }

  /// حذف لیست کالاها و تاییدهای فعلی (بایگانی باقی می‌ماند)
  Future<void> clearAll() async {
    _products = [];
    _confirmed = {};
    _fileName = null;
    _index.clear();
    await _storageService.clearHall();
    notifyListeners();
  }

  Future<void> deleteArchive(int index) async {
    if (index < 0 || index >= _archives.length) return;
    _archives.removeAt(index);
    await _storageService.saveHallArchive(_archives);
    notifyListeners();
  }

  Future<void> clearArchives() async {
    _archives = [];
    await _storageService.saveHallArchive(_archives);
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
