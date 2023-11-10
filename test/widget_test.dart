import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rakshak/main.dart';

void main() {
  testWidgets('MyApp UI test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the text 'Rakshak' is present in the app.
    expect(find.text('Rakshak'), findsOneWidget);

    // You can add more test cases based on your app's UI elements.
  });
}
