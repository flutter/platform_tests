// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';

const EventChannel _platformEventChannel =
    const EventChannel('overlay_ios.flutter.io/responder');

void main() {
  runApp(
    CupertinoApp(
      title: 'Flutter Demo',
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
  TextEditingController textController;
  bool toggleValue = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    _platformEventChannel.receiveBroadcastStream().listen((dynamic name) {
      if (name != controlName) setState(() => controlName = name);
    });

    textController = TextEditingController(text: '');
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Center(
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(8.0, 8.0, 8.0, 8.0),
          child: widgetPicker(context),
        ),
      ),
    );
  }

  Widget widgetPicker(BuildContext context) {
    switch (controlName) {
      case 'CupertinoButton':
        return CupertinoButton(
          child: Text('Button'),
          onPressed: () {/** */},
        );

      case 'CupertinoTextField':
        return CupertinoTextField(
          placeholder: "Placeholder",
        );

      case 'CupertinoPicker':
        return CupertinoPicker(
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
        );

      case 'CupertinoSearchTextField':
        return CupertinoSearchTextField(
          controller: textController,
          onChanged: (value) {
            print("The text has changed to: " + value);
          },
          onSubmitted: (value) {
            print("Submitted text: " + value);
          },
        );

      case 'CupertinoFormSectionGroupInsetDemo':
        return Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 100.0, 0.0, 0.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CupertinoFormSection.insetGrouped(
                  header: Text("SECTION 1"),
                  children: [
                    CupertinoTextFormFieldRow(
                      prefix: Text('Enter text'),
                      placeholder: "Enter text",
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter a value';
                        }
                        return null;
                      },
                    ),
                    CupertinoTextFormFieldRow(
                      prefix: Text('Enter text'),
                      placeholder: "Enter text",
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter a value';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
                CupertinoFormSection.insetGrouped(
                  header: Text("SECTION 1"),
                  children: [
                    CupertinoTextFormFieldRow(
                      prefix: Text('Enter text'),
                      placeholder: "Enter text",
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter a value';
                        }
                        return null;
                      },
                    ),
                    CupertinoTextFormFieldRow(
                      prefix: Text('Enter text'),
                      placeholder: "Enter text",
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter a value';
                        }
                        return null;
                      },
                    ),
                    CupertinoFormRow(
                      prefix: Text('Toggle'),
                      child: CupertinoSwitch(
                        value: this.toggleValue,
                        onChanged: (value) {
                          setState(() {
                            this.toggleValue = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 16.0),
                  child: CupertinoButton(
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        showCupertinoDialog(
                          context: context,
                          builder: (context) => CupertinoAlertDialog(
                            title: Text('Validated'),
                            actions: [
                              CupertinoDialogAction(
                                  child: Text('Ok'),
                                  onPressed: () => Navigator.pop(context)),
                            ],
                          ),
                        );
                      }
                    },
                    child: Text('Submit'),
                  ),
                ),
              ],
            ),
          ),
        );

      case 'CupertinoFormSection':
        return Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 100.0, 0.0, 0.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CupertinoFormSection(
                  header: Text("SECTION 1"),
                  children: [
                    CupertinoTextFormFieldRow(
                      prefix: Text('Enter text'),
                      placeholder: "Enter text",
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter a value';
                        }
                        return null;
                      },
                    ),
                    CupertinoTextFormFieldRow(
                      prefix: Text('Enter text'),
                      placeholder: "Enter text",
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter a value';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
                CupertinoFormSection(
                  header: Text("SECTION 1"),
                  children: [
                    CupertinoTextFormFieldRow(
                      prefix: Text('Enter text'),
                      placeholder: "Enter text",
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter a value';
                        }
                        return null;
                      },
                    ),
                    CupertinoTextFormFieldRow(
                      prefix: Text('Enter text'),
                      placeholder: "Enter text",
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter a value';
                        }
                        return null;
                      },
                    ),
                    CupertinoFormRow(
                      prefix: Text('Toggle'),
                      child: CupertinoSwitch(
                        value: this.toggleValue,
                        onChanged: (value) {
                          setState(() {
                            this.toggleValue = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 16.0),
                  child: CupertinoButton(
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        showCupertinoDialog(
                          context: context,
                          builder: (context) => CupertinoAlertDialog(
                            title: Text('Validated'),
                            actions: [
                              CupertinoDialogAction(
                                  child: Text('Ok'),
                                  onPressed: () => Navigator.pop(context)),
                            ],
                          ),
                        );
                      }
                    },
                    child: Text('Submit'),
                  ),
                ),
              ],
            ),
          ),
        );

      case "CupertinoActivityIndicator":
        return CupertinoActivityIndicator();

      case "CupertinoSliverNavigationBar":
        return CustomScrollView(
          slivers: [
            CupertinoSliverNavigationBar(
              largeTitle: Text("Title"),
              backgroundColor: CupertinoColors.white,
              stretch: true,
              border: null,
            ),
          ],
        );

      default:
        break;
    }
    return null;
  }
}
