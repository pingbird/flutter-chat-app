import 'package:flutter/material.dart';
import 'package:speed1/pages/about.dart';
import 'package:speed1/pages/friends.dart';
import 'package:speed1/pages/home.dart';
import 'package:speed1/pages/settings.dart';
import 'package:speed1/pages/setup.dart';

void main() {
  runApp(new MyApp());
}

GlobalKey<_MyAppState> appStateKey = new GlobalKey(debugLabel: "app");
GlobalKey<NavigatorState> appNavigatorKey = new GlobalKey(debugLabel: "nav");

class MyApp extends StatefulWidget {
  MyApp() : super(key: appStateKey);
  createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  build(BuildContext context) {
    return new MaterialApp(
      navigatorKey: appNavigatorKey,
      title: 'DashChat',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new SetupPage(),
      initialRoute: "setup",
      routes: {
        "setup": (ctx) => new SetupPage(),
        "home": (ctx) => new HomePage(),
        "settings": (ctx) => new SettingsPage(),
        "about": (ctx) => new AboutPage(),
        "licenses": (ctx) => new LicensePage(),
        "friends": (ctx) => new FriendsPage(),
      },
    );
  }
}