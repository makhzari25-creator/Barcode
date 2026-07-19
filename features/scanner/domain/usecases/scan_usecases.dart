import '../../../../core/errors/failures.dart';
import '../../domain/entities/scan_record.dart';
import '../../domain/repositories/scan_repository.dart';
import '../../../barcode/domain/repositories/barcode_repository.dart';

/// Use Case: اعتبارسنجی بارکد
/// این Use Case مرکزی‌ترین منطق کسب‌وکار اپلیکیشن است
class ValidateBarcodeUseCase {
  final BarcodeRepository _barcodeRepository;
  final ScanRepository _scanRepository;

  ValidateBarcodeUseCase(this._barcodeRepository, this._scanRepository);

  /// اعتبارسنجی بارکد و برگرداندن نتیجه
  /// مراحل:
  /// ۱. بررسی وجود بارکد در لیست مجاز (Bloom Filter + SQLite)
  /// ۲. اگر موجود بود، بررسی اینکه قبلاً اسکن شده یا خیر
  /// ۳. برگرداندن نتیجه با وضعیت مناسب
  Future<ValidationResult> call(String code, {String? dateOnly}) async {
    final date = dateOnly ?? _todayDate();

    // Step 1: Check if barcode is in valid list
    final isValid = await _barcodeRepository.isBarcodeValid(code);

    if (!isValid) {
      return const ValidationResult(status: ScanStatus.invalid);
    }

    // Step 2: Get barcode details
    final barcode = await _barcodeRepository.getBarcode(code);

    // Step 3: Check if already scanned today
    final isDuplicate = await _scanRepository.isBarcodeScannedToday(code, date);

    if (isDuplicate) {
      final previousScan = await _scanRepository.getLastScanForBarcode(code);
      return ValidationResult(
        status: ScanStatus.duplicate,
        barcode: barcode,
        previousScan: previousScan,
      );
    }

    // Step 4: Valid and not scanned before
    return ValidationResult(
      status: ScanStatus.valid,
      barcode: barcode,
    );
  }

  String _todayDate() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }
}

/// Use Case: ثبت اسکن
class SaveScanUseCase {
  final ScanRepository _repository;

  SaveScanUseCase(this._repository);

  Future<Either<Failure, ScanRecord>> call(ScanRecord scan) {
    return _repository.saveScan(scan);
  }
}

/// Use Case: دریافت اسکن‌ها با فیلتر
class GetScansUseCase {
  final ScanRepository _repository;

  GetScansUseCase(this._repository);

  Future<Either<Failure, List<ScanRecord>>> call({
    String? startDate,
    String? endDate,
    int? userId,
    int limit = 100,
    int offset = 0,
  }) {
    return _repository.getScans(
      startDate: startDate,
      endDate: endDate,
      userId: userId,
      limit: limit,
      offset: offset,
    );
  }
}

/// Use Case: دریافت آمار اسکن
class GetScanStatsUseCase {
  final ScanRepository _repository;

  GetScanStatsUseCase(this._repository);

  Future<Either<Failure, ScanStats>> call({
    String? startDate,
    String? endDate,
    int? userId,
  }) {
    return _repository.getScanStats(
      startDate: startDate,
      endDate: endDate,
      userId: userId,
    );
  }
}

/// Use Case: پاک‌سازی اسکن‌های قدیمی
class ClearOldScansUseCase {
  final ScanRepository _repository;

  ClearOldScansUseCase(this._repository);

  Future<Either<Failure, int>> call(String dateOnly) {
    return _repository.deleteScansBeforeDate(dateOnly);
  }
}

/// Use Case: پاک‌سازی همه اسکن‌ها
class ClearAllScansUseCase {
  final ScanRepository _repository;

  ClearAllScansUseCase(this._repository);

  Future<Either<Failure, bool>> call() => _repository.deleteAllScans();
}
