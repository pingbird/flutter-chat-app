import 'package:flutter/material.dart';
import 'package:speed1/account.dart';
import 'package:speed1/common.dart';
import 'package:speed1/pages/profile.dart';
import 'package:speed1/state.dart';

class HomePage extends StatefulWidget {
  createState() => new _HomePageState();
}

class _HomePageState extends StoreState<HomePage> {
  final stores = [
    account.profile,
  ];
  
  build(BuildContext context) => new Scaffold(
    appBar: new GradientAppBar(
      text: "DashChat",
      colors: [
        Colors.lightBlue,
        Colors.green,
      ],
      actions: [
        new IconButton(icon: new Icon(Icons.settings), onPressed: () {
          Navigator.of(context).pushNamed("settings");
        }),
      ],
      leading: new Builder(builder: (context) => new IconButton(icon: new Icon(Icons.menu), onPressed: () {
        Scaffold.of(context).openDrawer();
      })),
    ),
    drawer: new Builder(builder: (context) => new Drawer(child: new DecoratedBox(decoration: new BoxDecoration(
      gradient: new LinearGradient(colors: [
        Colors.purple,
        Colors.orange,
      ], begin: Alignment.topLeft, end: Alignment.bottomRight),
    ), child: new SingleChildScrollView(child: new Column(children: [
      new Padding(padding: new EdgeInsets.only(top: MediaQuery.of(context).padding.top)),
      new ListTile(
        leading: new UserAvatar(account.profile),
        title: new Text(account.profile.v.displayName, style: const TextStyle(color: Colors.white)),
        subtitle: new Row(children: [
          new OnlineIndicator(state: ProfileOnlineState.online),
        ]),
        trailing: new IconButton(icon: new Icon(Icons.exit_to_app, color: Colors.white), onPressed: () async {
          var res = await showDialog<bool>(context: context, child: new AlertDialog(
            content: const Text("Are you sure you want to sign out?"),
            actions: [
              new ButtonBar(children: [
                new FlatButton(onPressed: () {
                  Navigator.of(context).pop(false);
                }, child: const Text("CANCEL")),
                new FlatButton(onPressed: () {
                  Navigator.of(context).pop(true);
                }, child: const Text("SIGN OUT")),
              ]),
            ],
          ));
          
          if (res) {
            await account.signOut();
            Navigator.of(context).pushReplacementNamed("setup");
          }
        }),
      ),
      new Padding(padding: const EdgeInsets.symmetric(horizontal: 16.0), child: new Divider(color: Colors.white, height: 1.0)),
      new ListTile(
        leading: new Icon(Icons.account_circle, color: Colors.white),
        title: new Text("Profile", style: const TextStyle(color: Colors.white)),
        onTap: () {
          Navigator.of(context)
            ..pop()
            ..push(new MaterialPageRoute(builder: (ctx) =>
            new ProfilePage(account.profile)
          ));
        },
      ),
      new ListTile(
        leading: new Icon(Icons.people, color: Colors.white),
        title: new Text("Friends", style: const TextStyle(color: Colors.white)),
        onTap: () {
          Navigator.of(context)
            ..pop()
            ..pushNamed("friends");
        },
      ),
      new ListTile(
        leading: new Icon(Icons.archive, color: Colors.white),
        title: new Text("Archive", style: const TextStyle(color: Colors.white)),
      ),
      new Padding(padding: const EdgeInsets.symmetric(horizontal: 16.0), child: new Divider(color: Colors.white, height: 1.0)),
      new ListTile(
        leading: new Icon(Icons.info_outline, color: Colors.white),
        title: new Text("About DashChat", style: const TextStyle(color: Colors.white)),
        onTap: () {
          Navigator.of(context)
            ..pop()
            ..pushNamed("about");
        },
      ),
      new ListTile(
        leading: new Icon(Icons.pages, color: Colors.white),
        title: new Text("Legal", style: const TextStyle(color: Colors.white)),
        onTap: () {
          Navigator.of(context)
            ..pop()
            ..pushNamed("licenses");
        },
      ),
    ]))))),
    body: new ListView.builder(itemBuilder: (ctx, i) {
      return new MultiUserAvatar(account.friends.values.toList());
    }, itemCount: 1),
  );
}
