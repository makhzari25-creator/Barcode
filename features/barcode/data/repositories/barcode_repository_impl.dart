import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/barcode.dart';
import '../../domain/repositories/barcode_repository.dart';
import '../datasources/app_database.dart' as db;
import '../datasources/bloom_filter.dart';
import '../models/barcode_mapper.dart';

/// پیاده‌سازی BarcodeRepository با Drift و Bloom Filter
class BarcodeRepositoryImpl implements BarcodeRepository {
  final db.AppDatabase _database;
  BloomFilter? _bloomFilter;
  final Set<String> _cache = {};
  bool _isInitialized = false;

  BarcodeRepositoryImpl(this._database);

  /// مقداردهی اولیه - بارگذاری Bloom Filter از دیتابیس
  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;

    try {
      // Try to load cached bloom filter from file
      final bloomFile = await _getBloomFile();
      if (await bloomFile.exists()) {
        final bytes = await bloomFile.readAsBytes();
        _bloomFilter = BloomFilter.fromBytes(
          bytes,
        );
      } else {
        _bloomFilter = BloomFilter();
      }

      // Load all codes into cache (HashSet in memory)
      final codes = await _database.getAllBarcodeCodes();
      _cache.addAll(codes);

      // Rebuild bloom filter to ensure consistency
      _bloomFilter!.clear();
      _bloomFilter!.addAll(codes);

      await _saveBloomFilter();

      _isInitialized = true;
    } catch (e) {
      // Fallback: just initialize empty
      _bloomFilter ??= BloomFilter();
      _isInitialized = true;
    }
  }

  Future<File> _getBloomFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File(p.join(dir.path, 'bloom_filter.bin'));
  }

  Future<void> _saveBloomFilter() async {
    if (_bloomFilter == null) return;
    try {
      final file = await _getBloomFile();
      await file.writeAsBytes(_bloomFilter!.toBytes());
    } catch (_) {
      // Ignore save errors
    }
  }

  @override
  Future<bool> isBarcodeValid(String code) async {
    await _ensureInitialized();

    // Step 1: Check Bloom Filter (O(1)) - quick rejection
    if (!_bloomFilter!.contains(code)) {
      return false; // Definitely not in list
    }

    // Step 2: Check HashSet in memory (O(1)) - confirms membership
    if (_cache.contains(code)) {
      return true;
    }

    // Step 3: Fallback to database (in case cache is stale)
    final row = await _database.getBarcodeByCode(code);
    if (row != null) {
      _cache.add(code);
      return true;
    }
    return false;
  }

  @override
  Future<Barcode?> getBarcode(String code) async {
    final row = await _database.getBarcodeByCode(code);
    return row != null ? BarcodeMapper.toEntity(row) : null;
  }

  @override
  Future<int> getBarcodeCount() {
    return _database.getBarcodeCount();
  }

  @override
  Future<List<Barcode>> getAllBarcodes({int limit = 100, int offset = 0}) async {
    final rows = await _database.getAllBarcodes(limit: limit, offset: offset);
    return BarcodeMapper.toEntityList(rows);
  }

  @override
  Future<Either<Failure, Barcode>> addBarcode(Barcode barcode) async {
    try {
      await _database.insertBarcode(db.BarcodesCompanion.insert(
        code: barcode.code,
        productName: Value(barcode.productName),
        productCode: Value(barcode.productCode),
        category: Value(barcode.category),
        size: Value(barcode.size),
        color: Value(barcode.color),
        importedBatch: Value(barcode.importedBatch),
        createdAt: Value(barcode.createdAt),
      ));

      // Update cache
      _cache.add(barcode.code);
      _bloomFilter?.add(barcode.code);
      await _saveBloomFilter();

      return Right(barcode);
    } catch (e) {
      return Left(DatabaseFailure(message: 'خطا در افزودن بارکد: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> replaceAllBarcodes(List<Barcode> barcodes) async {
    try {
      // Delete all existing barcodes
      await _database.deleteAllBarcodes();

      // Clear cache and bloom filter
      _cache.clear();
      _bloomFilter?.clear();

      // Insert all new barcodes
      final companions = barcodes
          .map((b) => db.BarcodesCompanion.insert(
                code: b.code,
                productName: Value(b.productName),
                productCode: Value(b.productCode),
                category: Value(b.category),
                size: Value(b.size),
                color: Value(b.color),
                createdAt: Value(b.createdAt),
              ))
          .toList();

      // Insert in batches of 1000 for performance
      for (int i = 0; i < companions.length; i += 1000) {
        final batch = companions.sublist(
          i,
          (i + 1000 > companions.length) ? companions.length : i + 1000,
        );
        await _database.insertBarcodesBatch(batch);
      }

      // Rebuild cache and bloom filter
      final codes = barcodes.map((b) => b.code).toSet();
      _cache.addAll(codes);
      _bloomFilter?.addAll(codes);
      await _saveBloomFilter();

      return Right(barcodes.length);
    } catch (e) {
      return Left(DatabaseFailure(message: 'خطا در جایگزینی بارکدها: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> addBarcodes(List<Barcode> barcodes) async {
    try {
      int addedCount = 0;
      final companions = <db.BarcodesCompanion>[];

      for (final b in barcodes) {
        if (!_cache.contains(b.code)) {
          companions.add(db.BarcodesCompanion.insert(
            code: b.code,
            productName: Value(b.productName),
            productCode: Value(b.productCode),
            category: Value(b.category),
            size: Value(b.size),
            color: Value(b.color),
            createdAt: Value(b.createdAt),
          ));
          _cache.add(b.code);
          _bloomFilter?.add(b.code);
          addedCount++;
        }
      }

      // Insert in batches of 1000
      for (int i = 0; i < companions.length; i += 1000) {
        final batch = companions.sublist(
          i,
          (i + 1000 > companions.length) ? companions.length : i + 1000,
        );
        await _database.insertBarcodesBatch(batch);
      }

      await _saveBloomFilter();

      return Right(addedCount);
    } catch (e) {
      return Left(DatabaseFailure(message: 'خطا در افزودن بارکدها: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteAllBarcodes() async {
    try {
      await _database.deleteAllBarcodes();
      _cache.clear();
      _bloomFilter?.clear();
      await _saveBloomFilter();
      return const Right(true);
    } catch (e) {
      return Left(DatabaseFailure(message: 'خطا در حذف بارکدها: $e'));
    }
  }

  @override
  Future<List<String>> getAllBarcodeCodes() async {
    return _database.getAllBarcodeCodes();
  }

  @override
  Future<void> reloadBloomFilter() async {
    _isInitialized = false;
    _cache.clear();
    await _ensureInitialized();
  }
}
