/// موجودیت بارکد مجاز
class Barcode {
  final int? id;
  final String code;
  final String? productName;
  final String? productCode;
  final String? category;
  final String? size;
  final String? color;
  final int? importedBatch;
  final DateTime createdAt;

  const Barcode({
    this.id,
    required this.code,
    this.productName,
    this.productCode,
    this.category,
    this.size,
    this.color,
    this.importedBatch,
    required this.createdAt,
  });

  Barcode copyWith({
    int? id,
    String? code,
    String? productName,
    String? productCode,
    String? category,
    String? size,
    String? color,
    int? importedBatch,
    DateTime? createdAt,
  }) {
    return Barcode(
      id: id ?? this.id,
      code: code ?? this.code,
      productName: productName ?? this.productName,
      productCode: productCode ?? this.productCode,
      category: category ?? this.category,
      size: size ?? this.size,
      color: color ?? this.color,
      importedBatch: importedBatch ?? this.importedBatch,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
