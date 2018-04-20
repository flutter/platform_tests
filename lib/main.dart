// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

const EventChannel _platformVelocityEventChannel =
    const EventChannel('scroll_overlay.flutter.io/velocity');

void main() {
  runApp(
    new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new FlutterDemo(),
    ),
  );
}

class FlutterDemo extends StatefulWidget {
  FlutterDemo({Key key}) : super(key: key);

  @override
  _FlutterDemoState createState() => new _FlutterDemoState();
}

class _FlutterDemoState extends State<FlutterDemo> {
  double flutterFlingVelocity;
  double platformFlingVelocity;
  InstrumentingScrollPhysics instrumentingPhysics;

  @override
  void initState() {
    super.initState();
    instrumentingPhysics = new InstrumentingScrollPhysics(velocityListener: (double velocity) {
      SchedulerBinding.instance.addPostFrameCallback((Duration timestamp) {
        if (velocity != flutterFlingVelocity)
          setState(() => flutterFlingVelocity = velocity);
      });
    });
    _platformVelocityEventChannel.receiveBroadcastStream().listen((dynamic velocity) {
      if (velocity != platformFlingVelocity)
        setState(() => platformFlingVelocity = velocity);
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Stack(
        children: <Widget>[
          new ListView.builder(
            physics: instrumentingPhysics,
            itemCount: 1000,
            itemExtent: 40.0,
            itemBuilder: (BuildContext context, int index) {
              return new Container(
                decoration: new BoxDecoration(
                  border: new Border.all(
                    color: const Color(0xFF666666),
                    width: 0.0,
                  ),
                ),
                child: new Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    new Padding(
                      padding: const EdgeInsets.only(left: 100.0),
                      child: new Text(
                        'Flutter $index',
                        style: const TextStyle(fontSize: 16.0),
                      ),
                    ),
                  ],
                )
              );
            },
          ),
          new Align(
            alignment: FractionalOffset.centerRight,
            child: DefaultTextStyle.merge(
              style: const TextStyle (fontSize: 18.0),
              child: new Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Text('Flutter velocity\n${flutterFlingVelocity?.round()?.abs() ?? ""}'),
                  new Text('Platform velocity\n${platformFlingVelocity?.round()?.abs() ?? ""}'),
                ],
              ),
            )
          ),
        ],
      ),
    );
  }
}

typedef void VelocityListener(double velocity);

/// A ScrollPhysics that passes along its ballistic simulation's initial velocity.
class InstrumentingScrollPhysics extends ScrollPhysics {
  InstrumentingScrollPhysics({this.velocityListener, ScrollPhysics parent})
      : super(parent: parent);

  final VelocityListener velocityListener;

  @override
  InstrumentingScrollPhysics applyTo(ScrollPhysics ancestor) {
    return new InstrumentingScrollPhysics(
      velocityListener: velocityListener,
      parent: buildParent(ancestor),
    );
  }

  @override
  Simulation createBallisticSimulation(ScrollMetrics position, double velocity) {
    velocityListener?.call(velocity);
    return super.createBallisticSimulation(position, velocity);
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    velocityListener?.call(null);
    return super.applyPhysicsToUserOffset(position, offset);
  }
}
