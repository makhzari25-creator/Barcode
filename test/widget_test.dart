import 'package:check_hall_charge/models/product.dart';
import 'package:check_hall_charge/screens/home_screen.dart';
import 'package:check_hall_charge/screens/settings_screen.dart';
import 'package:check_hall_charge/services/app_state.dart';
import 'package:check_hall_charge/services/hall_charge_state.dart';
import 'package:check_hall_charge/services/settings_state.dart';
import 'package:check_hall_charge/theme/app_theme.dart';
import 'package:check_hall_charge/theme/app_colors.dart';
import 'package:check_hall_charge/widgets/progress_header.dart';
import 'package:check_hall_charge/widgets/scan_result_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _wrap(Widget child) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AppState()),
      ChangeNotifierProvider(create: (_) => HallChargeState()),
      ChangeNotifierProvider(create: (_) => SettingsState()),
    ],
    child: MaterialApp(
      theme: AppTheme.light(),
      locale: const Locale('fa', 'IR'),
      builder: (context, c) =>
          Directionality(textDirection: TextDirection.rtl, child: c!),
      home: child,
    ),
  );
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('صفحه اصلی دو دکمه و دسترسی به تنظیمات را نشان می‌دهد',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_wrap(const HomeScreen()));
    await tester.pumpAndSettle();

    expect(find.text('چک شارژ سالن'), findsOneWidget);
    expect(find.text('شارژ سالن'), findsWidgets);
    expect(find.text('چک کردن شارژ'), findsWidgets);
    expect(find.text('فایلی بارگذاری نشده'), findsNWidgets(2));
    expect(find.byIcon(Icons.settings_rounded), findsOneWidget);
  });

  testWidgets('تنظیمات: کلید صدا ذخیره می‌شود', (tester) async {
    await tester.pumpWidget(_wrap(const SettingsScreen()));
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(SettingsScreen));
    final settings = context.read<SettingsState>();
    expect(settings.soundEnabled, isTrue);

    await tester.tap(find.text('صدای تایید و رد'));
    await tester.pumpAndSettle();
    expect(settings.soundEnabled, isFalse);
  });

  testWidgets('هدر پیشرفت اعداد فارسی و درصد را نشان می‌دهد', (tester) async {
    await tester.pumpWidget(_wrap(const Scaffold(
      body: ProgressHeader(done: 36, total: 128, progress: 36 / 128),
    )));
    expect(find.text('۳۶ از ۱۲۸ کالا'), findsOneWidget);
    expect(find.text('۲۸٪'), findsOneWidget);
  });

  testWidgets('کارت نتیجه: موفق با شمارنده و خطا برای کد ناشناخته',
      (tester) async {
    final product = Product(code: '123', title: 'پیراهن', requiredCount: 6);

    await tester.pumpWidget(_wrap(Scaffold(
      body: ScanResultCard(
        accent: AppColors.primary,
        feedback: ScanFeedback(
          kind: FeedbackKind.success,
          title: 'اسکن شد',
          code: '123',
          product: product,
          scanned: 3,
          required: 6,
        ),
      ),
    )));
    expect(find.text('اسکن شد'), findsOneWidget);
    expect(find.text('پیراهن'), findsOneWidget);
    expect(find.text('۳ از ۶'), findsOneWidget);

    await tester.pumpWidget(_wrap(const Scaffold(
      body: ScanResultCard(
        accent: AppColors.primary,
        feedback: ScanFeedback(
          kind: FeedbackKind.error,
          title: 'این کالا در شارژ سالن نیست',
          code: '999',
        ),
      ),
    )));
    expect(find.text('این کالا در شارژ سالن نیست'), findsOneWidget);
    expect(find.textContaining('پیدا نشد'), findsOneWidget);
  });

  testWidgets('کارت نتیجه پیش از اولین اسکن راهنما می‌دهد', (tester) async {
    await tester.pumpWidget(_wrap(const Scaffold(
      body: ScanResultCard(feedback: null, accent: AppColors.hall),
    )));
    expect(find.textContaining('بارکد کالا را اسکن کنید'), findsOneWidget);
  });
}
