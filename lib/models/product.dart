/// مدل کالای بارکد‌دار
/// فیلدهای اصلی شارژ از سند انبار / اکسل
class Product {
  final String code;
  final String title;
  final int requiredCount;

  /// مسیر فایل روی گوشی یا آدرس اینترنتی عکس کالا (اختیاری)
  final String imageUrl;

  /// محل فیزیکی انبار (م.ف. انبار) مثلاً 1-11-1-1
  final String warehouseLoc;

  /// رنگ کالا
  final String color;

  /// طرح
  final String design;

  /// سایز (XL, Free, ...)
  final String size;

  /// سه رقم اول محل فیزیکی سالن (م.ف.سالن) مثلاً 031 یا 032
  final String hallLoc;

  Product({
    required this.code,
    required this.title,
    required this.requiredCount,
    this.imageUrl = '',
    this.warehouseLoc = '',
    this.color = '',
    this.design = '',
    this.size = '',
    this.hallLoc = '',
  });

  factory Product.empty() => Product(code: '', title: '', requiredCount: 0);

  Product copyWith({
    int? requiredCount,
    String? title,
    String? warehouseLoc,
    String? color,
    String? design,
    String? size,
    String? hallLoc,
    String? imageUrl,
  }) =>
      Product(
        code: code,
        title: title ?? this.title,
        requiredCount: requiredCount ?? this.requiredCount,
        imageUrl: imageUrl ?? this.imageUrl,
        warehouseLoc: warehouseLoc ?? this.warehouseLoc,
        color: color ?? this.color,
        design: design ?? this.design,
        size: size ?? this.size,
        hallLoc: hallLoc ?? this.hallLoc,
      );

  bool get isEmpty => code.isEmpty && title.isEmpty;

  /// زیرعنوان خلاصه برای لیست: رنگ · سایز · م.ف.انبار
  String get subtitleBits {
    final parts = <String>[];
    if (color.isNotEmpty) parts.add(color);
    if (size.isNotEmpty) parts.add(size);
    if (warehouseLoc.isNotEmpty) parts.add(warehouseLoc);
    if (hallLoc.isNotEmpty) parts.add('سالن $hallLoc');
    return parts.join(' · ');
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'title': title,
        'requiredCount': requiredCount,
        'imageUrl': imageUrl,
        'warehouseLoc': warehouseLoc,
        'color': color,
        'design': design,
        'size': size,
        'hallLoc': hallLoc,
      };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        code: json['code'] as String? ?? '',
        title: json['title'] as String? ?? '',
        requiredCount: (json['requiredCount'] as num?)?.toInt() ?? 0,
        imageUrl: json['imageUrl'] as String? ?? '',
        warehouseLoc: json['warehouseLoc'] as String? ?? '',
        color: json['color'] as String? ?? '',
        design: json['design'] as String? ?? '',
        size: json['size'] as String? ?? '',
        hallLoc: json['hallLoc'] as String? ?? '',
      );
}

/// وضعیت اسکن یک کالا
class ScanState {
  final String code;
  final int scannedCount;

  ScanState({required this.code, required this.scannedCount});

  Map<String, dynamic> toJson() => {
        'code': code,
        'scannedCount': scannedCount,
      };

  factory ScanState.fromJson(Map<String, dynamic> json) => ScanState(
        code: json['code'] as String? ?? '',
        scannedCount: json['scannedCount'] as int? ?? 0,
      );
}

/// یک نسخه‌ی بایگانی‌شده از فایل اکسل و نتیجه‌ی اسکن‌های آن
class ArchivedSession {
  final String fileName;
  final DateTime archivedAt;
  final List<Product> products;
  final Map<String, int> scanCounts;

  ArchivedSession({
    required this.fileName,
    required this.archivedAt,
    required this.products,
    required this.scanCounts,
  });

  int scannedCountFor(String code) => scanCounts[code] ?? 0;

  int get totalRequired =>
      products.fold(0, (sum, p) => sum + p.requiredCount);

  int get totalScanned =>
      products.fold(0, (sum, p) => sum + scannedCountFor(p.code));

  bool get isComplete {
    if (products.isEmpty) return false;
    for (final p in products) {
      if (scannedCountFor(p.code) < p.requiredCount) return false;
    }
    return true;
  }

  Map<String, dynamic> toJson() => {
        'fileName': fileName,
        'archivedAt': archivedAt.toIso8601String(),
        'products': products.map((p) => p.toJson()).toList(),
        'scanCounts': scanCounts,
      };

  factory ArchivedSession.fromJson(Map<String, dynamic> json) =>
      ArchivedSession(
        fileName: json['fileName'] as String? ?? 'بدون نام',
        archivedAt: DateTime.tryParse(json['archivedAt'] as String? ?? '') ??
            DateTime.now(),
        products: (json['products'] as List? ?? [])
            .map((e) => Product.fromJson(e as Map<String, dynamic>))
            .toList(),
        scanCounts: Map<String, int>.from(
          (json['scanCounts'] as Map?)?.map(
                (k, v) => MapEntry(k as String, (v as num).toInt()),
              ) ??
              {},
        ),
      );
}
