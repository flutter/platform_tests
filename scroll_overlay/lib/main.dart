// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const EventChannel _platformVelocityEventChannel = EventChannel('scroll_overlay.flutter.io/velocity');

void main() {
  runApp(DemoApp(
    // EDIT HERE if you want to experiment with a custom [ScrollPhysics].
    physics: null,
  ));
}

class DemoApp extends StatelessWidget {
  const DemoApp({super.key, this.physics});

  /// The scroll physics to apply on top of the default.
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FlutterDemo(physics: physics),
    );
  }
}

class FlutterDemo extends StatefulWidget {
  const FlutterDemo({super.key, this.physics});

  /// The scroll physics to apply on top of the default.
  final ScrollPhysics? physics;

  @override
  _FlutterDemoState createState() => _FlutterDemoState();
}

class _FlutterDemoState extends State<FlutterDemo> {
  /// How many times the velocity is measured per second.
  ///
  /// Setting this to not too small value - to get a meaningful velocity information,
  /// and not too big - to distinguish individual digits after thousands.
  static const int measurementsPerSecond = 25;
  static const Duration velocityTimerInverval = Duration(milliseconds: 1000 ~/ measurementsPerSecond);

  /// The base item extent at 0 index.
  ///
  /// Each item will have an extent = this + index.
  static const int baseItemExtent = 40;

  double? flutterVelocity;
  double? platformVelocity;
  final ScrollController controller = ScrollController();
  late Timer velocityTimer;
  double? oldOffset;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      velocityTimer = Timer.periodic(velocityTimerInverval, (timer) {
        if (oldOffset != null) {
          final double delta = controller.offset - oldOffset!;
          final double velocity = delta * measurementsPerSecond;
          if (velocity != flutterVelocity) {
            setState(() {
              flutterVelocity = velocity;
            });
          }
        }
        oldOffset = controller.offset;
      });
    });
    _platformVelocityEventChannel.receiveBroadcastStream().listen((dynamic velocity) {
      if (velocity != platformVelocity) {
        setState(() {
          platformVelocity = velocity / MediaQuery.of(context).devicePixelRatio;
        });
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    velocityTimer.cancel();
    super.dispose();
  }

  ScrollPhysics getScrollPhysics(BuildContext context) {
    final parent = ScrollConfiguration.of(context).getScrollPhysics(context);
    final custom = widget.physics;
    final physics = custom != null ? custom.applyTo(parent) : parent;
    return DebugScrollPhysics().applyTo(physics);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          ListView.builder(
            controller: controller,
            itemCount: 1000,
            physics: getScrollPhysics(context),
            itemBuilder: (BuildContext context, int index) {
              return Container(
                height: (baseItemExtent + index).toDouble(),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF666666),
                    width: 0.0,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 100.0),
                      child: Text(
                        'Flutter $index',
                        style: const TextStyle(fontSize: 16.0),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Align(
            alignment: FractionalOffset.centerRight,
            child: DefaultTextStyle.merge(
              style: const TextStyle (fontSize: 18.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Flutter velocity\n${flutterVelocity?.round().abs() ?? ""}'),
                  Text('Platform velocity\n${platformVelocity?.round().abs() ?? ""}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const bool debugPrintCreateBallisticSimulation = true;

/// A [ScrollPhysics] that just forwards to its [parent], plus debug logging.
///
/// This prints debug log messages on key method calls that are expected to be
/// of interest for anyone investigating scrolling behavior.
class DebugScrollPhysics extends ScrollPhysics {
  const DebugScrollPhysics({super.parent});

  @override
  DebugScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return DebugScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {
    if (debugPrintCreateBallisticSimulation) {
      debugPrint(
          "createBallisticSimulation: velocity ${velocity.toStringAsFixed(1)}" +
              ", offset ${position.pixels.toStringAsFixed(1)}" +
              ", range ${position.minScrollExtent.toStringAsFixed(1)}..${position.maxScrollExtent.toStringAsFixed(1)}");
    }
    return super.createBallisticSimulation(position, velocity);
  }
}
