import '../../../barcode/domain/entities/barcode.dart';

/// وضعیت نتیجه اسکن
enum ScanStatus {
  valid('معتبر'),
  invalid('نامعتبر'),
  duplicate('تکراری');

  final String label;
  const ScanStatus(this.label);

  static ScanStatus fromString(String value) {
    return switch (value) {
      'valid' => ScanStatus.valid,
      'invalid' => ScanStatus.invalid,
      'duplicate' => ScanStatus.duplicate,
      _ => ScanStatus.invalid,
    };
  }

  String toDbValue() => name;
}

/// موجودیت اسکن ثبت‌شده
class ScanRecord {
  final int? id;
  final int userId;
  final String barcode;
  final ScanStatus status;
  final DateTime scannedAt;
  final String dateOnly;
  final String timeOnly;
  final String? deviceInfo;

  const ScanRecord({
    this.id,
    required this.userId,
    required this.barcode,
    required this.status,
    required this.scannedAt,
    required this.dateOnly,
    required this.timeOnly,
    this.deviceInfo,
  });

  ScanRecord copyWith({
    int? id,
    int? userId,
    String? barcode,
    ScanStatus? status,
    DateTime? scannedAt,
    String? dateOnly,
    String? timeOnly,
    String? deviceInfo,
  }) {
    return ScanRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      barcode: barcode ?? this.barcode,
      status: status ?? this.status,
      scannedAt: scannedAt ?? this.scannedAt,
      dateOnly: dateOnly ?? this.dateOnly,
      timeOnly: timeOnly ?? this.timeOnly,
      deviceInfo: deviceInfo ?? this.deviceInfo,
    );
  }
}

/// موجودیت نتیجه اعتبارسنجی بارکد
class ValidationResult {
  final ScanStatus status;
  final Barcode? barcode;
  final ScanRecord? previousScan;

  const ValidationResult({
    required this.status,
    this.barcode,
    this.previousScan,
  });

  bool get isValid => status == ScanStatus.valid;
  bool get isInvalid => status == ScanStatus.invalid;
  bool get isDuplicate => status == ScanStatus.duplicate;
}

/// موجودیت آمار اسکن
class ScanStats {
  final int total;
  final int valid;
  final int invalid;
  final int duplicate;

  const ScanStats({
    required this.total,
    required this.valid,
    required this.invalid,
    required this.duplicate,
  });

  factory ScanStats.empty() => const ScanStats(total: 0, valid: 0, invalid: 0, duplicate: 0);

  ScanStats copyWith({
    int? total,
    int? valid,
    int? invalid,
    int? duplicate,
  }) {
    return ScanStats(
      total: total ?? this.total,
      valid: valid ?? this.valid,
      invalid: invalid ?? this.invalid,
      duplicate: duplicate ?? this.duplicate,
    );
  }
}

/// موجودیت دسته Import
class ImportBatch {
  final int? id;
  final int userId;
  final String fileName;
  final int totalRecords;
  final DateTime importedAt;
  final bool replaced;

  const ImportBatch({
    this.id,
    required this.userId,
    required this.fileName,
    required this.totalRecords,
    required this.importedAt,
    required this.replaced,
  });
}

/// نتیجه Import (legacy - use ImportExportRepository's ImportResult)
class BarcodeImportResult {
  final int totalRecords;
  final int importedCount;
  final int skippedCount;
  final int errorCount;
  final String fileName;

  const BarcodeImportResult({
    required this.totalRecords,
    required this.importedCount,
    required this.skippedCount,
    required this.errorCount,
    required this.fileName,
  });

  factory BarcodeImportResult.empty(String fileName) => BarcodeImportResult(
        totalRecords: 0,
        importedCount: 0,
        skippedCount: 0,
        errorCount: 0,
        fileName: fileName,
      );
}
