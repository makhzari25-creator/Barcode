import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../services/hall_charge_state.dart';
import '../services/settings_state.dart';
import '../theme/app_colors.dart';
import '../utils/barcode_utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // بارگذاری وضعیت ذخیره‌شده در ابتدای باز شدن برنامه
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<SettingsState>().initialize();
      context.read<AppState>().initialize();
      context.read<HallChargeState>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final check = context.watch<AppState>();
    final hall = context.watch<HallChargeState>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const _OfflineBadge(),
                  const Spacer(),
                  IconButton(
                    tooltip: 'تنظیمات',
                    onPressed: () =>
                        Navigator.of(context).pushNamed('/settings'),
                    icon: const Icon(Icons.settings_rounded),
                    color: AppColors.primaryDark,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const _Hero(),
              const SizedBox(height: 24),
              _FileStatusCard(
                rows: [
                  _FileRow(
                    label: 'شارژ سالن',
                    fileName: hall.fileName,
                    count: hall.products.length,
                    color: AppColors.hall,
                  ),
                  _FileRow(
                    label: 'چک کردن شارژ',
                    fileName: check.excelFileName,
                    count: check.products.length,
                    color: AppColors.primary,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _HomeButton(
                icon: Icons.add_box_rounded,
                label: 'شارژ سالن',
                subtitle: 'اسکن و تایید کالاها برای شارژ سالن',
                color: AppColors.hall,
                onTap: () => Navigator.of(context).pushNamed('/charge_hall'),
              ),
              const SizedBox(height: 12),
              _HomeButton(
                icon: Icons.qr_code_scanner_rounded,
                label: 'چک کردن شارژ',
                subtitle: 'بررسی موجودی و تطبیق با لیست',
                color: AppColors.primary,
                onTap: () => Navigator.of(context).pushNamed('/check_charge'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).pushNamed('/archive'),
                icon: const Icon(Icons.archive_outlined),
                label: const Text('بایگانی'),
              ),
              const SizedBox(height: 28),
              const _Footer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _OfflineBadge extends StatelessWidget {
  const _OfflineBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off_rounded, size: 17, color: AppColors.primaryDark),
          SizedBox(width: 6),
          Text('بدون نیاز به اینترنت',
              style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryDark)),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 108,
          height: 108,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, Color(0xFF00B4CC)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.28),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(Icons.warehouse_rounded,
              size: 60, color: Colors.white),
        ),
        const SizedBox(height: 16),
        const Text('چک شارژ سالن',
            style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: AppColors.text)),
        const SizedBox(height: 4),
        const Text('ابزار مدیریت موجودی و شارژ سالن',
            style: TextStyle(fontSize: 14, color: AppColors.textMuted)),
      ],
    );
  }
}

class _FileRow {
  final String label;
  final String? fileName;
  final int count;
  final Color color;

  const _FileRow({
    required this.label,
    required this.fileName,
    required this.count,
    required this.color,
  });
}

class _FileStatusCard extends StatelessWidget {
  final List<_FileRow> rows;
  const _FileStatusCard({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const Divider(height: 1),
            _FileStatusRow(row: rows[i]),
          ],
        ],
      ),
    );
  }
}

class _FileStatusRow extends StatelessWidget {
  final _FileRow row;
  const _FileStatusRow({required this.row});

  @override
  Widget build(BuildContext context) {
    final loaded = row.fileName != null && row.count > 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: loaded ? const Color(0xFF1D7A45) : AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(Icons.table_chart_rounded,
                size: 22,
                color: loaded ? Colors.white : AppColors.textMuted),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(row.label,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: row.color)),
                Text(
                  loaded ? row.fileName! : 'فایلی بارگذاری نشده',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          if (loaded) ...[
            Text('${toFaDigits(row.count)} کالا',
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700)),
            const SizedBox(width: 6),
            const Icon(Icons.check_circle_rounded,
                color: AppColors.success, size: 20),
          ],
        ],
      ),
    );
  }
}

class _HomeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _HomeButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, size: 32, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                            color: Colors.white)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.white.withValues(alpha: 0.9))),
                  ],
                ),
              ),
              const Icon(Icons.chevron_left_rounded,
                  color: Colors.white, size: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(Icons.checkroom_rounded,
            size: 44, color: AppColors.primary.withValues(alpha: 0.35)),
        const SizedBox(height: 6),
        const Text('مدیریت بهتر، فروش بیشتر',
            style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
      ],
    );
  }
}
