// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

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
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new ListView.builder(
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
    );
  }
}
