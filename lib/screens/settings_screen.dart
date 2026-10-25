import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../services/hall_charge_state.dart';
import '../services/settings_state.dart';
import '../theme/app_colors.dart';
import '../widgets/dialogs.dart';

/// صفحه‌ی تنظیمات: صدا، لرزش و مدیریت داده‌ها
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _clear(
    BuildContext context, {
    required String title,
    required String message,
    required Future<void> Function() action,
    required String done,
  }) async {
    final ok = await confirmDialog(
      context,
      title: title,
      message: message,
      confirmLabel: 'حذف',
      destructive: true,
    );
    if (!ok) return;
    await action();
    if (!context.mounted) return;
    showAppSnack(context, done, kind: SnackKind.success);
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsState>();
    final check = context.read<AppState>();
    final hall = context.read<HallChargeState>();

    return Scaffold(
      appBar: AppBar(title: const Text('تنظیمات')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          const _SectionTitle('اسکن'),
          _Card(children: [
            SwitchListTile(
              value: settings.soundEnabled,
              onChanged: settings.setSoundEnabled,
              secondary: const Icon(Icons.volume_up_rounded),
              title: const Text('صدای تایید و رد'),
              subtitle: const Text('پس از هر اسکن یک صدای کوتاه پخش می‌شود'),
            ),
            const Divider(height: 1),
            SwitchListTile(
              value: settings.vibrationEnabled,
              onChanged: settings.setVibrationEnabled,
              secondary: const Icon(Icons.vibration_rounded),
              title: const Text('لرزش'),
              subtitle: const Text('لرزش کوتاه هنگام هر اسکن'),
            ),
          ]),
          const SizedBox(height: 20),
          const _SectionTitle('داده‌ها'),
          _Card(children: [
            _DangerTile(
              icon: Icons.qr_code_scanner_rounded,
              title: 'حذف لیست و شمارنده‌های «چک کردن شارژ»',
              onTap: () => _clear(
                context,
                title: 'حذف داده‌های چک کردن شارژ',
                message:
                    'فایل فعلی و همه‌ی شمارنده‌ها پاک می‌شود. بایگانی دست نمی‌خورد.',
                action: check.clearAll,
                done: 'داده‌های چک کردن شارژ حذف شد.',
              ),
            ),
            const Divider(height: 1),
            _DangerTile(
              icon: Icons.add_box_rounded,
              title: 'حذف لیست و تاییدهای «شارژ سالن»',
              onTap: () => _clear(
                context,
                title: 'حذف داده‌های شارژ سالن',
                message:
                    'فایل فعلی و همه‌ی تاییدها پاک می‌شود. بایگانی دست نمی‌خورد.',
                action: hall.clearAll,
                done: 'داده‌های شارژ سالن حذف شد.',
              ),
            ),
            const Divider(height: 1),
            _DangerTile(
              icon: Icons.archive_rounded,
              title: 'خالی کردن هر دو بایگانی',
              onTap: () => _clear(
                context,
                title: 'خالی کردن بایگانی',
                message: 'همه‌ی موارد بایگانی هر دو بخش برای همیشه حذف می‌شود.',
                action: () async {
                  await check.clearArchives();
                  await hall.clearArchives();
                },
                done: 'بایگانی خالی شد.',
              ),
            ),
          ]),
          const SizedBox(height: 20),
          const _SectionTitle('درباره'),
          const _Card(children: [
            ListTile(
              leading: Icon(Icons.info_outline_rounded),
              title: Text('چک شارژ سالن'),
              subtitle: Text(
                'نسخه ۱٫۰٫۰ · ساخته‌شده با اعتماد، MA LABS\nداده‌ها فقط روی همین گوشی ذخیره می‌شوند.',
                style: TextStyle(height: 1.8),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
      child: Text(
        text,
        style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textMuted),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final List<Widget> children;
  const _Card({required this.children});

  @override
  Widget build(BuildContext context) {
    // Material لازم است تا ListTile / SwitchListTile بتوانند ink splash بکشند
    // و در تست‌های widget assertion «background color may be invisible» ندهند.
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(children: children),
      ),
    );
  }
}

class _DangerTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _DangerTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppColors.danger),
      title: Text(title, style: const TextStyle(fontSize: 14.5)),
      trailing: const Icon(Icons.delete_outline_rounded,
          color: AppColors.danger, size: 22),
    );
  }
}
