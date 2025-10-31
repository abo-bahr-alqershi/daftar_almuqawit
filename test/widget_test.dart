// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:daftar_almuqawit/app.dart';

void main() {
  testWidgets('App builds and shows splash', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    // Should show splash title in Arabic
    expect(find.text('دفتر المقاوت'), findsOneWidget);
  });
}
