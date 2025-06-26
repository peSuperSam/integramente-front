// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:integramente/main.dart';

void main() {
  testWidgets('IntegraMente smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const IntegraMenteApp());

    // Verify that our app shows the correct description
    expect(find.text('Aplicativo educacional para Cálculo II'), findsOneWidget);

    // Verify that we have the calculate icon
    expect(find.byIcon(Icons.calculate), findsOneWidget);

    // Verify that we have an AppBar
    expect(find.byType(AppBar), findsOneWidget);

    // Verify that the app renders correctly
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
