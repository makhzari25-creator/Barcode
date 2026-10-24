import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// نوع پیام کوتاه پایین صفحه
enum SnackKind { success, error, info }

void showAppSnack(BuildContext context, String message,
    {SnackKind kind = SnackKind.info}) {
  final color = switch (kind) {
    SnackKind.success => AppColors.success,
    SnackKind.error => AppColors.danger,
    SnackKind.info => AppColors.primaryDark,
  };
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
}

/// دیالوگ تایید دو دکمه‌ای. اگر [destructive] باشد دکمه تایید قرمز می‌شود.
Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(title),
      content: Text(message, style: const TextStyle(height: 1.8)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('انصراف'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: FilledButton.styleFrom(
            minimumSize: const Size(96, 44),
            backgroundColor:
                destructive ? AppColors.danger : AppColors.primary,
          ),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// دیالوگ جشن تکمیل شارژ
Future<void> showCompleteDialog(
  BuildContext context, {
  required String message,
}) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(
              color: AppColors.successSoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.celebration_rounded,
                color: AppColors.success, size: 56),
          ),
          const SizedBox(height: 18),
          const Text(
            'تکمیل شد!',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 15, color: AppColors.textMuted, height: 1.8),
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
      actions: [
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => Navigator.pop(ctx),
            style: FilledButton.styleFrom(backgroundColor: AppColors.success),
            child: const Text('باشه'),
          ),
        ),
      ],
    ),
  );
}
