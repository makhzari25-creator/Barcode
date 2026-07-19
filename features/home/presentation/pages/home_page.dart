import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../injection.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// صفحه اصلی اپلیکیشن
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.appName,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: AppStrings.logout,
            onPressed: () => _showLogoutDialog(context, ref),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome card
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingLg),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      radius: 28,
                      child: const Icon(Icons.person, color: Colors.white, size: 32),
                    ),
                    const SizedBox(width: AppDimensions.spacingMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${AppStrings.welcome}،',
                            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                          ),
                          Text(
                            user?.fullName ?? '',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              user?.role.label ?? '',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.spacingLg),

              // Main action - Start Picking (large CTA)
              _MenuButton(
                title: 'شروع برداشت',
                subtitle: 'شروع نشست برداشت کالا',
                icon: Icons.play_arrow_rounded,
                color: AppColors.accent,
                textColor: AppColors.primaryDark,
                size: MenuButtonSize.large,
                onTap: () => context.push('/picking'),
              ),
              const SizedBox(height: AppDimensions.spacingMd),

              // Legacy scanner (تأیید بارکد)
              _MenuButton(
                title: AppStrings.startScan,
                subtitle: 'تأیید بارکد (حالت ساده)',
                icon: Icons.qr_code_scanner_rounded,
                color: AppColors.primary,
                textColor: Colors.white,
                onTap: () => context.push('/scanner'),
              ),
              const SizedBox(height: AppDimensions.spacingSm),

              // Reports
              _MenuButton(
                title: AppStrings.reports,
                subtitle: 'مشاهده آمار و جزئیات اسکن‌ها',
                icon: Icons.assessment_rounded,
                color: AppColors.primary,
                textColor: Colors.white,
                onTap: () => context.push('/reports'),
              ),
              const SizedBox(height: AppDimensions.spacingSm),

              // Import Excel - only admin
              _MenuButton(
                title: AppStrings.importExcel,
                subtitle: user?.role.isAdmin == true
                    ? 'وارد کردن لیست برداشت از اکسل'
                    : 'نیاز به دسترسی مدیر',
                icon: Icons.file_upload_rounded,
                color: AppColors.primary,
                textColor: Colors.white,
                enabled: user?.role.isAdmin == true,
                onTap: () => context.push('/import'),
              ),
              const SizedBox(height: AppDimensions.spacingSm),

              // Settings
              _MenuButton(
                title: AppStrings.settings,
                subtitle: 'تنظیمات برنامه و حساب کاربری',
                icon: Icons.settings_rounded,
                color: AppColors.primary,
                textColor: Colors.white,
                onTap: () => context.push('/settings'),
              ),
              const SizedBox(height: AppDimensions.spacingLg),

              // Statistics card - real barcode count from database
              Consumer(
                builder: (context, ref, _) {
                  final countFuture = ref.watch(getBarcodeCountUseCaseProvider);
                  return FutureBuilder<int>(
                    future: countFuture(),
                    builder: (context, snapshot) {
                      final count = snapshot.data ?? 0;
                      return Container(
                        padding: const EdgeInsets.all(AppDimensions.paddingLg),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                          border: Border.all(color: AppColors.gray200),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.inventory_2_outlined, color: AppColors.primary, size: 32),
                            const SizedBox(width: AppDimensions.spacingMd),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppStrings.totalBarcodes,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    _formatNumber(count),
                                    style: theme.textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.logout),
        content: const Text(AppStrings.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text(AppStrings.logout),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(authProvider.notifier).logout();
      if (context.mounted) {
        context.go('/login');
      }
    }
  }

  /// تبدیل عدد به فارسی با جداکننده هزارگان
  String _formatNumber(int n) {
    final str = n.toString();
    final persianDigits = str.replaceAllMapped(
      RegExp(r'\d'),
      (m) => const ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'][int.parse(m.group(0)!)],
    );
    // Add thousand separators
    final buffer = StringBuffer();
    int count = 0;
    for (int i = persianDigits.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) {
        buffer.write('،');
      }
      buffer.write(persianDigits[i]);
      count++;
    }
    return buffer.toString().split('').reversed.join();
  }
}

enum MenuButtonSize { normal, large }

class _MenuButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color textColor;
  final MenuButtonSize size;
  final bool enabled;
  final VoidCallback onTap;

  const _MenuButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.textColor,
    this.size = MenuButtonSize.normal,
    this.enabled = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final height = size == MenuButtonSize.large
        ? AppDimensions.buttonHeightLg + 20
        : AppDimensions.buttonHeightLg;
    final iconSize = size == MenuButtonSize.large ? 40.0 : 32.0;

    return Material(
      color: enabled ? color : color.withOpacity(0.4),
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingLg),
          child: Row(
            children: [
              Icon(icon, color: textColor, size: iconSize),
              const SizedBox(width: AppDimensions.spacingMd),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Vazirmatn',
                        fontSize: size == MenuButtonSize.large ? 22 : 18,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: 'Vazirmatn',
                        fontSize: 13,
                        color: textColor.withOpacity(0.85),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_left, color: textColor.withOpacity(0.7)),
            ],
          ),
        ),
      ),
    );
  }
}
