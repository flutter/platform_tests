import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:transition_overlay/first_page.dart';
import 'package:transition_overlay/time_dilation_provider.dart';
import 'package:transition_overlay/transition_data_provider.dart';
import 'package:transition_overlay/transition_graph.dart';

const EventChannel platformEventChannel =
    EventChannel('overlay_ios.flutter.io/responder');

const MethodChannel platformMethodChannel =
    MethodChannel('overlay_ios.flutter.io/sender');

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return TimeDilationProvider(
      child: TransitionDataProvider(
        child: Stack(
          alignment: Alignment.topRight,
          children: const [
            CupertinoApp(
              title: 'Cupertino App',
              theme: CupertinoThemeData(
                brightness: Brightness.light,
              ),
              home: FirstPage(),
            ),
            TransitionGraph(),
          ],
        ),
      ),
    );
  }
}
