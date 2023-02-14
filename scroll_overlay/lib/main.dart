// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const EventChannel _platformVelocityEventChannel = EventChannel('scroll_overlay.flutter.io/velocity');

void main() {
  runApp(DemoApp());
}

class DemoApp extends StatelessWidget {
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const FlutterDemo(),
    );
  }
}

class FlutterDemo extends StatefulWidget {
  const FlutterDemo({super.key});

  @override
  _FlutterDemoState createState() => _FlutterDemoState();
}

class _FlutterDemoState extends State<FlutterDemo> {
  /// The base item extent at 0 index.
  ///
  /// Each item will have an extent = this + index.
  static const int baseItemExtent = 40;

  double flutterVelocity = 0;
  double platformVelocity = 0;
  final ScrollController controller = ScrollController();
  double? oldOffset;
  Duration? oldTimeStamp;

  void _setStateNextFrame(void Function() fn) {
    WidgetsBinding.instance.scheduleFrameCallback((_) {
      setState(fn);
    });
  }

  @override
  void initState() {
    super.initState();

    // Compute the velocity after each frame completes.
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // This initState call could itself be within a persistent frame callback,
      // when driven by flutter_test.  So we defer adding another.
      WidgetsBinding.instance.addPersistentFrameCallback((timeStamp) {
        if (oldOffset != null) {
          final timeDelta = (timeStamp - oldTimeStamp!).inMicroseconds;
          if (timeDelta == 0)
            return;
          final double delta = controller.offset - oldOffset!;
          final double velocity = delta / timeDelta * 1e6;
          if (velocity != flutterVelocity) {
            _setStateNextFrame(() {
              flutterVelocity = velocity;
            });
          }
        }
        oldOffset = controller.offset;
        oldTimeStamp = timeStamp;
      });
    });

    // Record the platform velocity whenever the platform code sends it.
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
              child: Padding(padding: EdgeInsets.only(right: 16),
                child: SizedBox(
                    width: 240,
                    child: VelocityOverlay(
                      flutterVelocity: flutterVelocity,
                      platformVelocity: platformVelocity,
                    ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class VelocityOverlay extends StatelessWidget {
  const VelocityOverlay({
    super.key,
    required this.flutterVelocity,
    required this.platformVelocity,
  });

  final double flutterVelocity;
  final double platformVelocity;

  @override
  Widget build(BuildContext context) {
    final ratio = platformVelocity == 0
        ? flutterVelocity == 0
            ? 1
            : null
        : flutterVelocity / platformVelocity;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text('Velocity:'),

        SizedBox(height: 8),
        NumberRow(label: 'Flutter', value: flutterVelocity),
        VelocityBar(value: flutterVelocity, scale: 8000),

        SizedBox(height: 8),
        NumberRow(label: 'Platform', value: platformVelocity),
        VelocityBar(value: platformVelocity, scale: 8000),

        SizedBox(height: 8),
        NumberRow(label: 'Difference', value: flutterVelocity - platformVelocity),
        VelocityBar(value: flutterVelocity - platformVelocity, scale: 800),

        SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(child: Text('Ratio')), Text(ratio?.toStringAsFixed(2) ?? "∞")
        ]),
        VelocityBar(value: ((ratio ?? 1e9) - 1), scale: 1),
      ],
    );
  }
}

class NumberRow extends StatelessWidget {
  const NumberRow({super.key, required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Expanded(child: Text(label)),
      Text(value.round().abs().toString())
    ]);
  }
}

/// A horizontal bar showing a signed value.
class VelocityBar extends StatelessWidget {
  const VelocityBar({super.key, required this.value, required this.scale});

  final double value;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final scaled = value / scale;
    final align = scaled / (2 - scaled.abs());
    return FractionallySizedBox(
      widthFactor: scaled.abs() / 2,
      alignment: AlignmentDirectional(align, 0),
      child: SizedBox(height: 4, child: ColoredBox(color: Colors.blue)),
    );
  }
}
