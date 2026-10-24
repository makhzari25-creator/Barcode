import '../models/product.dart';
import '../utils/barcode_utils.dart';

/// نمایه‌ی جستجوی سریع کالا با کد بارکد (زمان O(1))
/// ابتدا تطبیق دقیق انجام می‌شود، سپس تطبیق بدون صفرهای ابتدایی
/// (برای فایل‌هایی که اکسل صفرهای ابتدای کد را حذف کرده است).
class ProductIndex {
  final Map<String, Product> _exact = {};
  final Map<String, Product> _loose = {};

  void rebuild(List<Product> products) {
    _exact.clear();
    _loose.clear();
    for (final p in products) {
      if (p.code.isEmpty) continue;
      _exact[p.code] = p;
      _loose.putIfAbsent(codeLooseKey(p.code), () => p);
    }
  }

  void clear() {
    _exact.clear();
    _loose.clear();
  }

  Product? find(String raw) {
    final code = normalizeCode(raw);
    if (code.isEmpty) return null;
    return _exact[code] ?? _loose[codeLooseKey(code)];
  }
}
