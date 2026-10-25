import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'services/app_state.dart';
import 'services/hall_charge_state.dart';
import 'services/settings_state.dart';
import 'screens/settings_screen.dart';
import 'screens/home_screen.dart';
import 'screens/charge_hall_screen.dart';
import 'screens/check_charge_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/archive_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(create: (_) => HallChargeState()),
        ChangeNotifierProvider(create: (_) => SettingsState()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'چک شارژ سالن',
      debugShowCheckedModeBanner: false,

      // تنظیمات راست‌چین و فارسی
      locale: const Locale('fa', 'IR'),
      supportedLocales: const [
        Locale('fa', 'IR'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // تم روشن برنامه
      theme: AppTheme.light(),

      // مسیرهای برنامه
      home: const SplashScreen(nextScreen: HomeScreen()),
      routes: {
        '/charge_hall': (_) => const ChargeHallScreen(),
        '/check_charge': (_) => const CheckChargeScreen(),
        '/archive': (_) => const ArchiveScreen(),
        '/settings': (_) => const SettingsScreen(),
      },
    );
  }
}
