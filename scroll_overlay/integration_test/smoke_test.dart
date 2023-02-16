import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:scroll_overlay/main.dart' as app;

import '../test/smoke_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('smoke test - app runs, and a fling flings', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();
    await tester.fling(find.text('Flutter 15'), const Offset(0, -500), 8000);
    await tester.pumpAndSettle();
    expect(flutterScrollIndex(), greaterThanOrEqualTo(70));
  });
}
