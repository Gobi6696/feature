import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:feature/main.dart';

void main() {
  testWidgets('App dashboard loading test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the DashboardScreen header elements exist.
    expect(find.text('TN Dam Tracker'), findsOneWidget);
    expect(find.text('Daily Updates'), findsOneWidget);

    // Verify that a progress indicator is shown initially during loading
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Advance clock by 1 second to resolve the 800ms mock delay timer
    await tester.pump(const Duration(seconds: 1));
  });
}
