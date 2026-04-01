import 'package:carwash_app/features/shared/presentation/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('SplashScreen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));

    // The app should show the SplashScreen initially during initialization
    // SplashScreen contains 'KREW' text
    expect(find.text('KREW'), findsOneWidget);
    expect(find.text('CAR WASH'), findsOneWidget);
  });
}
