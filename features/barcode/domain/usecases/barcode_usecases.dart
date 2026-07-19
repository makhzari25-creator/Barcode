import '../../../../core/errors/failures.dart';
import '../../domain/entities/barcode.dart';
import '../../domain/repositories/barcode_repository.dart';

/// Use Case: بررسی اعتبار بارکد
class IsBarcodeValidUseCase {
  final BarcodeRepository _repository;

  IsBarcodeValidUseCase(this._repository);

  Future<bool> call(String code) => _repository.isBarcodeValid(code);
}

/// Use Case: دریافت بارکد با کد
class GetBarcodeUseCase {
  final BarcodeRepository _repository;

  GetBarcodeUseCase(this._repository);

  Future<Barcode?> call(String code) => _repository.getBarcode(code);
}

/// Use Case: دریافت تعداد بارکدها
class GetBarcodeCountUseCase {
  final BarcodeRepository _repository;

  GetBarcodeCountUseCase(this._repository);

  Future<int> call() => _repository.getBarcodeCount();
}

/// Use Case: دریافت همه بارکدها
class GetAllBarcodesUseCase {
  final BarcodeRepository _repository;

  GetAllBarcodesUseCase(this._repository);

  Future<List<Barcode>> call({int limit = 100, int offset = 0}) {
    return _repository.getAllBarcodes(limit: limit, offset: offset);
  }
}

/// Use Case: افزودن بارکد
class AddBarcodeUseCase {
  final BarcodeRepository _repository;

  AddBarcodeUseCase(this._repository);

  Future<Either<Failure, Barcode>> call(Barcode barcode) {
    return _repository.addBarcode(barcode);
  }
}

/// Use Case: جایگزینی همه بارکدها
class ReplaceAllBarcodesUseCase {
  final BarcodeRepository _repository;

  ReplaceAllBarcodesUseCase(this._repository);

  Future<Either<Failure, int>> call(List<Barcode> barcodes) {
    return _repository.replaceAllBarcodes(barcodes);
  }
}

/// Use Case: افزودن لیست بارکدها
class AddBarcodesUseCase {
  final BarcodeRepository _repository;

  AddBarcodesUseCase(this._repository);

  Future<Either<Failure, int>> call(List<Barcode> barcodes) {
    return _repository.addBarcodes(barcodes);
  }
}

/// Use Case: حذف همه بارکدها
class DeleteAllBarcodesUseCase {
  final BarcodeRepository _repository;

  DeleteAllBarcodesUseCase(this._repository);

  Future<Either<Failure, bool>> call() => _repository.deleteAllBarcodes();
}

/// Use Case: بارگذاری مجدد Bloom Filter
class ReloadBloomFilterUseCase {
  final BarcodeRepository _repository;

  ReloadBloomFilterUseCase(this._repository);

  Future<void> call() => _repository.reloadBloomFilter();
}
