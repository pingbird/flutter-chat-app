import 'package:flutter/material.dart';
import 'package:speed1/account.dart';
import 'package:speed1/common.dart';
import 'package:speed1/main.dart';
import 'package:speed1/pages/profile.dart';
import 'package:speed1/state.dart';

class FriendsPage extends StatefulWidget {
  createState() => new _FriendsPageState();
}

class _FriendReq extends StatefulWidget {
  final ValueStore<ProfileRef> user;
  _FriendReq(this.user) : super(key: new ValueKey("req-${user.v.uuid}"));
  createState() => new _FriendReqState();
}

class _FriendReqState extends State<_FriendReq> with TickerProviderStateMixin {
  AnimationController sizeCtrl;
  
  initState() {
    super.initState();
    sizeCtrl = new AnimationController(value: 1.0, vsync: this, duration: const Duration(milliseconds: 250));
  }
  
  dispose() {
    super.dispose();
    sizeCtrl.dispose();
  }
  
  build(BuildContext context) => new SizeTransition(child: new Dismissible(key: new ValueKey(widget.user.v.uuid), child: new ListTile(
    leading: new Hero(tag: "avatar-${widget.user.v.uuid}-2", child: new UserAvatar(widget.user)),
    title: new Row(children: [
      new Text(widget.user.v.displayName),
    ]),
    trailing: new Row(children: [
      account.incomingFriends.containsKey(widget.user.v.uuid) ? new IconButton(icon: new Icon(Icons.check), onPressed: () {
        sizeCtrl.animateTo(0.0, curve: Curves.easeIn);
      }) : new Container(),
      new IconButton(icon: new Icon(Icons.close), onPressed: () {
        sizeCtrl.animateTo(0.0, curve: Curves.easeIn);
      }),
    ]),
    onTap: () {
      Navigator.of(context).push(new MaterialPageRoute(builder: (ctx) =>
        new ProfilePage(widget.user),
      ));
    },
  ), background: new DecoratedBox(
    decoration: new BoxDecoration(gradient: new LinearGradient(
      colors: [
        Colors.red,
        Colors.pink.shade300,
      ],
    )),
    child: new ListTile(
      leading: new Icon(Icons.close, color: Colors.white),
    ),
  ), secondaryBackground: new DecoratedBox(
    decoration: new BoxDecoration(gradient: new LinearGradient(
      colors: [
        Colors.lightGreen.shade300,
        Colors.green,
      ],
    )),
    child: new ListTile(
      trailing: new Icon(Icons.check, color: Colors.white),
    ),
  )), sizeFactor: sizeCtrl, axisAlignment: 0.0);
}

class _FriendInfo extends StatefulWidget {
  final ValueStore<ProfileRef> user;
  final bool initial;
  _FriendInfo(this.user, [this.initial = true]) : super(key: new ValueKey("fri-${user.v.uuid}"));
  createState() => new _FriendInfoState();
}

class _FriendInfoState extends State<_FriendInfo> with TickerProviderStateMixin{
  
  AnimationController sizeCtrl;
  
  initState() {
    super.initState();
    sizeCtrl = new AnimationController(value: widget.initial ? 1.0 : 0.0, vsync: this, duration: const Duration(milliseconds: 2500));
    if (!widget.initial) sizeCtrl.animateTo(1.0, curve: Curves.easeIn);
  }
  
  dispose() {
    super.dispose();
    sizeCtrl.dispose();
  }
  
  build(BuildContext context) => new SizeTransition(child: new ListTile(
    leading: new Hero(tag: "avatar-${widget.user.v.uuid}", child: new UserAvatar(widget.user)),
    
    title: new Row(children: [
      new OnlineIndicator(
        state: ProfileOnlineState.busy,
      ),
      const Padding(padding: const EdgeInsets.only(right: 8.0)),
      new Text(widget.user.v.displayName),
    ]),
    
    onTap: () {
      Navigator.of(context).push(new MaterialPageRoute(builder: (ctx) =>
        new ProfilePage(widget.user)
      ));
    },
  ), sizeFactor: sizeCtrl);
}


class _FriendsPageState extends State<FriendsPage> with TickerProviderStateMixin {
  List<ValueStore<ProfileRef>> friends;
  
  initState() {
    super.initState();
    friends = account.friends.values.toList();
  }
  
  dispose() {
    super.dispose();
  }
  
  Widget build(BuildContext context) => new Scaffold(
    appBar: new GradientAppBar(
      colors: [
        Colors.pink,
        Colors.purple,
      ],
      text: "Friends",
      leading: new IconButton(icon: new Icon(Icons.arrow_back), onPressed: () {
        Navigator.of(context).pop();
      }),
      actions: [
        new IconButton(icon: new Icon(Icons.add), onPressed: () {
        
        })
      ],
    ),
    body: new ListView(children: (friends.map((user) {
      return new _FriendInfo(user) as Widget;
    }).toList()..addAll([
      const Padding(padding: const EdgeInsets.only(top: 8.0)),
      new Center(child:
        new Text("Pending")
      ),
      const Divider(),
    ])..addAll(([
      account.incomingFriends.values,
      account.outboundFriends.values,
    ].expand((e) => e).map((user) {
      return new _FriendReq(user);
    }))))),
  );
}
