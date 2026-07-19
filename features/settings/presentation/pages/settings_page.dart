import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../injection.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../scanner/domain/usecases/scan_usecases.dart';
import '../providers/settings_provider.dart';

/// صفحه تنظیمات
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final user = ref.watch(currentUserProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.paddingMd),
        children: [
          // صدا و بازخورد
          _SectionTitle(title: 'صدا و بازخورد'),
          _SettingsCard(
            children: [
              SwitchListTile(
                title: const Text(AppStrings.sound),
                subtitle: const Text('پخش صدا هنگام اسکن'),
                value: settings.soundEnabled,
                onChanged: (v) => ref.read(settingsProvider.notifier).toggleSound(v),
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: const Text(AppStrings.vibration),
                subtitle: const Text('لرزش دستگاه هنگام اسکن'),
                value: settings.vibrationEnabled,
                onChanged: (v) => ref.read(settingsProvider.notifier).toggleVibration(v),
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: const Text(AppStrings.autoFlash),
                subtitle: const Text('روشن کردن خودکار فلش در محیط تاریک'),
                value: settings.autoFlashEnabled,
                onChanged: (v) => ref.read(settingsProvider.notifier).toggleAutoFlash(v),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingLg),

          // ظاهر
          _SectionTitle(title: 'ظاهر'),
          _SettingsCard(
            children: [
              ListTile(
                title: const Text(AppStrings.darkMode),
                subtitle: Text(_themeModeLabel(settings.themeMode)),
                trailing: const Icon(Icons.chevron_left),
                onTap: () => _showThemeDialog(context, ref),
              ),
              const Divider(height: 1),
              ListTile(
                title: const Text(AppStrings.resultDuration),
                subtitle: Text('${(settings.resultDurationMs / 1000).toStringAsFixed(1)} ثانیه'),
                trailing: const Icon(Icons.chevron_left),
                onTap: () => _showDurationDialog(context, ref),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingLg),

          // حساب کاربری
          _SectionTitle(title: 'حساب کاربری'),
          _SettingsCard(
            children: [
              ListTile(
                title: const Text(AppStrings.changePassword),
                leading: const Icon(Icons.lock_outline, color: AppColors.primary),
                trailing: const Icon(Icons.chevron_left),
                onTap: () => _showChangePasswordDialog(context, ref, user?.id),
              ),
              if (user?.role.isAdmin == true) ...[
                const Divider(height: 1),
                ListTile(
                  title: const Text(AppStrings.clearScans),
                  subtitle: const Text('حذف تمام اسکن‌های ثبت‌شده'),
                  leading: const Icon(Icons.delete_outline, color: AppColors.error),
                  trailing: const Icon(Icons.chevron_left),
                  onTap: () => _showClearScansDialog(context, ref),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppDimensions.spacingLg),

          // درباره
          _SectionTitle(title: 'درباره'),
          _SettingsCard(
            children: [
              ListTile(
                title: const Text(AppStrings.about),
                leading: const Icon(Icons.info_outline, color: AppColors.primary),
                trailing: const Icon(Icons.chevron_left),
                onTap: () => _showAboutDialog(context),
              ),
              ListTile(
                title: const Text('خروج از حساب'),
                leading: const Icon(Icons.logout, color: AppColors.error),
                trailing: const Icon(Icons.chevron_left),
                onTap: () => _showLogoutDialog(context, ref),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingLg),
          Text(
            'نسخه ${AppStrings.appVersion}',
            style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textHint),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _themeModeLabel(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => AppStrings.themeLight,
      ThemeMode.dark => AppStrings.themeDark,
      ThemeMode.system => AppStrings.themeSystem,
    };
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text(AppStrings.darkMode),
        children: ThemeMode.values.map((mode) {
          return SimpleDialogOption(
            onPressed: () {
              ref.read(settingsProvider.notifier).setThemeMode(mode);
              Navigator.pop(ctx);
            },
            child: Row(
              children: [
                Icon(_themeModeIcon(mode)),
                const SizedBox(width: 8),
                Text(_themeModeLabel(mode)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  IconData _themeModeIcon(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => Icons.light_mode,
      ThemeMode.dark => Icons.dark_mode,
      ThemeMode.system => Icons.settings_brightness,
    };
  }

  void _showDurationDialog(BuildContext context, WidgetRef ref) {
    final options = [1000, 1500, 2000, 2500, 3000];
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text(AppStrings.resultDuration),
        children: options.map((ms) {
          return SimpleDialogOption(
            onPressed: () {
              ref.read(settingsProvider.notifier).setResultDuration(ms);
              Navigator.pop(ctx);
            },
            child: Text('${(ms / 1000).toStringAsFixed(1)} ثانیه'),
          );
        }).toList(),
      ),
    );
  }

  /// دیالوگ تغییر رمز عبور
  void _showChangePasswordDialog(BuildContext context, WidgetRef ref, int? userId) {
    if (userId == null) return;

    final oldController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.changePassword),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: oldController,
                  decoration: const InputDecoration(
                    labelText: AppStrings.oldPassword,
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                  validator: Validators.validatePassword,
                ),
                const SizedBox(height: AppDimensions.spacingSm),
                TextFormField(
                  controller: newController,
                  decoration: const InputDecoration(
                    labelText: AppStrings.newPassword,
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: Validators.validatePassword,
                ),
                const SizedBox(height: AppDimensions.spacingSm),
                TextFormField(
                  controller: confirmController,
                  decoration: const InputDecoration(
                    labelText: AppStrings.confirmPassword,
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (v) =>
                      Validators.validatePasswordMatch(v, newController.text),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

              final useCase = ref.read(changePasswordUseCaseProvider);
              final result = await useCase(
                userId: userId,
                oldPassword: oldController.text,
                newPassword: newController.text,
              );

              if (!ctx.mounted) return;
              Navigator.pop(ctx);

              result.fold(
                (failure) => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(failure.message),
                    backgroundColor: AppColors.error,
                  ),
                ),
                (_) => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(AppStrings.passwordChanged),
                    backgroundColor: ScanResultColors.validBg,
                  ),
                ),
              );
            },
            child: const Text(AppStrings.save),
          ),
        ],
      ),
    );
  }

  /// دیالوگ پاک‌سازی اسکن‌ها
  void _showClearScansDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.clearScans),
        content: const Text(AppStrings.clearScansConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final useCase = ref.read(clearAllScansUseCaseProvider);
              await useCase();
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('اسکن‌ها با موفقیت پاک شدند'),
                  backgroundColor: ScanResultColors.validBg,
                ),
              );
            },
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.appName),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('اپلیکیشن تأیید بارکد انبار'),
            SizedBox(height: 8),
            Text('نسخه: ${AppStrings.appVersion}'),
            Text('ساخته‌شده با Flutter'),
            SizedBox(height: 8),
            Text('© ۱۴۰۵ تمام حقوق محفوظ است'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(AppStrings.close),
          ),
        ],
      ),
    );
  }

  /// دیالوگ خروج
  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.logout),
        content: const Text(AppStrings.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
              context.go('/login');
            },
            child: const Text(AppStrings.logout),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppDimensions.spacingSm, bottom: AppDimensions.spacingSm),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Column(children: children),
    );
  }
}
