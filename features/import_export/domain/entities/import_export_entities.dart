/// حالت Import
enum ImportMode {
  add('افزودن به موجود'),
  replace('جایگزینی کامل');

  final String label;
  const ImportMode(this.label);
}

/// نتیجه Import
class ImportResult {
  final int totalRecords;
  final int importedCount;
  final int skippedCount;
  final int errorCount;
  final String fileName;
  final String? error;

  const ImportResult({
    required this.totalRecords,
    required this.importedCount,
    required this.skippedCount,
    required this.errorCount,
    required this.fileName,
    this.error,
  });

  bool get isSuccess => errorCount == 0 && error == null;
}
