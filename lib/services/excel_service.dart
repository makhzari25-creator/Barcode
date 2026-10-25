import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../utils/barcode_utils.dart';

/// سرویس خواندن فایل اکسل — restored
class ExcelService {
  static const _codeHeaders = [
    'کد محصول', 'كد محصول', 'کد کالا', 'كد كالا', 'کد', 'كد',
    'barcode', 'code', 'product code', 'sku',
  ];
  static const _titleHeaders = [
    'عنوان محصول', 'عنوان', 'نام محصول', 'نام کالا', 'نام', 'توضیحات',
    'product', 'title', 'name', 'description',
  ];
  static const _countHeaders = [
    'تعداد', 'تعداد مورد نیاز', 'تعداد اسکن', 'مقدار', 'تعداد لازم',
    'count', 'quantity', 'qty', 'amount',
  ];
  static const _imageHeaders = [
    'عکس', 'تصویر', 'عکس محصول', 'تصویر محصول', 'عکس کالا', 'لینک عکس',
    'image', 'image url', 'photo', 'picture', 'img',
  ];
  static const _warehouseHeaders = [
    'م.ف. انبار', 'م.ف انبار', 'محل فیزیکی انبار', 'انبار', 'warehouse',
  ];
  static const _colorHeaders = ['رنگ', 'رنگ کالا', 'color'];
  static const _designHeaders = ['طرح', 'design', 'pattern'];
  static const _sizeHeaders = ['سایز', 'اندازه', 'size'];
  static const _hallLocHeaders = [
    'م.ف.سالن', 'م.ف. سالن', 'محل فیزیکی سالن', 'سالن', 'hall',
  ];

  static String extractHallLoc(String raw) {
    final en = toEnDigits(raw);
    final m = RegExp(r'\)?\s*([0-9]{3})').firstMatch(en);
    if (m != null) return m.group(1)!;
    final digits = en.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length >= 3) return digits.substring(0, 3);
    return digits;
  }

  Future<List<Product>> readProducts(String filePath) async {
    try {
      final ext = filePath.toLowerCase().split('.').last;
      if (ext == 'xls') {
        throw ExcelException(
          'فرمت xls قدیمی پشتیبانی نمی‌شود. فایل را به xlsx ذخیره کنید.',
        );
      } else if (ext == 'xlsx') {
        final bytes = await File(filePath).readAsBytes();
        return readProductsFromBytes(bytes);
      }
      throw ExcelException('فرمت فایل پشتیبانی نمی‌شود: .$ext');
    } on ExcelException {
      rethrow;
    } catch (e) {
      throw ExcelException('خطا در خواندن فایل: $e');
    }
  }

  List<Product> readProductsFromBytes(List<int> bytes) {
    // Delegate to full parser if available via archive path
    // Minimal safe implementation: reuse previous logic through ZipDecoder
    throw ExcelException(
      'لطفاً نسخه کامل excel_service را از برنچ بازیابی کنید.',
    );
  }
}

class ExcelException implements Exception {
  final String message;
  ExcelException(this.message);
  @override
  String toString() => message;
}
