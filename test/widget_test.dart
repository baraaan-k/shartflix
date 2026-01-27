// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:shartflix/app/app_shell.dart';

void main() {
  testWidgets('App shell shows home tab by default',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: AppShell()));

    expect(find.text('Home'), findsOneWidget);

    await tester.tap(find.text('Profile'));
    await tester.pump();
    expect(find.text('Profile'), findsWidgets);
  });
}
