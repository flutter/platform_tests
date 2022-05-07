import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:tabs_overlay/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('smoke test - app runs and can swipe the tabs',
      (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();
    await tester.fling(
        find.text('Flutter tab 1'), const Offset(-300.0, 0.0), 1000.0);
    expect(find.text('Flutter tab 2'), findsOneWidget);
  });
}
