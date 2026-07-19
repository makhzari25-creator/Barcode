// lib/features/picking/domain/repositories/picking_repository.dart
//
// قرارداد Repository برای مدیریت نشست‌ها و آیتم‌های برداشت
//

import '../../../../core/errors/failures.dart';
import '../../domain/entities/picking_item.dart';
import '../../domain/entities/picking_session.dart';

abstract class PickingRepository {
  // ============ Sessions ============

  /// ایجاد نشست برداشت جدید
  Future<Either<Failure, PickingSession>> createSession({
    required int userId,
    required String name,
    required String sourceFile,
    required List<PickingItem> items,
  });

  /// دریافت نشست با شناسه
  Future<Either<Failure, PickingSession>> getSession(int id);

  /// دریافت نشست فعال کاربر
  Future<PickingSession?> getActiveSession(int userId);

  /// دریافت همه نشست‌های کاربر
  Future<Either<Failure, List<PickingSession>>> getUserSessions(
    int userId, {
    int limit = 50,
    int offset = 0,
  });

  /// دریافت همه نشست‌ها (برای مدیر)
  Future<Either<Failure, List<PickingSession>>> getAllSessions({
    int limit = 100,
    int offset = 0,
  });

  /// تکمیل نشست
  Future<Either<Failure, PickingSession>> completeSession(int sessionId);

  /// لغو نشست
  Future<Either<Failure, bool>> cancelSession(int sessionId);

  /// حذف نشست
  Future<Either<Failure, bool>> deleteSession(int sessionId);

  // ============ Items ============

  /// دریافت آیتم‌های نشست
  Future<Either<Failure, List<PickingItem>>> getSessionItems(int sessionId);

  /// دریافت آیتم با شناسه
  Future<Either<Failure, PickingItem>> getItem(int itemId);

  /// به‌روزرسانی آیتم (مثلاً پس از اسکن)
  Future<Either<Failure, PickingItem>> updateItem(PickingItem item);

  /// جستجوی آیتم با بارکد در نشست
  Future<PickingItem?> findItemByBarcode(int sessionId, String barcode);

  /// دریافت آیتم بعدی pending
  Future<PickingItem?> getNextPendingItem(int sessionId);

  /// دریافت آمار نشست
  Future<Either<Failure, PickingSessionStats>> getSessionStats(int sessionId);

  /// شمارش آیتم‌های pending
  Future<int> getPendingCount(int sessionId);
}
