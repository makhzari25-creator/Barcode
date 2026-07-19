import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_strings.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/picking/presentation/pages/picking_page.dart';
import '../../features/picking/presentation/pages/picking_report_page.dart';
import '../../features/scanner/presentation/pages/scanner_page.dart';
import '../../features/reports/presentation/pages/reports_page.dart';
import '../../features/import_export/presentation/pages/import_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';

/// مسیریاب اپلیکیشن
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.login,
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isOnLogin = state.matchedLocation == AppRoutes.login;

      if (!isAuthenticated && !isOnLogin) {
        return AppRoutes.login;
      }
      if (isAuthenticated && isOnLogin) {
        return AppRoutes.home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        name: AppStrings.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        name: AppStrings.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.picking,
        name: 'برداشت',
        builder: (context, state) => const PickingPage(),
      ),
      GoRoute(
        path: AppRoutes.pickingReport,
        name: 'گزارش برداشت',
        builder: (context, state) => const PickingReportPage(),
      ),
      GoRoute(
        path: AppRoutes.scanner,
        name: AppStrings.scanTitle,
        builder: (context, state) => const ScannerPage(),
      ),
      GoRoute(
        path: AppRoutes.reports,
        name: AppStrings.reports,
        builder: (context, state) => const ReportsPage(),
      ),
      GoRoute(
        path: AppRoutes.import,
        name: AppStrings.importExcel,
        builder: (context, state) => const ImportPage(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: AppStrings.settings,
        builder: (context, state) => const SettingsPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text(AppStrings.error)),
      body: Center(
        child: Text(
          '${state.error}',
          style: const TextStyle(fontFamily: 'Vazirmatn'),
          textAlign: TextAlign.center,
        ),
      ),
    ),
  );
});

/// مسیرهای اپلیکیشن
class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String home = '/home';
  static const String picking = '/picking';
  static const String pickingReport = '/picking/report';
  static const String scanner = '/scanner';
  static const String reports = '/reports';
  static const String import = '/import';
  static const String settings = '/settings';
}
