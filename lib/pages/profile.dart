import 'package:flutter/material.dart';
import 'package:speed1/account.dart';
import 'package:speed1/common.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speed1/state.dart';

class ProfilePage extends StatefulWidget {
  ValueStore<ProfileRef> user;
  ProfilePage(this.user);
  createState() => new _ProfilePageState();
}

class _ProfilePageState extends StoreState<ProfilePage> {
  get stores => [widget.user];
  
  bool editMode = false;
  
  var profileNameCtrl = new TextEditingController();
  
  build(BuildContext context) => new MediaQuery.removePadding(context: context, removeTop: true, child: new Scaffold(
    body: new ListView(children: [
      new DecoratedBox(decoration: new BoxDecoration(gradient: new LinearGradient(
        colors: [
          Colors.lightBlue,
          Colors.indigo,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      )), child: new Column(children: [
        new Padding(padding: new EdgeInsets.only(top: MediaQuery.of(context).padding.top)),
        new Padding(padding: const EdgeInsets.all(4.0), child: new Row(children: [
          new IconButton(icon: new Icon(Icons.arrow_back, color: Colors.white), onPressed: () {
            Navigator.of(context).pop();
          }),
          new Expanded(child: new Container()),
          editMode ? new IconButton(icon: new Icon(Icons.delete, color: Colors.white), onPressed: () {
          
          }) : new Container(),
          widget.user.v.uuid == account.profile.v.uuid ? new IconButton(icon: new Icon(editMode ? Icons.save : Icons.edit, color: Colors.white), onPressed: () {
            profileNameCtrl.text = account.profile.v.displayName;
            editMode = !editMode;
            if (!editMode) {
            
            }
            setState(() {});
          }) : new Container(),
        ])),
        new Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          new Padding(padding: const EdgeInsets.all(8.0), child: new Hero(
            tag: "avatar-${widget.user.v.uuid}",
            child: editMode ? new Stack(
              children: [
                new UserAvatar(widget.user, size: 150.0),
                new ClipRRect(child: new Container(
                  color: Colors.black.withOpacity(0.5),
                  child: new Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    new Icon(Icons.photo_library, color: Colors.white, size: 50.0),
                  ]),
                  width: 150.0,
                  height: 150.0,
                ), borderRadius: new BorderRadius.circular(10.0))
              ],
            ) : new UserAvatar(widget.user, size: 150.0),
          )),
        ]),
        new Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          new OnlineIndicator(
            size: 16.0,
            state: ProfileOnlineState.busy,
          ),
          const Padding(padding: const EdgeInsets.only(right: 12.0)),
          editMode ? new ConstrainedBox(constraints: const BoxConstraints(
            maxWidth: 200.0,
          ), child: new TextField(
            controller: profileNameCtrl,
            style: const TextStyle(
              fontSize: 25.0,
              fontFamily: "PT",
              color: Colors.white,
            ),
            decoration: const InputDecoration(
              isDense: true,
            ),
          )) : new Text(widget.user.v.displayName, style: const TextStyle(
            fontSize: 25.0,
            fontFamily: "PT",
            color: Colors.white,
          )),
        ]),
        new Padding(padding: const EdgeInsets.only(bottom: 32.0)),
      ])),

      widget.user.v.uuid == account.profile.v.uuid || account.friends.containsKey(widget.user.v.uuid) ? new Container() : new ListTile(
        leading: new Icon(Icons.people),
        title: new Text("Add Friend"),
      ),

      widget.user.v.uuid == account.profile.v.uuid ? new Container() : new ListTile(
        leading: new Icon(Icons.message),
        title: new Text("Message"),
      ),

      widget.user.v.uuid == account.profile.v.uuid ? new Container() : new ListTile(
        leading: new Icon(Icons.report),
        title: new Text("Report"),
      ),
    ]),
  ));
}
