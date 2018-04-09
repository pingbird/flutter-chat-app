import 'package:flutter/material.dart';
import 'package:speed1/account.dart';
import 'package:speed1/common.dart';
import 'package:speed1/main.dart';

class SettingsPage extends StatefulWidget {
  createState() => new _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  build(BuildContext context) => new Scaffold(
    appBar: new GradientAppBar(
      text: "Settings",
      colors: [
        Colors.orange,
        Colors.red,
      ],
      leading: new IconButton(icon: new Icon(Icons.arrow_back), onPressed: () {
        Navigator.of(context).pop();
      }),
      actions: [
        new Padding(padding: const EdgeInsets.only(left: 48.0))
      ],
    ),
    body: new ListView(children: [
      new ListTile(
        leading: new Icon(Icons.notifications),
        title: new Text("Enable notifications"),
        trailing: new ColorSwitch(
          colorFrom: Colors.blueGrey,
          colorTo: Colors.orange,
          state: settings.enableNotifications,
        ),
        onTap: () {
          settings.enableNotifications = !settings.enableNotifications;
          setState(() {});
        },
      ),
      
      new ListTile(
        leading: new Icon(Icons.notifications),
        title: new Text("Notify when mentioned"),
        trailing: new ColorSwitch(
          colorFrom: Colors.blueGrey,
          colorTo: Colors.orange,
          state: settings.enablePingNotifications,
        ),
        onTap: () {
          settings.enablePingNotifications = !settings.enablePingNotifications;
          setState(() {});
        },
      ),
      
      new ListTile(
        leading: new Icon(Icons.notifications),
        title: new Text("Play a sound"),
        trailing: new ColorSwitch(
          colorFrom: Colors.blueGrey,
          colorTo: Colors.orange,
          state: settings.enableNotificationSound,
        ),
        onTap: () {
          settings.enableNotificationSound = !settings.enableNotificationSound;
          setState(() {});
        },
      ),
    ]),
  );
}
