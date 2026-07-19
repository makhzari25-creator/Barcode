// lib/features/picking/data/repositories/picking_repository_impl.dart
//
// پیاده‌سازی PickingRepository با Drift
//

import 'package:drift/drift.dart';

import '../../../../core/errors/failures.dart';
import '../../../barcode/data/datasources/app_database.dart' as db;
import '../../domain/entities/picking_item.dart';
import '../../domain/entities/picking_session.dart';
import '../../domain/repositories/picking_repository.dart';
import '../models/picking_mapper.dart';

class PickingRepositoryImpl implements PickingRepository {
  final db.AppDatabase _database;

  PickingRepositoryImpl(this._database);

  // ============ Sessions ============

  @override
  Future<Either<Failure, PickingSession>> createSession({
    required int userId,
    required String name,
    required String sourceFile,
    required List<PickingItem> items,
  }) async {
    try {
      // تراکنش برای ایجاد نشست و آیتم‌ها به‌صورت اتمیک
      final sessionId = await _database.transaction(() async {
        // ۱. ایجاد نشست
        final session = PickingSession(
          userId: userId,
          name: name,
          sourceFile: sourceFile,
          totalItems: items.length,
          startedAt: DateTime.now(),
        );

        final id = await _database.insertPickingSession(
          PickingSessionMapper.toInsertCompanion(session),
        );

        // ۲. درج آیتم‌ها
        final companions = items
            .map((item) => item.copyWith(sessionId: id, createdAt: DateTime.now()))
            .map(PickingItemMapper.toInsertCompanion)
            .toList();

        if (companions.isNotEmpty) {
          await _database.insertPickingItemsBatch(companions);
        }

        return id;
      });

      // دریافت نشست ایجاد‌شده
      final row = await _database.getPickingSessionById(sessionId);
      if (row == null) {
        return const Left(DatabaseFailure(message: 'نشست ایجاد نشد'));
      }

      return Right(PickingSessionMapper.toEntity(row));
    } catch (e) {
      return Left(DatabaseFailure(message: 'خطا در ایجاد نشست: $e'));
    }
  }

  @override
  Future<Either<Failure, PickingSession>> getSession(int id) async {
    try {
      final row = await _database.getPickingSessionById(id);
      if (row == null) {
        return const Left(DatabaseFailure(message: 'نشست پیدا نشد'));
      }
      return Right(PickingSessionMapper.toEntity(row));
    } catch (e) {
      return Left(DatabaseFailure(message: 'خطا در دریافت نشست: $e'));
    }
  }

