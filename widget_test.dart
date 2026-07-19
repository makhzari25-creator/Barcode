// This is a basic Flutter widget test for the barcode warehouse app.
//
// To perform an interaction with a widget in a test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:barcode_warehouse/main.dart';

void main() {
  testWidgets('App smoke test - shows login page', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: BarcodeWarehouseApp()));

    // Verify that the login page renders.
    await tester.pump();
    expect(find.text('تأیید بارکد انبار'), findsWidgets);
  });
}
