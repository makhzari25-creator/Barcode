import 'package:flutter/foundation.dart';
import '../models/product.dart';
import 'excel_service.dart';
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
  final ExcelService _excelService = ExcelService();
  final StorageService _storageService = StorageService();

  List<Product> _products = [];
  Set<String> _confirmed = {};
  String? _fileName;
  bool _loading = false;
  String? _error;

  final Map<String, Product> _byCode = {};

  List<Product> get products => List.unmodifiable(_products);
  String? get fileName => _fileName;
  bool get loading => _loading;
  String? get error => _error;
  bool get hasFile => _products.isNotEmpty;
  int get confirmedCount => _confirmed.length;
  bool get isFullyComplete =>
      _products.isNotEmpty && _confirmed.length >= _products.length;

  bool isConfirmed(String code) => _confirmed.contains(code);

  /// بارگذاری وضعیت ذخیره‌شده در ابتدای برنامه
  Future<void> initialize() async {
    _loading = true;
    notifyListeners();
    try {
      _products = await _storageService.loadHallProducts();
      _confirmed = await _storageService.loadHallConfirmed();
      _fileName = await _storageService.getHallFileName();
      _rebuildCache();
    } catch (e) {
      _error = 'خطا در بارگذاری داده‌ها: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// بارگذاری فایل اکسل جدید. فقط ستون‌های «کد محصول» و «عنوان محصول» استفاده
  /// می‌شود؛ در صورت وجود ستون تعداد، نادیده گرفته می‌شود.
  Future<bool> loadExcelFile(String filePath, {String? fileName}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final products = await _excelService.readProducts(filePath);

      _products = products;
      _confirmed = {};
      _fileName = fileName ?? filePath.split('/').last;
      _rebuildCache();

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

  Product? findProduct(String code) {
    if (code.isEmpty) return null;
    return _byCode[code];
  }

  /// ثبت یک اسکن: فقط تطبیق کد با نام محصول را بررسی و علامت می‌زند
  Future<HallScanResult> recordScan(String code) async {
    final product = findProduct(code);
    if (product == null) {
      return HallScanResult.notFound;
    }
    if (_confirmed.contains(code)) {
      return HallScanResult.alreadyConfirmed;
    }
    _confirmed.add(code);
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

  /// حذف کامل داده‌های این بخش
  Future<void> clearAll() async {
    _products = [];
    _confirmed = {};
    _fileName = null;
    _byCode.clear();
    await _storageService.clearHall();
    notifyListeners();
  }

  void _rebuildCache() {
    _byCode.clear();
    for (final p in _products) {
      if (p.code.isNotEmpty) {
        _byCode[p.code] = p;
      }
    }
  }
}
