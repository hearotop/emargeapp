// Basic smoke test for the app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:namer_app/main.dart';

void main() {
  testWidgets('App starts on the home page', (WidgetTester tester) async {
    await tester.pumpWidget(const NavigationBarApp());

    expect(find.text('首页'), findsWidgets);
  });
}
