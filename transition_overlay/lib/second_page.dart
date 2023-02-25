import 'package:flutter/cupertino.dart';
import 'package:transition_overlay/transition_controller_nav_bar.dart';

class SecondPage extends StatelessWidget {
  const SecondPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGreen,
      navigationBar: TransitionControllerNavBar(
        isForSecondPage: true,
        secondPageKey: key as GlobalKey?,
      ),
      child: const SizedBox(),
    );
  }
}
