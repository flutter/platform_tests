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

  testWidgets('VelocityOverlay - handles diverse values without error', (WidgetTester tester) async {
    Future<void> checkWidget(Widget widget) async {
      await tester.pumpWidget(Directionality(textDirection: TextDirection.ltr, child: widget));
      await tester.pumpAndSettle();
    }
    await checkWidget(VelocityOverlay(flutterVelocity: 0, platformVelocity: 0));
    await checkWidget(VelocityOverlay(flutterVelocity: 8000, platformVelocity: 0));
    await checkWidget(VelocityOverlay(flutterVelocity: 0, platformVelocity: 10000));
  });
}

int flutterScrollIndex() {
  final RegExp pattern = RegExp(r'Flutter (\d+)');
  final Element item = find.textContaining(pattern).evaluate().first;
  final String itemText = (item.widget as Text).data!;
  return int.parse(pattern.matchAsPrefix(itemText)!.group(1)!);
}
