import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';

/// سرویس ذخیره‌سازی دائمی وضعیت کالاها، شمارنده‌ها و تنظیمات
/// با بستن برنامه اطلاعات از بین نمی‌رود
class StorageService {
  static const _productsKey = 'products_list';
  static const _scanStatesKey = 'scan_states';
  static const _excelFileNameKey = 'excel_file_name';
  static const _archiveKey = 'archived_sessions';

  // کلیدهای مربوط به صفحه‌ی «شارژ سالن»
  static const _hallProductsKey = 'hall_products_list';
  static const _hallConfirmedKey = 'hall_confirmed_codes';
  static const _hallFileNameKey = 'hall_file_name';
  static const _hallArchiveKey = 'hall_archived_sessions';

  // کلیدهای تنظیمات
  static const _soundKey = 'settings_sound';
  static const _vibrationKey = 'settings_vibration';

  SharedPreferences? _prefs;

  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // ---------------- کمکی‌های مشترک ----------------

  Future<void> _saveProducts(String key, List<Product> products) async {
    final prefs = await _getPrefs();
    final jsonList = products.map((p) => p.toJson()).toList();
    await prefs.setString(key, jsonEncode(jsonList));
  }

  Future<List<Product>> _loadProducts(String key) async {
    final prefs = await _getPrefs();
    final str = prefs.getString(key);
    if (str == null) return [];
    try {
      final list = jsonDecode(str) as List;
      return list
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveArchive(String key, List<ArchivedSession> sessions) async {
    final prefs = await _getPrefs();
    final jsonList = sessions.map((s) => s.toJson()).toList();
    await prefs.setString(key, jsonEncode(jsonList));
  }

  Future<List<ArchivedSession>> _loadArchive(String key) async {
    final prefs = await _getPrefs();
    final str = prefs.getString(key);
    if (str == null) return [];
    try {
      final list = jsonDecode(str) as List;
      return list
          .map((e) => ArchivedSession.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ---------------- چک کردن شارژ ----------------

  /// ذخیره لیست کالاها (همراه با اطلاعات فایل اکسل)
  Future<void> saveProducts(List<Product> products, {String? fileName}) async {
    await _saveProducts(_productsKey, products);
    if (fileName != null) {
      final prefs = await _getPrefs();
      await prefs.setString(_excelFileNameKey, fileName);
    }
  }

  Future<List<Product>> loadProducts() => _loadProducts(_productsKey);

  /// ذخیره شمارنده‌های اسکن
  Future<void> saveScanStates(Map<String, int> scanCounts) async {
    final prefs = await _getPrefs();
    final list = scanCounts.entries
        .map((e) => ScanState(code: e.key, scannedCount: e.value).toJson())
        .toList();
    await prefs.setString(_scanStatesKey, jsonEncode(list));
  }

  /// بارگذاری شمارنده‌های اسکن
  Future<Map<String, int>> loadScanStates() async {
    final prefs = await _getPrefs();
    final str = prefs.getString(_scanStatesKey);
    if (str == null) return {};
    try {
      final list = jsonDecode(str) as List;
      final map = <String, int>{};
      for (final e in list) {
        final s = ScanState.fromJson(e as Map<String, dynamic>);
        map[s.code] = s.scannedCount;
      }
      return map;
    } catch (_) {
      return {};
    }
  }

  /// نام فایل اکسل بارگذاری‌شده
  Future<String?> getExcelFileName() async {
    final prefs = await _getPrefs();
    return prefs.getString(_excelFileNameKey);
  }

  /// ریست کامل شمارنده‌ها (بدون حذف لیست کالاها)
  Future<void> resetScanStates() async {
    final prefs = await _getPrefs();
    await prefs.remove(_scanStatesKey);
  }

  /// حذف کامل داده‌ها (لیست کالاها، شمارنده‌ها و نام فایل)؛ بایگانی دست نمی‌خورد
  Future<void> clearAll() async {
    final prefs = await _getPrefs();
    await prefs.remove(_productsKey);
    await prefs.remove(_scanStatesKey);
    await prefs.remove(_excelFileNameKey);
  }

  Future<void> saveArchive(List<ArchivedSession> sessions) =>
      _saveArchive(_archiveKey, sessions);

  Future<List<ArchivedSession>> loadArchive() => _loadArchive(_archiveKey);

  // ---------------- شارژ سالن ----------------

  Future<void> saveHallProducts(List<Product> products,
      {String? fileName}) async {
    await _saveProducts(_hallProductsKey, products);
    if (fileName != null) {
      final prefs = await _getPrefs();
      await prefs.setString(_hallFileNameKey, fileName);
    }
  }

  Future<List<Product>> loadHallProducts() => _loadProducts(_hallProductsKey);

  /// ذخیره‌ی کدهای تاییدشده (اسکن‌شده) در شارژ سالن
  Future<void> saveHallConfirmed(Set<String> codes) async {
    final prefs = await _getPrefs();
    await prefs.setStringList(_hallConfirmedKey, codes.toList());
  }

  Future<Set<String>> loadHallConfirmed() async {
    final prefs = await _getPrefs();
    final list = prefs.getStringList(_hallConfirmedKey);
    return list?.toSet() ?? {};
  }

  Future<String?> getHallFileName() async {
    final prefs = await _getPrefs();
    return prefs.getString(_hallFileNameKey);
  }

  /// حذف کامل داده‌های شارژ سالن؛ بایگانی دست نمی‌خورد
  Future<void> clearHall() async {
    final prefs = await _getPrefs();
    await prefs.remove(_hallProductsKey);
    await prefs.remove(_hallConfirmedKey);
    await prefs.remove(_hallFileNameKey);
  }

  Future<void> saveHallArchive(List<ArchivedSession> sessions) =>
      _saveArchive(_hallArchiveKey, sessions);

  Future<List<ArchivedSession>> loadHallArchive() =>
      _loadArchive(_hallArchiveKey);

  // ---------------- تنظیمات ----------------

  Future<bool> loadSoundEnabled() async {
    final prefs = await _getPrefs();
    return prefs.getBool(_soundKey) ?? true;
  }

  Future<bool> loadVibrationEnabled() async {
    final prefs = await _getPrefs();
    return prefs.getBool(_vibrationKey) ?? true;
  }

  Future<void> saveSoundEnabled(bool value) async {
    final prefs = await _getPrefs();
    await prefs.setBool(_soundKey, value);
  }

  Future<void> saveVibrationEnabled(bool value) async {
    final prefs = await _getPrefs();
    await prefs.setBool(_vibrationKey, value);
  }
}
