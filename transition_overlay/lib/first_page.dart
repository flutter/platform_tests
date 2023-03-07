import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:transition_overlay/main.dart';
import 'package:transition_overlay/transition_controller_nav_bar.dart';
import 'package:transition_overlay/transition_data_provider.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  final secondPageKey = GlobalKey(debugLabel: 'secondPageKey');
  TransitionDataProvider? transitionDataProviderRef;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    transitionDataProviderRef = TransitionDataProvider.of(context);
  }

  @override
  void initState() {
    super.initState();

    platformEventChannel.receiveBroadcastStream().listen((dynamic message) {
      if (message is String) {
        if (message.contains("maximum refresh rate:")) {
          final screenRefreshRate = int.parse(message.split(":").last);

          if (screenRefreshRate > 60) {
            if (kDebugMode) {
              transitionDataProviderRef?.transitionConfiguration
                  .setScreenRefreshRate(screenRefreshRate);

              print(
                  "detected $screenRefreshRate hz refresh rate, enabling enhanced transition reporting");
            }
          }
        }
      } else if (message is double && message != 1.0) {
        transitionDataProviderRef?.transitionData.addIosData(message);
      }
    });
  }

  @override
  void dispose() {
    transitionDataProviderRef?.transitionData.stopTransitionReporting();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: TransitionControllerNavBar(secondPageKey: secondPageKey),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Spacer(),
            Text("Flutter"),
            Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}
