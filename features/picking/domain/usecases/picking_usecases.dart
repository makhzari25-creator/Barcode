// lib/features/picking/domain/usecases/picking_usecases.dart
//
// Use Caseهای سیستم برداشت
//

import 'package:drift/drift.dart' show Value;

import '../../../../core/errors/failures.dart';
import '../../domain/entities/picking_item.dart';
import '../../domain/entities/picking_session.dart';
import '../../domain/repositories/picking_repository.dart';

/// Use Case: ایجاد نشست برداشت
class CreatePickingSessionUseCase {
  final PickingRepository _repository;

  CreatePickingSessionUseCase(this._repository);

  Future<Either<Failure, PickingSession>> call({
    required int userId,
    required String name,
    required String sourceFile,
    required List<PickingItem> items,
  }) {
    return _repository.createSession(
      userId: userId,
      name: name,
      sourceFile: sourceFile,
      items: items,
    );
  }
}

/// Use Case: دریافت نشست فعال
class GetActiveSessionUseCase {
  final PickingRepository _repository;

  GetActiveSessionUseCase(this._repository);

  Future<PickingSession?> call(int userId) {
    return _repository.getActiveSession(userId);
  }
}

/// Use Case: دریافت نشست‌های کاربر
class GetUserSessionsUseCase {
  final PickingRepository _repository;

  GetUserSessionsUseCase(this._repository);

  Future<Either<Failure, List<PickingSession>>> call(
    int userId, {
    int limit = 50,
    int offset = 0,
  }) {
    return _repository.getUserSessions(
      userId,
      limit: limit,
      offset: offset,
    );
  }
}

/// Use Case: دریافت همه نشست‌ها (برای مدیر)
class GetAllSessionsUseCase {
  final PickingRepository _repository;

  GetAllSessionsUseCase(this._repository);

  Future<Either<Failure, List<PickingSession>>> call({
    int limit = 100,
    int offset = 0,
  }) {
    return _repository.getAllSessions(limit: limit, offset: offset);
  }
}

/// Use Case: دریافت آیتم‌های نشست
class GetSessionItemsUseCase {
  final PickingRepository _repository;

  GetSessionItemsUseCase(this._repository);

  Future<Either<Failure, List<PickingItem>>> call(int sessionId) {
    return _repository.getSessionItems(sessionId);
  }
}

/// Use Case: دریافت آیتم بعدی pending
class GetNextPendingItemUseCase {
  final PickingRepository _repository;

  GetNextPendingItemUseCase(this._repository);

  Future<PickingItem?> call(int sessionId) {
    return _repository.getNextPendingItem(sessionId);
  }
}

/// Use Case: اعتبارسنجی بارکد اسکن‌شده در نشست برداشت
///
/// این Use Case قلب منطق برداشت است:
/// ۱. اگر بارکد با آیتم فعلی تطابق داشت → correct
/// ۲. اگر بارکد با آیتم دیگری در نشست تطابق داشت → wrongItem
/// ۳. اگر بارکد در نشست نبود → notInList
/// ۴. اگر آیتم قبلاً picked شده → alreadyPicked
class ValidatePickingBarcodeUseCase {
  final PickingRepository _repository;

  ValidatePickingBarcodeUseCase(this._repository);

  Future<PickingValidationResult> call({
    required int sessionId,
    required String scannedBarcode,
    required PickingItem? currentItem,
  }) async {
    // جستجوی بارکد در نشست
    final matchedItem =
        await _repository.findItemByBarcode(sessionId, scannedBarcode);

    // اگر بارکد در لیست نبود
    if (matchedItem == null) {
      return PickingValidationResult(
        status: PickingValidationStatus.notInList,
        expectedItem: currentItem,
      );
    }

    // اگر آیتم قبلاً برداشت شده
    if (matchedItem.isPicked) {
      return PickingValidationResult(
        status: PickingValidationStatus.alreadyPicked,
        matchedItem: matchedItem,
        expectedItem: currentItem,
      );
    }

    // اگر با آیتم فعلی تطابق دارد
    if (currentItem != null && matchedItem.id == currentItem.id) {
      return PickingValidationResult(
        status: PickingValidationStatus.correct,
        matchedItem: matchedItem,
        expectedItem: currentItem,
      );
    }

    // در غیر این صورت، آیتم دیگری در لیست بوده
    return PickingValidationResult(
      status: PickingValidationStatus.wrongItem,
      matchedItem: matchedItem,
      expectedItem: currentItem,
    );
  }
}

/// Use Case: ثبت موفقیت برداشت آیتم
class PickItemUseCase {
  final PickingRepository _repository;

  PickItemUseCase(this._repository);

  Future<Either<Failure, PickingItem>> call(
    PickingItem item, {
    String? scannedBarcode,
  }) async {
    final updated = item.copyWith(
      status: PickingStatus.picked,
      scannedBarcode: scannedBarcode ?? item.barcode,
      pickedAt: DateTime.now(),
    );
    return _repository.updateItem(updated);
  }
}

/// Use Case: نادیده گرفتن آیتم (Skip)
class SkipItemUseCase {
  final PickingRepository _repository;

  SkipItemUseCase(this._repository);

  Future<Either<Failure, PickingItem>> call(PickingItem item) async {
    final updated = item.copyWith(status: PickingStatus.skipped);
    return _repository.updateItem(updated);
  }
}

/// Use Case: ثبت بارکد اشتباه
class MarkWrongBarcodeUseCase {
  final PickingRepository _repository;

  MarkWrongBarcodeUseCase(this._repository);

  Future<Either<Failure, PickingItem>> call(
    PickingItem item, {
    required String wrongBarcode,
  }) async {
    final updated = item.copyWith(
      status: PickingStatus.wrongBarcode,
      scannedBarcode: wrongBarcode,
    );
    return _repository.updateItem(updated);
  }
}

/// Use Case: تکمیل نشست
class CompleteSessionUseCase {
  final PickingRepository _repository;

  CompleteSessionUseCase(this._repository);

  Future<Either<Failure, PickingSession>> call(int sessionId) {
    return _repository.completeSession(sessionId);
  }
}

/// Use Case: لغو نشست
class CancelSessionUseCase {
  final PickingRepository _repository;

  CancelSessionUseCase(this._repository);

  Future<Either<Failure, bool>> call(int sessionId) {
    return _repository.cancelSession(sessionId);
  }
}

/// Use Case: حذف نشست
class DeleteSessionUseCase {
  final PickingRepository _repository;

  DeleteSessionUseCase(this._repository);

  Future<Either<Failure, bool>> call(int sessionId) {
    return _repository.deleteSession(sessionId);
  }
}

/// Use Case: دریافت آمار نشست
class GetSessionStatsUseCase {
  final PickingRepository _repository;

  GetSessionStatsUseCase(this._repository);

  Future<Either<Failure, PickingSessionStats>> call(int sessionId) {
    return _repository.getSessionStats(sessionId);
  }
}
