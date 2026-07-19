// lib/features/picking/data/models/picking_mapper.dart
//
// تبدیل بین Drift rows و Entity
//

import 'package:drift/drift.dart';

import '../../../barcode/data/datasources/app_database.dart' as db;
import '../../domain/entities/picking_item.dart';
import '../../domain/entities/picking_session.dart';

/// Mapper برای PickingItem
class PickingItemMapper {
  PickingItemMapper._();

  /// تبدیل از Drift Row به Entity
  static PickingItem toEntity(db.PickingItemRow row) {
    return PickingItem(
      id: row.id,
      sessionId: row.sessionId,
      locationWarehouse: row.locationWarehouse,
      locationHall: row.locationHall,
      color: row.color,
      productCode: row.productCode,
      productName: row.productName,
      quantity: row.quantity,
      gender: row.gender,
      design: row.design,
      size: row.size,
      barcode: row.barcode,
      sortOrder: row.sortOrder,
      status: PickingStatus.fromString(row.status),
      scannedBarcode: row.scannedBarcode,
      pickedAt: row.pickedAt,
      createdAt: row.createdAt,
    );
  }

  /// تبدیل لیست
  static List<PickingItem> toEntityList(List<db.PickingItemRow> rows) {
    return rows.map(toEntity).toList();
  }

  /// تبدیل Entity به Drift Companion (برای Insert)
  static db.PickingItemsCompanion toInsertCompanion(PickingItem item) {
    return db.PickingItemsCompanion.insert(
      sessionId: item.sessionId!,
      locationWarehouse: item.locationWarehouse,
      locationHall: Value(item.locationHall),
      color: Value(item.color),
      productCode: Value(item.productCode),
      productName: Value(item.productName),
      quantity: Value(item.quantity),
      gender: Value(item.gender),
      design: Value(item.design),
      size: Value(item.size),
      barcode: item.barcode,
      sortOrder: Value(item.sortOrder),
      status: Value(item.status.toDbValue()),
      scannedBarcode: Value(item.scannedBarcode),
      pickedAt: Value(item.pickedAt),
      createdAt: Value(item.createdAt),
    );
  }

  /// تبدیل Entity به Drift Companion (برای Update)
  static db.PickingItemsCompanion toUpdateCompanion(PickingItem item) {
    return db.PickingItemsCompanion(
      id: Value(item.id!),
      sessionId: Value(item.sessionId!),
      locationWarehouse: Value(item.locationWarehouse),
      locationHall: Value(item.locationHall),
      color: Value(item.color),
      productCode: Value(item.productCode),
      productName: Value(item.productName),
      quantity: Value(item.quantity),
      gender: Value(item.gender),
      design: Value(item.design),
      size: Value(item.size),
      barcode: Value(item.barcode),
      sortOrder: Value(item.sortOrder),
      status: Value(item.status.toDbValue()),
      scannedBarcode: Value(item.scannedBarcode),
      pickedAt: Value(item.pickedAt),
    );
  }
}

/// Mapper برای PickingSession
class PickingSessionMapper {
  PickingSessionMapper._();

  /// تبدیل از Drift Row به Entity
  static PickingSession toEntity(db.PickingSessionRow row) {
    return PickingSession(
      id: row.id,
      userId: row.userId,
      name: row.name,
      sourceFile: row.sourceFile,
      totalItems: row.totalItems,
      pickedCount: row.pickedCount,
      skippedCount: row.skippedCount,
      status: SessionStatus.fromString(row.status),
      startedAt: row.startedAt,
      completedAt: row.completedAt,
    );
  }

  /// تبدیل لیست
  static List<PickingSession> toEntityList(List<db.PickingSessionRow> rows) {
    return rows.map(toEntity).toList();
  }

  /// تبدیل Entity به Drift Companion (برای Insert)
  static db.PickingSessionsCompanion toInsertCompanion(PickingSession session) {
    return db.PickingSessionsCompanion.insert(
      userId: session.userId,
      name: session.name,
      sourceFile: session.sourceFile,
      totalItems: Value(session.totalItems),
      pickedCount: Value(session.pickedCount),
      skippedCount: Value(session.skippedCount),
      status: Value(session.status.toDbValue()),
      startedAt: Value(session.startedAt),
      completedAt: Value(session.completedAt),
    );
  }

  /// تبدیل Entity به Drift Companion (برای Update)
  static db.PickingSessionsCompanion toUpdateCompanion(PickingSession session) {
    return db.PickingSessionsCompanion(
      id: Value(session.id!),
      userId: Value(session.userId),
      name: Value(session.name),
      sourceFile: Value(session.sourceFile),
      totalItems: Value(session.totalItems),
      pickedCount: Value(session.pickedCount),
      skippedCount: Value(session.skippedCount),
      status: Value(session.status.toDbValue()),
      startedAt: Value(session.startedAt),
      completedAt: Value(session.completedAt),
    );
  }
}
