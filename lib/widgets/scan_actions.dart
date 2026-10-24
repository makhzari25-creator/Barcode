import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// دکمه‌ی گرد با برچسب زیرش (چراغ قوی، ورود دستی)
class ScanActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;
  final Color color;

  const ScanActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: active ? color : AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: active ? color : AppColors.border),
              ),
              child: Icon(icon, color: active ? Colors.white : color, size: 26),
            ),
            const SizedBox(height: 6),
            Text(label,
                style: const TextStyle(
                    fontSize: 12.5, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}
