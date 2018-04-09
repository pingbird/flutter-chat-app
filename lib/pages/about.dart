import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/licenses.dart';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => new _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) => new Scaffold(
    body: new GestureDetector(child: new DecoratedBox(decoration: new BoxDecoration(
      gradient: new LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.lightBlue,
          Colors.purple,
        ]
      ),
    ), child: new Padding(padding: const EdgeInsets.all(32.0), child: new Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        new Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text("DashChat", style: const TextStyle(
            color: Colors.white,
            fontSize: 55.0,
            fontFamily: "PT",
          )),
        ]),
        const Text("Created by PixelToast", style: const TextStyle(
          color: Colors.white,
          fontSize: 16.0,
          fontFamily: "PT",
        )),
        new SizedBox(width: 50.0, child: const Divider(color: Colors.white)),
        const Text("Made in Flutter", style: const TextStyle(
          color: Colors.white,
          fontSize: 16.0,
          fontFamily: "PT",
        )),
      ]
    ))), onTap: () {
      Navigator.of(context).pop();
    }),
  );
}
