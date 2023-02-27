import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transition_overlay/main.dart';
import 'package:transition_overlay/transition_graph.dart';

void main() {
  testWidgets("smoke test - button pushes new page and pops back",
      (WidgetTester tester) async {
    await tester.pumpWidget(const App());

    expect(find.text("Push"), findsOneWidget);
    await tester.tap(find.text("Push"));
    await tester.pumpAndSettle();

    expect(find.text("Push"), findsNothing);
    expect(find.text("Pop"), findsOneWidget);

    await tester.tap(find.text("Pop"));
    await tester.pumpAndSettle();

    expect(find.text("Push"), findsOneWidget);
    expect(find.text("Pop"), findsNothing);
  });

  testWidgets("transition data is being passed to graph painter",
      (widgetTester) async {
    await widgetTester.pumpWidget(const App());

    await widgetTester.tap(find.text("Push"));
    await widgetTester.pumpAndSettle();

    final customPaint =
        widgetTester.widget(find.byType(CustomPaint).last) as CustomPaint;
    final transitionGraphPainter =
        customPaint.painter as TransitionGraphPainter;

    expect(transitionGraphPainter.flutterTransitionData.isNotEmpty, true);
  });
}
