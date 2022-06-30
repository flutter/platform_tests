import 'package:flutter_test/flutter_test.dart';
import 'package:tabs_overlay/main.dart';

void main() {
  testWidgets('smoke test - app runs and can swipe the tabs',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    await tester.fling(
        find.text('Flutter tab 1'), const Offset(-300.0, 0.0), 1000.0);
    expect(find.text('Flutter tab 2'), findsOneWidget);
  });
}
