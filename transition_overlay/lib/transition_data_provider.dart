import 'dart:async';

import 'package:flutter/cupertino.dart';

class TransitionDataProvider extends InheritedWidget {
  TransitionDataProvider({super.key, required super.child});

  final TransitionData transitionData = TransitionData();
  final TransitionConfiguration transitionConfiguration =
      TransitionConfiguration();

  static TransitionDataProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<TransitionDataProvider>();
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return oldWidget != this;
  }
}

class TransitionData extends ChangeNotifier {
  final List<double> flutterData = [];
  final List<double> iosData = [];
  StreamSubscription<dynamic>? stream;

  void addFlutterData(double data) {
    flutterData.add(data);

    notifyListeners();
  }

  void addIosData(double data) {
    iosData.add(data);

    notifyListeners();
  }

  void clearData() {
    flutterData.clear();
    iosData.clear();

    notifyListeners();
  }

  void startTransitionReportingFor({
    required GlobalKey pageKey,
    required BuildContext context,
  }) {
    clearData();
    final screenWidth = MediaQuery.of(context).size.width;

    stream?.cancel();
    stream = Stream.periodic(TransitionDataProvider.of(context)!
            .transitionConfiguration
            .frameTime)
        .listen((event) {
      final secondPageRenderObject =
          pageKey.currentContext?.findRenderObject() as RenderBox?;

      final secondPagePosition =
          secondPageRenderObject?.localToGlobal(Offset.zero);

      if (secondPagePosition != null) {
        final delta = (screenWidth - secondPagePosition.dx) / screenWidth;

        // Checking if delta is 1.0 to avoid sudden jumps in
        // the graph at start or end of a transition
        if (delta != 1.0) {
          addFlutterData(delta);
        }
      }
    });
  }

  void stopTransitionReporting() {
    stream?.cancel();
  }
}

class TransitionConfiguration extends ChangeNotifier {
  double resolution = 6;
  int screenRefreshRate = 60;
  Duration frameTime = const Duration(milliseconds: 16, microseconds: 666);

  void setResolution(double resolution) {
    this.resolution = resolution;

    notifyListeners();
  }

  void setScreenRefreshRate(int screenRefreshRate) {
    this.screenRefreshRate = screenRefreshRate;

    frameTime = Duration(
        milliseconds: (1 / screenRefreshRate).floor(),
        microseconds: ((1 / screenRefreshRate) * 1000000).truncate() % 1000000);
  }
}
