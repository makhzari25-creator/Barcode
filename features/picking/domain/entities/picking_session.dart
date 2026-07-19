// lib/features/picking/domain/entities/picking_session.dart
//
// موجودیت نشست برداشت
//

import 'picking_item.dart';

/// وضعیت نشست برداشت
enum SessionStatus {
  /// در حال انجام
  active('در حال انجام'),

  /// تکمیل شده
  completed('تکمیل شده'),

  /// لغو شده
  cancelled('لغو شده');

  final String label;
  const SessionStatus(this.label);

  static SessionStatus fromString(String value) {
    return switch (value) {
      'active' => SessionStatus.active,
      'completed' => SessionStatus.completed,
      'cancelled' => SessionStatus.cancelled,
      _ => SessionStatus.active,
    };
  }

  String toDbValue() => name;
}

/// موجودیت نشست برداشت
///
/// یک نشست نشان‌دهنده یک دوره کاری است که اپراتور در آن
/// لیست آیتم‌ها را برداشت می‌کند.
class PickingSession {
  final int? id;
  final int userId;
  final String name;

  /// نام فایل اکسل که از آن لیست بارگذاری شده
  final String sourceFile;

  /// تعداد کل آیتم‌ها
  final int totalItems;

  /// تعداد آیتم‌های با موفقیت برداشت شده
  final int pickedCount;

  /// تعداد آیتم‌های نادیده گرفته شده
  final int skippedCount;

  /// وضعیت نشست
  final SessionStatus status;

  /// زمان شروع
  final DateTime startedAt;

  /// زمان پایان (در صورت تکمیل)
  final DateTime? completedAt;

  const PickingSession({
    this.id,
    required this.userId,
    required this.name,
    required this.sourceFile,
    this.totalItems = 0,
    this.pickedCount = 0,
    this.skippedCount = 0,
    this.status = SessionStatus.active,
    required this.startedAt,
    this.completedAt,
  });

  /// تعداد آیتم‌های باقی‌مانده
  int get remainingItems => totalItems - pickedCount - skippedCount;

  /// درصد پیشرفت (۰ تا ۱)
  double get progress {
    if (totalItems == 0) return 0;
    return (pickedCount + skippedCount) / totalItems;
  }

  /// آیا نشست فعال است؟
  bool get isActive => status == SessionStatus.active;

  /// آیا نشست تکمیل شده است؟
  bool get isCompleted => status == SessionStatus.completed;

  PickingSession copyWith({
    int? id,
    int? userId,
    String? name,
    String? sourceFile,
    int? totalItems,
    int? pickedCount,
    int? skippedCount,
    SessionStatus? status,
    DateTime? startedAt,
    DateTime? completedAt,
  }) {
    return PickingSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      sourceFile: sourceFile ?? this.sourceFile,
      totalItems: totalItems ?? this.totalItems,
      pickedCount: pickedCount ?? this.pickedCount,
      skippedCount: skippedCount ?? this.skippedCount,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

/// آمار نشست برداشت
class PickingSessionStats {
  final int totalItems;
  final int pickedCount;
  final int skippedCount;
  final int wrongBarcodeCount;
  final int pendingCount;

  const PickingSessionStats({
    required this.totalItems,
    required this.pickedCount,
    required this.skippedCount,
    required this.wrongBarcodeCount,
    required this.pendingCount,
  });

  /// تعداد آیتم‌های از دست رفته (نادیده یا اشتباه)
  int get missedCount => skippedCount + wrongBarcodeCount;

  /// آیا نشست کامل برداشت شده؟
  bool get isComplete => pendingCount == 0 && missedCount == 0;

  factory PickingSessionStats.fromItems(List<PickingItem> items) {
    int picked = 0;
    int skipped = 0;
    int wrong = 0;
    int pending = 0;

    for (final item in items) {
      switch (item.status) {
        case PickingStatus.picked:
          picked++;
          break;
        case PickingStatus.skipped:
          skipped++;
          break;
        case PickingStatus.wrongBarcode:
          wrong++;
          break;
        case PickingStatus.pending:
          pending++;
          break;
      }
    }

    return PickingSessionStats(
      totalItems: items.length,
      pickedCount: picked,
      skippedCount: skipped,
      wrongBarcodeCount: wrong,
      pendingCount: pending,
    );
  }
}

/// نتیجه اعتبارسنجی بارکد در نشست برداشت
class PickingValidationResult {
  /// وضعیت نتیجه
  final PickingValidationStatus status;

  /// آیتمی که بارکد با آن تطابق داشت (در صورت وجود)
  final PickingItem? matchedItem;

  /// آیتم فعلی که باید اسکن می‌شد
  final PickingItem? expectedItem;

  const PickingValidationResult({
    required this.status,
    this.matchedItem,
    this.expectedItem,
  });
}

/// وضعیت نتیجه اعتبارسنجی بارکد
enum PickingValidationStatus {
  /// بارکد با آیتم فعلی تطابق دارد
  correct,

  /// بارکد با آیتم دیگری در لیست تطابق دارد (نه آیتم فعلی)
  wrongItem,

  /// بارکد در لیست وجود ندارد
  notInList,

  /// آیتم قبلاً برداشت شده
  alreadyPicked,
}
