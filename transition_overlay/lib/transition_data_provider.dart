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

  void addFlutterData(double data) {
    flutterData.add(data);

    notifyListeners();
  }

  void addIosData(double data) {
    iosData.add(data);

    notifyListeners();
  }

  void clear() {
    flutterData.clear();
    iosData.clear();

    notifyListeners();
  }
}

class TransitionConfiguration extends ChangeNotifier {
  double resolution = 6;
  int screenRefreshRate = 60;
  Duration frameTime = const Duration(milliseconds: 16, microseconds: 666);
  StreamSubscription<dynamic>? stream;

  void setResolution(double resolution) {
    this.resolution = resolution;

    notifyListeners();
  }

  void startTransitionReportingFor({
    required GlobalKey pageKey,
    required BuildContext context,
  }) {
    frameTime = Duration(
        milliseconds: (1 / screenRefreshRate).floor(),
        microseconds: ((1 / screenRefreshRate) * 1000000).truncate() % 1000000);

    final screenWidth = MediaQuery.of(context).size.width;

    stream = Stream.periodic(frameTime).listen((event) {
      final secondPageRenderObject =
          pageKey.currentContext?.findRenderObject() as RenderBox?;

      final secondPagePosition =
          secondPageRenderObject?.localToGlobal(Offset.zero);

      if (secondPagePosition != null) {
        final delta = (screenWidth - secondPagePosition.dx) / screenWidth;

        // Checking if delta is 1.0 to avoid sudden jumps in
        // the graph at start or end of a transition
        if (delta != 1.0) {
          TransitionDataProvider.of(pageKey.currentContext!)!
              .transitionData
              .addFlutterData(delta);
        }
      }
    });
  }
}
