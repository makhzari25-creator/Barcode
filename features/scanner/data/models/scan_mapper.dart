import 'package:drift/drift.dart';

import '../../../barcode/data/datasources/app_database.dart' as db;
import '../../domain/entities/scan_record.dart';

/// Mapper برای تبدیل ردیف اسکن به Entity
class ScanMapper {
  ScanMapper._();

  /// تبدیل ScanRow (DB) به ScanRecord (Entity)
  static ScanRecord toEntity(db.ScanRow row) {
    return ScanRecord(
      id: row.id,
      userId: row.userId,
      barcode: row.barcode,
      status: ScanStatus.fromString(row.status),
      scannedAt: row.scannedAt,
      dateOnly: row.dateOnly,
      timeOnly: row.timeOnly,
      deviceInfo: row.deviceInfo,
    );
  }

  /// تبدیل لیست ردیف‌ها به Entity
  static List<ScanRecord> toEntityList(List<db.ScanRow> rows) {
    return rows.map(toEntity).toList();
  }

  /// ایجاد ScansCompanion برای Insert
  static db.ScansCompanion toCompanion({
    required int userId,
    required String barcode,
    required ScanStatus status,
    required DateTime scannedAt,
    required String dateOnly,
    required String timeOnly,
    String? deviceInfo,
  }) {
    return db.ScansCompanion.insert(
      userId: userId,
      barcode: barcode,
      status: status.toDbValue(),
      scannedAt: Value(scannedAt),
      dateOnly: dateOnly,
      timeOnly: timeOnly,
      deviceInfo: deviceInfo != null ? Value(deviceInfo) : const Value.absent(),
    );
  }
}

/// Mapper برای آمار
class ScanStatsMapper {
  ScanStatsMapper._();

  static ScanStats toEntity(db.ScanStatsData data) {
    return ScanStats(
      total: data.total,
      valid: data.valid,
      invalid: data.invalid,
      duplicate: data.duplicate,
    );
  }
}
