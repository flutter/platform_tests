import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const List<Tab> myTabs = <Tab>[
    Tab(text: 'Tab 1'),
    Tab(text: 'Tab 2'),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App',
      home: Scaffold(
        body: DefaultTabController(
          length: myTabs.length,
          child: Scaffold(
            appBar: AppBar(
              bottom: const TabBar(
                tabs: myTabs,
                indicatorPadding: EdgeInsets.only(bottom: 5),
                indicatorColor: Colors.white,
                indicatorWeight: 5,
              ),
            ),
            body: TabBarView(
              children: myTabs.map((Tab tab) {
                final String label = tab.text!.toLowerCase();
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 40.0),
                    child: Text('Flutter $label'),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
