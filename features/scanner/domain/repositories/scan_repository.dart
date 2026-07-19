import '../../../../core/errors/failures.dart';
import '../../domain/entities/scan_record.dart';

/// قرارداد Repository اسکن‌ها
abstract class ScanRepository {
  /// ثبت یک اسکن
  Future<Either<Failure, ScanRecord>> saveScan(ScanRecord scan);

  /// بررسی اینکه آیا بارکد قبلاً اسکن شده
  Future<bool> isBarcodeScannedToday(String barcode, String dateOnly);

  /// دریافت آخرین اسکن یک بارکد
  Future<ScanRecord?> getLastScanForBarcode(String barcode);

  /// دریافت اسکن‌ها با فیلتر
  Future<Either<Failure, List<ScanRecord>>> getScans({
    String? startDate,
    String? endDate,
    int? userId,
    int limit = 100,
    int offset = 0,
  });

  /// دریافت آمار اسکن
  Future<Either<Failure, ScanStats>> getScanStats({
    String? startDate,
    String? endDate,
    int? userId,
  });

  /// حذف اسکن‌های قبل از تاریخ مشخص
  Future<Either<Failure, int>> deleteScansBeforeDate(String dateOnly);

  /// حذف همه اسکن‌ها
  Future<Either<Failure, bool>> deleteAllScans();
}