  @override
  Future<PickingSession?> getActiveSession(int userId) async {
    try {
      final row = await _database.getActivePickingSession(userId);
      return row != null ? PickingSessionMapper.toEntity(row) : null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Either<Failure, List<PickingSession>>> getUserSessions(
    int userId, {
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final rows = await _database.getPickingSessionsByUser(
        userId,
        limit: limit,
        offset: offset,
      );
      return Right(PickingSessionMapper.toEntityList(rows));
    } catch (e) {
      return Left(DatabaseFailure(message: 'خطا در دریافت نشست‌ها: $e'));
    }
  }

  @override
  Future<Either<Failure, List<PickingSession>>> getAllSessions({
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final rows = await _database.getAllPickingSessions(
        limit: limit,
        offset: offset,
      );
      return Right(PickingSessionMapper.toEntityList(rows));
    } catch (e) {
      return Left(DatabaseFailure(message: 'خطا در دریافت نشست‌ها: $e'));
    }
  }

  @override
  Future<Either<Failure, PickingSession>> completeSession(int sessionId) async {
    try {
      await _database.updatePickingSession(
        db.PickingSessionsCompanion(
          id: Value(sessionId),
          status: const Value('completed'),
          completedAt: Value(DateTime.now()),
        ),
      );

      // Mark all pending items as skipped
      final items = await _database.getPickingItemsBySession(sessionId);
      for (final item in items) {
        if (item.status == 'pending') {
          await _database.updatePickingItem(
            db.PickingItemsCompanion(
              id: Value(item.id),
              status: const Value('skipped'),
            ),
          );
        }
      }

      final row = await _database.getPickingSessionById(sessionId);
      if (row == null) {
        return const Left(DatabaseFailure(message: 'نشست پیدا نشد'));
      }

      return Right(PickingSessionMapper.toEntity(row));
    } catch (e) {
      return Left(DatabaseFailure(message: 'خطا در تکمیل نشست: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> cancelSession(int sessionId) async {
    try {
      await _database.updatePickingSession(
        db.PickingSessionsCompanion(
          id: Value(sessionId),
          status: const Value('cancelled'),
          completedAt: Value(DateTime.now()),
        ),
      );
      return const Right(true);
    } catch (e) {
      return Left(DatabaseFailure(message: 'خطا در لغو نشست: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteSession(int sessionId) async {
    try {
      await _database.transaction(() async {
        await _database.deletePickingItemsBySession(sessionId);
        await _database.deletePickingSession(sessionId);
      });
      return const Right(true);
    } catch (e) {
      return Left(DatabaseFailure(message: 'خطا در حذف نشست: $e'));
    }
  }

  // ============ Items ============

  @override
  Future<Either<Failure, List<PickingItem>>> getSessionItems(
    int sessionId,
  ) async {
    try {
      final rows = await _database.getPickingItemsBySession(sessionId);
      return Right(PickingItemMapper.toEntityList(rows));
    } catch (e) {
      return Left(DatabaseFailure(message: 'خطا در دریافت آیتم‌ها: $e'));
    }
  }

  @override
  Future<Either<Failure, PickingItem>> getItem(int itemId) async {
    try {
      final row = await _database.getPickingItemById(itemId);
      if (row == null) {
        return const Left(DatabaseFailure(message: 'آیتم پیدا نشد'));
      }
      return Right(PickingItemMapper.toEntity(row));
    } catch (e) {
      return Left(DatabaseFailure(message: 'خطا در دریافت آیتم: $e'));
    }
  }

  @override
  Future<Either<Failure, PickingItem>> updateItem(PickingItem item) async {
    try {
      await _database.updatePickingItem(
        PickingItemMapper.toUpdateCompanion(item),
      );

      // به‌روزرسانی شمارنده‌های نشست
      if (item.sessionId != null) {
        await _updateSessionCounts(item.sessionId!);
      }

      return Right(item);
    } catch (e) {
      return Left(DatabaseFailure(message: 'خطا در به‌روزرسانی آیتم: $e'));
    }
  }

  @override
  Future<PickingItem?> findItemByBarcode(
    int sessionId,
    String barcode,
  ) async {
    try {
      final row = await _database.getPickingItemByBarcode(sessionId, barcode);
      return row != null ? PickingItemMapper.toEntity(row) : null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<PickingItem?> getNextPendingItem(int sessionId) async {
    try {
      final row = await _database.getFirstPendingPickingItem(sessionId);
      return row != null ? PickingItemMapper.toEntity(row) : null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Either<Failure, PickingSessionStats>> getSessionStats(
    int sessionId,
  ) async {
    try {
      final items = await _database.getPickingItemsBySession(sessionId);
      final stats = PickingSessionStats.fromItems(
        PickingItemMapper.toEntityList(items),
      );
      return Right(stats);
    } catch (e) {
      return Left(DatabaseFailure(message: 'خطا در دریافت آمار: $e'));
    }
  }

  @override
  Future<int> getPendingCount(int sessionId) async {
    try {
      return await _database.getPendingPickingItemsCount(sessionId);
    } catch (_) {
      return 0;
    }
  }

  /// به‌روزرسانی شمارنده‌های picked و skipped در نشست
  Future<void> _updateSessionCounts(int sessionId) async {
    try {
      final items = await _database.getPickingItemsBySession(sessionId);
      int picked = 0;
      int skipped = 0;
      for (final item in items) {
        if (item.status == 'picked') {
          picked++;
        } else if (item.status == 'skipped' || item.status == 'wrongBarcode') {
          skipped++;
        }
      }
      await _database.updatePickingSession(
        db.PickingSessionsCompanion(
          id: Value(sessionId),
          pickedCount: Value(picked),
          skippedCount: Value(skipped),
        ),
      );
    } catch (_) {
      // ignore count update errors
    }
  }
}
