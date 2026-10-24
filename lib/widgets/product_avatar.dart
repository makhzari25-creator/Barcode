import 'dart:io';
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../theme/app_colors.dart';

/// عکس کالا: اگر ستون «عکس» در اکسل مسیر یا آدرس معتبر داشته باشد نمایش داده
/// می‌شود، در غیر این صورت (یا در صورت خطا) آیکون جایگزین دیده می‌شود.
class ProductAvatar extends StatelessWidget {
  final Product? product;
  final double size;
  final Color color;

  const ProductAvatar({
    super.key,
    required this.product,
    this.size = 56,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(size * 0.22);
    final fallback = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: radius,
      ),
      child: Icon(Icons.inventory_2_rounded, color: color, size: size * 0.5),
    );

    final url = product?.imageUrl.trim() ?? '';
    if (url.isEmpty) return fallback;

    final Widget image;
    if (url.startsWith('http://') || url.startsWith('https://')) {
      image = Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
      );
    } else {
      image = Image.file(
        File(url),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
      );
    }
    return ClipRRect(borderRadius: radius, child: image);
  }
}
