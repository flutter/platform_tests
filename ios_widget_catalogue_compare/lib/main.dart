// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';

const EventChannel _platformEventChannel =
    const EventChannel('overlay_ios.flutter.io/responder');

void main() {
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FlutterDemo(),
    ),
  );
}

class FlutterDemo extends StatefulWidget {
  FlutterDemo({Key key}) : super(key: key);

  @override
  _FlutterDemoState createState() => _FlutterDemoState();
}

class _FlutterDemoState extends State<FlutterDemo> {
  String controlName = 'Null';

  @override
  void initState() {
    super.initState();

    _platformEventChannel.receiveBroadcastStream().listen((dynamic name) {
      if (name != controlName) setState(() => controlName = name);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[Align(child: widgetForKey(controlName))],
      ),
    );
  }

  Widget widgetForKey(String key) {
    Map<String, Widget> map = {
      'CupertinoButton': CupertinoButton(
        child: Text('Button'),
        onPressed: () {/** */},
      ),
      'CupertinoTextField': CupertinoTextField(
        placeholder: "Placeholder",
      ),
      'CupertinoPicker': CupertinoPicker(
        scrollController: FixedExtentScrollController(initialItem: 3),
        magnification: 1.2,
        useMagnifier: true,
        itemExtent: 32.0,
        onSelectedItemChanged: (value) {},
        children: const [
          Text('One'),
          Text('Two'),
          Text('Three'),
          Text('Four'),
          Text('Five'),
        ],
      )
    };
    return map[key];
  }
}
