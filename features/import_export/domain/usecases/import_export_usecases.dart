import '../../../../core/errors/failures.dart';
import '../../domain/entities/import_export_entities.dart';
import '../../domain/repositories/import_export_repository.dart';
import '../../../barcode/domain/repositories/barcode_repository.dart';
import '../../../scanner/domain/repositories/scan_repository.dart';

/// Use Case: Import بارکدها از فایل Excel/CSV
class ImportBarcodesUseCase {
  final ImportExportRepository _importExportRepository;
  final BarcodeRepository _barcodeRepository;

  ImportBarcodesUseCase(this._importExportRepository, this._barcodeRepository);

  /// خواندن فایل و Import بارکدها
  /// [mode]: 'add' برای افزودن، 'replace' برای جایگزینی
  Future<ImportResult> call({
    required String filePath,
    required ImportMode mode,
    int? userId,
  }) async {
    // Step 1: Read barcodes from file
    final barcodes = await _importExportRepository.readBarcodesFromFile(filePath);

    if (barcodes.isEmpty) {
      return ImportResult(
        totalRecords: 0,
        importedCount: 0,
        skippedCount: 0,
        errorCount: 0,
        fileName: filePath.split('/').last,
      );
    }

    // Step 2: Import based on mode
    Either<Failure, int> result;
    if (mode == ImportMode.replace) {
      result = await _barcodeRepository.replaceAllBarcodes(barcodes);
    } else {
      result = await _barcodeRepository.addBarcodes(barcodes);
    }

    // Step 3: Build result
    return result.fold(
      (failure) => ImportResult(
        totalRecords: barcodes.length,
        importedCount: 0,
        skippedCount: 0,
        errorCount: barcodes.length,
        fileName: filePath.split('/').last,
        error: failure.message,
      ),
      (importedCount) => ImportResult(
        totalRecords: barcodes.length,
        importedCount: importedCount,
        skippedCount: barcodes.length - importedCount,
        errorCount: 0,
        fileName: filePath.split('/').last,
      ),
    );
  }
}

/// Use Case: Export بارکدها به Excel
class ExportBarcodesUseCase {
  final ImportExportRepository _importExportRepository;
  final BarcodeRepository _barcodeRepository;

  ExportBarcodesUseCase(this._importExportRepository, this._barcodeRepository);

  Future<String?> call() async {
    final barcodes = await _barcodeRepository.getAllBarcodes(limit: 1000000);
    return _importExportRepository.writeBarcodesToFile(barcodes);
  }
}

/// Use Case: Export اسکن‌ها به Excel
class ExportScansUseCase {
  final ImportExportRepository _importExportRepository;
  final ScanRepository _scanRepository;

  ExportScansUseCase(this._importExportRepository, this._scanRepository);

  Future<String?> call({
    String? startDate,
    String? endDate,
    int? userId,
  }) async {
    final result = await _scanRepository.getScans(
      startDate: startDate,
      endDate: endDate,
      userId: userId,
      limit: 1000000,
    );

    return result.fold(
      (failure) => null,
      (scans) => _importExportRepository.writeScansToFile(scans),
    );
  }
}
