import '../../../../core/errors/failures.dart';
import '../../../barcode/data/datasources/app_database.dart' as db;
import '../../domain/entities/scan_record.dart';
import '../../domain/repositories/scan_repository.dart';
import '../models/scan_mapper.dart';

/// پیاده‌سازی ScanRepository با Drift
class ScanRepositoryImpl implements ScanRepository {
  final db.AppDatabase _database;

  ScanRepositoryImpl(this._database);

  @override
  Future<Either<Failure, ScanRecord>> saveScan(ScanRecord scan) async {
    try {
      final companion = ScanMapper.toCompanion(
        userId: scan.userId,
        barcode: scan.barcode,
        status: scan.status,
        scannedAt: scan.scannedAt,
        dateOnly: scan.dateOnly,
        timeOnly: scan.timeOnly,
        deviceInfo: scan.deviceInfo,
      );

      final id = await _database.insertScan(companion);
      return Right(scan.copyWith(id: id));
    } catch (e) {
      return Left(DatabaseFailure(message: 'خطا در ثبت اسکن: $e'));
    }
  }

  @override
  Future<bool> isBarcodeScannedToday(String barcode, String dateOnly) {
    return _database.hasBarcodeBeenScannedToday(barcode, dateOnly);
  }

  @override
  Future<ScanRecord?> getLastScanForBarcode(String barcode) async {
    final row = await _database.getLastScanForBarcode(barcode);
    return row != null ? ScanMapper.toEntity(row) : null;
  }

  @override
  Future<Either<Failure, List<ScanRecord>>> getScans({
    String? startDate,
    String? endDate,
    int? userId,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final rows = await _database.getScans(
        startDate: startDate,
        endDate: endDate,
        userId: userId,
        limit: limit,
        offset: offset,
      );
      return Right(ScanMapper.toEntityList(rows));
    } catch (e) {
      return Left(DatabaseFailure(message: 'خطا در دریافت اسکن‌ها: $e'));
    }
  }

  @override
  Future<Either<Failure, ScanStats>> getScanStats({
    String? startDate,
    String? endDate,
    int? userId,
  }) async {
    try {
      final data = await _database.getScanStats(
        startDate: startDate,
        endDate: endDate,
        userId: userId,
      );
      return Right(ScanStatsMapper.toEntity(data));
    } catch (e) {
      return Left(DatabaseFailure(message: 'خطا در دریافت آمار: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> deleteScansBeforeDate(String dateOnly) async {
    try {
      final count = await _database.deleteScansBeforeDate(dateOnly);
      return Right(count);
    } catch (e) {
      return Left(DatabaseFailure(message: 'خطا در حذف اسکن‌ها: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteAllScans() async {
    try {
      await _database.deleteAllScans();
      return const Right(true);
    } catch (e) {
      return Left(DatabaseFailure(message: 'خطا در حذف اسکن‌ها: $e'));
    }
  }
}
