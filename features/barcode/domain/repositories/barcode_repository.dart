import '../../../../core/errors/failures.dart';
import '../../domain/entities/barcode.dart';

/// قرارداد Repository بارکدها
abstract class BarcodeRepository {
  /// بررسی وجود بارکد در لیست مجاز
  /// ابتدا Bloom Filter چک می‌شود، سپس SQLite
  Future<bool> isBarcodeValid(String code);

  /// دریافت بارکد با کد
  Future<Barcode?> getBarcode(String code);

  /// دریافت تعداد کل بارکدها
  Future<int> getBarcodeCount();

  /// دریافت همه بارکدها (با صفحه‌بندی)
  Future<List<Barcode>> getAllBarcodes({int limit = 100, int offset = 0});

  /// افزودن بارکد جدید
  Future<Either<Failure, Barcode>> addBarcode(Barcode barcode);

  /// جایگزینی کامل لیست بارکدها
  /// تمام بارکدهای قبلی حذف و لیست جدید وارد می‌شود
  Future<Either<Failure, int>> replaceAllBarcodes(List<Barcode> barcodes);

  /// افزودن لیست بارکدها به موجود
  /// خروجی: تعداد اضافه‌شده (تکراری‌ها نادیده گرفته می‌شوند)
  Future<Either<Failure, int>> addBarcodes(List<Barcode> barcodes);

  /// حذف همه بارکدها
  Future<Either<Failure, bool>> deleteAllBarcodes();

  /// دریافت همه کدهای بارکد برای بارگذاری در Bloom Filter
  Future<List<String>> getAllBarcodeCodes();

  /// بارگذاری مجدد Bloom Filter از دیتابیس
  Future<void> reloadBloomFilter();
}
