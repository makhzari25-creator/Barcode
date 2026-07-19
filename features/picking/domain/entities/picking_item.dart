// lib/features/picking/domain/entities/picking_item.dart
//
// موجودیت آیتم برداشت — مطابق ساختار Excel لیست برداشت انبار
// تمام ستون‌های فایل اکسل پشتیبانی می‌شوند (فارسی و انگلیسی)
//

/// وضعیت برداشت یک آیتم
enum PickingStatus {
  /// در انتظار برداشت
  pending('در انتظار'),

  /// با موفقیت برداشت شده
  picked('برداشت شد'),

  /// نادیده گرفته شده (skip شده توسط اپراتور)
  skipped('نادیده گرفته شد'),

  /// بارکد اشتباه اسکن شده
  wrongBarcode('بارکد اشتباه');

  final String label;
  const PickingStatus(this.label);

  static PickingStatus fromString(String value) {
    return switch (value) {
      'pending' => PickingStatus.pending,
      'picked' => PickingStatus.picked,
      'skipped' => PickingStatus.skipped,
      'wrongBarcode' => PickingStatus.wrongBarcode,
      _ => PickingStatus.pending,
    };
  }

  String toDbValue() => name;
}

/// موجودیت آیتم برداشت
///
/// هر آیتم نشان‌دهنده یک ردیف از فایل اکسل لیست برداشت است.
/// شامل تمام ستون‌های موردنیاز برای عملیات برداشت در انبار پوشاک.
class PickingItem {
  /// شناسه یکتا در دیتابیس
  final int? id;

  /// شناسه نشست برداشت که این آیتم به آن تعلق دارد
  final int? sessionId;

  /// م.ف.ا (مکان فیزیکی انبار) — مهم‌ترین فیلد برای مرتب‌سازی
  /// مثال: A-01-02، B-15-03
  final String locationWarehouse;

  /// م.ف.سالن (مکان سالن) — مکمل مکان فیزیکی
  final String? locationHall;

  /// رنگ محصول
  final String? color;

  /// کد محصول (کد کالا)
  final String? productCode;

  /// عنوان/نام محصول
  final String? productName;

  /// تعداد موردنیاز برای برداشت
  final int quantity;

  /// جنسیت (مردانه، زنانه، کودکانه و ...)
  final String? gender;

  /// طرح محصول
  final String? design;

  /// سایز محصول
  final String? size;

  /// بارکد محصول — کلید اصلی برای تطبیق هنگام اسکن
  final String barcode;

  /// ترتیب نمایش (پس از مرتب‌سازی بر اساس م.ف.ا)
  final int sortOrder;

  /// وضعیت برداشت این آیتم
  final PickingStatus status;

  /// بارکدی که واقعاً اسکن شده (در صورت تطابق با barcode)
  final String? scannedBarcode;

  /// زمان اسکن (در صورت برداشت)
  final DateTime? pickedAt;

  /// زمان ایجاد رکورد
  final DateTime createdAt;

  const PickingItem({
    this.id,
    this.sessionId,
    required this.locationWarehouse,
    this.locationHall,
    this.color,
    this.productCode,
    this.productName,
    required this.quantity,
    this.gender,
    this.design,
    this.size,
    required this.barcode,
    this.sortOrder = 0,
    this.status = PickingStatus.pending,
    this.scannedBarcode,
    this.pickedAt,
    required this.createdAt,
  });

  /// آیا این آیتم برداشت شده است؟
  bool get isPicked => status == PickingStatus.picked;

  /// آیا این آیتم هندر انتظار است؟
  bool get isPending => status == PickingStatus.pending;

  /// آیا این آیتم نادیده گرفته شده؟
  bool get isSkipped => status == PickingStatus.skipped;

  /// آیا این آیتم نیاز به توجه دارد (نادیده یا اشتباه)؟
  bool get isMissed =>
      status == PickingStatus.skipped || status == PickingStatus.wrongBarcode;

  PickingItem copyWith({
    int? id,
    int? sessionId,
    String? locationWarehouse,
    String? locationHall,
    String? color,
    String? productCode,
    String? productName,
    int? quantity,
    String? gender,
    String? design,
    String? size,
    String? barcode,
    int? sortOrder,
    PickingStatus? status,
    String? scannedBarcode,
    DateTime? pickedAt,
    DateTime? createdAt,
  }) {
    return PickingItem(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      locationWarehouse: locationWarehouse ?? this.locationWarehouse,
      locationHall: locationHall ?? this.locationHall,
      color: color ?? this.color,
      productCode: productCode ?? this.productCode,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      gender: gender ?? this.gender,
      design: design ?? this.design,
      size: size ?? this.size,
      barcode: barcode ?? this.barcode,
      sortOrder: sortOrder ?? this.sortOrder,
      status: status ?? this.status,
      scannedBarcode: scannedBarcode ?? this.scannedBarcode,
      pickedAt: pickedAt ?? this.pickedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() =>
      'PickingItem(barcode: $barcode, location: $locationWarehouse, status: $status)';
}
