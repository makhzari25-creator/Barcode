/// مدل کالای بارکد‌دار
/// هر کالا شامل کد، عنوان و تعداد مورد نیاز اسکن است
class Product {
  final String code;
  final String title;
  final int requiredCount;

  Product({
    required this.code,
    required this.title,
    required this.requiredCount,
  });

  factory Product.empty() => Product(code: '', title: '', requiredCount: 0);

  bool get isEmpty => code.isEmpty && title.isEmpty;

  Map<String, dynamic> toJson() => {
        'code': code,
        'title': title,
        'requiredCount': requiredCount,
      };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        code: json['code'] as String? ?? '',
        title: json['title'] as String? ?? '',
        requiredCount: json['requiredCount'] as int? ?? 0,
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
/// وقتی فایل جدیدی بارگذاری می‌شود، وضعیت فایل قبلی این‌جا نگه داشته می‌شود
/// تا هیچ داده‌ای گم نشود، ولی از صفحه‌ی فعلی پاک شود.
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
