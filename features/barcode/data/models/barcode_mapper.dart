import '../../../barcode/data/datasources/app_database.dart' as db;
import '../../domain/entities/barcode.dart';

/// Mapper برای تبدیل ردیف دیتابیس به Entity
class BarcodeMapper {
  BarcodeMapper._();

  /// تبدیل BarcodeRow (DB) به Barcode (Entity)
  static Barcode toEntity(db.BarcodeRow row) {
    return Barcode(
      id: row.id,
      code: row.code,
      productName: row.productName,
      productCode: row.productCode,
      category: row.category,
      size: row.size,
      color: row.color,
      importedBatch: row.importedBatch,
      createdAt: row.createdAt,
    );
  }

  /// تبدیل لیست ردیف‌ها به Entity
  static List<Barcode> toEntityList(List<db.BarcodeRow> rows) {
    return rows.map(toEntity).toList();
  }
}
