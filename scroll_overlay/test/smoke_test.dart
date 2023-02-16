import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:scroll_overlay/main.dart';

void main() {
  testWidgets('smoke test - app runs, and a fling flings', (WidgetTester tester) async {
    await tester.pumpWidget(DemoApp());
    await tester.pumpAndSettle();
    await tester.fling(find.text('Flutter 5'), const Offset(0, -500), 8000);
    await tester.pumpAndSettle();
    expect(flutterScrollIndex(), greaterThanOrEqualTo(70));
  });
}

int flutterScrollIndex() {
  final RegExp pattern = RegExp(r'Flutter (\d+)');
  final Element item = find.textContaining(pattern).evaluate().first;
  final String itemText = (item.widget as Text).data!;
  return int.parse(pattern.matchAsPrefix(itemText)!.group(1)!);
}
