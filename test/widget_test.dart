// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

// import 'package:flutter/material.dart';
// Commenting out for testing
import 'package:flutter_test/flutter_test.dart';

import 'package:divvy/main.dart';

void main() {
  testWidgets('Find title in AppBar', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AuthWrapper());

    // Testing if there is an app bar
    expect(find.text('Divvy'), findsOneWidget);
  });
}
