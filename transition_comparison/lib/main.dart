import 'package:flutter/cupertino.dart';

void main() {
  runApp(CupertinoApp(
    home: AppWidget(),
  ));
}

class AppWidget extends StatelessWidget {
  @override 
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        child: new Container(
            decoration: new BoxDecoration(
              image: new DecorationImage(
                image: new AssetImage("image_test.jpg"),
                fit: BoxFit.fill,
              ),
            ),
            child: Center(
              child: CupertinoButton(
                child: Text(
                  'Press for next page',
                  style: TextStyle(fontSize: 20, color: Color.fromRGBO(0, 0, 0, 1), fontWeight: FontWeight.bold),
                ),
                onPressed: () => Navigator.of(context).push(CupertinoPageRoute(
                    builder: (context) => CupertinoPageScaffold(
                          backgroundColor: Color.fromRGBO(0, 255, 0, 1),
                          child: Text(''),
                        ))),
              ),
            )));
  }
}
