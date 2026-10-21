import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overlay_ios/main.dart';

void main() {
  // The names the native overlay sends (the keys of controlDictionary in
  // ios/Runner/OverlaySwiftUIView.swift), each with the widget type that
  // widgetPicker builds for it. Add an entry when adding a control.
  const controls = <String, Type>{
    'CupertinoButton': CupertinoButton,
    'CupertinoTextField': CupertinoTextField,
    'CupertinoPicker': CupertinoPicker,
    'CupertinoSearchTextField': CupertinoSearchTextField,
    'CupertinoFormSectionGroupInsetDemo': CupertinoFormSection,
    'CupertinoFormSection': CupertinoFormSection,
    'CupertinoActivityIndicator': CupertinoActivityIndicator,
    'CupertinoSliverNavigationBar': CupertinoSliverNavigationBar,
    'CupertinoSwitch': CupertinoSwitch,
    'CupertinoSlidingSegmentedControl': CupertinoSlidingSegmentedControl<int>,
  };

  testWidgets('shows no control until the platform selects one', (
    WidgetTester tester,
  ) async {
    await _pumpCatalog(tester);
    for (final Type widgetType in controls.values) {
      expect(find.byType(widgetType), findsNothing);
    }
  });

  for (final MapEntry(key: controlName, value: widgetType)
      in controls.entries) {
    testWidgets('shows $controlName when the platform selects it', (
      WidgetTester tester,
    ) async {
      await _pumpCatalog(tester, controlName: controlName);
      expect(find.byType(widgetType), findsWidgets);
    });
  }
}

/// Pumps the catalog with a mock of the native overlay.
///
/// If `controlName` is given, the mock selects it the way the native overlay
/// does, by sending the name over the `overlay_ios.flutter.io/responder`
/// event channel.
Future<void> _pumpCatalog(WidgetTester tester, {String? controlName}) async {
  const channel = EventChannel('overlay_ios.flutter.io/responder');
  tester.binding.defaultBinaryMessenger.setMockStreamHandler(
    channel,
    MockStreamHandler.inline(
      onListen: (Object? arguments, MockStreamHandlerEventSink events) {
        if (controlName != null) {
          events.success(controlName);
        }
      },
    ),
  );
  // Remove the mock so it can't leak into the next test.
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockStreamHandler(
      channel,
      null,
    ),
  );
  await tester.pumpWidget(const CupertinoApp(home: FlutterDemo()));
  // Build the frame that a received name schedules. Note we can't use
  // pumpAndSettle because CupertinoActivityIndicator animates forever.
  await tester.pump();
}
