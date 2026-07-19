// lib/features/import_export/domain/repositories/import_export_repository.dart
//
// قرارداد Repository برای Import/Export
//

import '../../../barcode/domain/entities/barcode.dart';
import '../../../picking/domain/entities/picking_item.dart';
import '../../../scanner/domain/entities/scan_record.dart';

abstract class ImportExportRepository {
  /// خواندن بارکدها از فایل (Excel یا CSV)
  /// ستون الزامی: barcode
  Future<List<Barcode>> readBarcodesFromFile(String filePath);

  /// خواندن آیتم‌های برداشت از فایل (Excel یا CSV)
  ///
  /// ستون‌های پشتیبانی‌شده:
  /// - barcode (الزامی): barcode, بارکد, کد بارکد, کد
  /// - location_warehouse: م.ف.ا, مکان_فیزیکی_انبار, location_warehouse
  /// - location_hall: م.ف.سالن, مکان_سالن, location_hall
  /// - color: رنگ, color
  /// - product_code: کد محصول, product_code, sku
  /// - product_name: عنوان محصول, نام محصول, product_name
  /// - quantity: تعداد, quantity, qty
  /// - gender: جنسیت, gender
  /// - design: طرح, design, pattern
  /// - size: سایز, size
  ///
  /// آیتم‌ها به‌صورت خودکار بر اساس م.ف.ا مرتب می‌شوند.
  Future<List<PickingItem>> readPickingItemsFromFile(String filePath);

  /// نوشتن بارکدها به فایل Excel
  Future<String?> writeBarcodesToFile(List<Barcode> barcodes);

  /// نوشتن اسکن‌ها به فایل Excel
  Future<String?> writeScansToFile(List<ScanRecord> scans);

  /// نوشتن گزارش نشست برداشت به فایل Excel
  Future<String?> writePickingSessionToFile({
    required String sessionName,
    required List<PickingItem> items,
  });
}
