// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:palqarbot_app/main.dart';

void main() {
  testWidgets('Home screen shows four labeled tabs and switches tabs', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PalqarbotApp());

    final navigation = find.byType(NavigationBar);
    for (final label in ['Inbox', 'Leads', 'Bot', 'Settings']) {
      expect(
        find.descendant(of: navigation, matching: find.text(label)),
        findsOneWidget,
      );
    }

    for (var index = 0; index < 4; index++) {
      await tester.tap(
        find.descendant(
          of: navigation,
          matching: find.text(['Inbox', 'Leads', 'Bot', 'Settings'][index]),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.widget<NavigationBar>(navigation).selectedIndex, index);
    }
  });
}
