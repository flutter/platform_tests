// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const EventChannel _platformVelocityEventChannel = EventChannel('scroll_overlay.flutter.io/velocity');

void main() {
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const FlutterDemo(),
    ),
  );
}

class FlutterDemo extends StatefulWidget {
  const FlutterDemo({Key? key}) : super(key: key);

  @override
  _FlutterDemoState createState() => _FlutterDemoState();
}

class _FlutterDemoState extends State<FlutterDemo> {
  double? flutterVelocity;
  double? platformVelocity;
  final ScrollController controller = ScrollController();
  late Timer velocityTimer;
  static const Duration velocityTimerInverval = Duration(milliseconds: 1000 ~/ ticksPerSecond);
  static const int ticksPerSecond = 25;
  double? oldOffset;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      velocityTimer = Timer.periodic(velocityTimerInverval, (timer) {
        if (oldOffset != null) {
          final double delta = controller.offset - oldOffset!;
          final double velocity = delta * ticksPerSecond;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          ListView.builder(
            controller: controller,
            itemCount: 1000,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                height: (40 + index).toDouble(),
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
