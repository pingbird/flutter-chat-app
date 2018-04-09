import 'dart:ui' as ui;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:speed1/account.dart';
import 'package:speed1/common.dart';

class _RoundBtn extends StatelessWidget {
  _RoundBtn({
    this.text,
    this.fontSize,
    this.color,
    this.width,
    this.height,
    this.onTap,
  });
  
  final String text;
  final double fontSize;
  final Color color;
  final double width;
  final double height;
  final GestureTapCallback onTap;
  
  build(BuildContext context) => new ClipRRect(borderRadius: new BorderRadius.circular(10.0), child: new GestureDetector(child: new Container(
    width: width, height: height, color: color,
    child: new Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
      new Text(text, style: new TextStyle(color: Colors.white, fontFamily: "PT", fontSize: fontSize ?? 20.0)),
    ])
  ), onTap: onTap));
}


class SetupPage extends StatefulWidget {
  @override
  _SetupPageState createState() => new _SetupPageState();
}

class _SetupPageState extends State<SetupPage> with TickerProviderStateMixin {
  bool showLogin = false;
  bool register = false;
  bool login = false;
  bool rememberPW = true;

  final usernameCtrl = new TextEditingController();
  final passwordCtrl = new TextEditingController();
  
  initState() {
    super.initState();
    secureStorage.read(key: "savedUsername").then((value) {
      if (value != null) usernameCtrl.text = value;
    });
    
    secureStorage.read(key: "savedPassword").then((value) {
      if (value != null) passwordCtrl.text = value;
    });
  }
  
  var k = new GlobalKey();
  
  dispose() {
    super.dispose();
  }
  
  build(BuildContext context) => new Scaffold(
    body: new Builder(builder: (context) => new DecoratedBox(decoration: new BoxDecoration(
      gradient: new LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.lightBlue,
          Colors.purple,
        ]
      ),
    ), child: new Padding(padding: const EdgeInsets.all(32.0), child: new Column(
      children: [
        new Expanded(child: new Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text("DashChat", style: const TextStyle(
            color: Colors.white,
            fontSize: 55.0,
            fontFamily: "PT",
          )),
        ])),
        new Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          new AnimatedCrossFade(duration: const Duration(milliseconds: 250), firstChild: new SizedBox(height: 172.0, child: new Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            new Row(children: [new Expanded(child: new Container())]), // Ensure maximum width for animated cross fade
            new _RoundBtn(
              text: "Login",
              width: 250.0, height: 40.0, color: new ColorTween(
                begin: Colors.lightBlue.shade400,
                end: Colors.purple.shade400,
              ).lerp(0.8).withOpacity(1.0), onTap: () {
                if (!showLogin) setState(() {
                  login = true;
                  register = false;
                  showLogin = true;
                });
              },
            ),
            new Padding(padding: const EdgeInsets.only(top: 32.0)),
            new _RoundBtn(
              text: "Register",
              width: 250.0, height: 40.0, color: new ColorTween(
              begin: Colors.lightBlue.shade400,
              end: Colors.purple.shade400,
            ).lerp(0.5).withOpacity(1.0), onTap: () {
              if (!showLogin) setState(() {
                register = true;
                login = false;
                showLogin = true;
              });
            }),
          ])), secondChild: new Column(key: k, children: [
            new TextField(
              controller: usernameCtrl,
              style: const TextStyle(
                color: Colors.white, fontSize: 20.0
              ),
              decoration: new InputDecoration(
                labelText: "Username",
                labelStyle: const TextStyle(color: Colors.white),
                hintStyle: new TextStyle(color: Colors.white.withOpacity(0.2)),
                border: InputBorder.none,
              ),
            ),
            new Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              new Expanded(child: new TextField(
                controller: passwordCtrl,
                style: const TextStyle(
                  color: Colors.white, fontSize: 20.0
                ),
                obscureText: true,
                decoration: new InputDecoration(
                  labelText: "Password",
                  labelStyle: const TextStyle(color: Colors.white),
                  hintStyle: new TextStyle(color: Colors.white.withOpacity(0.2)),
                  border: InputBorder.none,
                ),
              )),
              
              new GestureDetector(child: new Column(children: [
                const Text("Remember", style: const TextStyle(color: Colors.white)),
                const Padding(padding: const EdgeInsets.only(bottom: 8.0)),
                new ColorSwitch(
                  colorFrom: Colors.blueGrey.withOpacity(0.3),
                  colorTo: new ColorTween(
                    begin: Colors.lightBlue.shade400,
                    end: Colors.purple.shade400,
                  ).lerp(0.5).withOpacity(0.7),
                  state: rememberPW,
                ),
              ]), onTap: () {
                rememberPW = !rememberPW;
                setState(() {});
              }),
            ]),

            new Padding(padding: const EdgeInsets.only(top: 8.0)),
            
            new Row(children: [
              new Expanded(child: new _RoundBtn(
                height: 30.0, fontSize: 17.0,
                text: "Back", color: new ColorTween(
                  begin: Colors.lightBlue.shade400,
                  end: Colors.purple.shade400,
                ).lerp(0.8).withOpacity(0.7), onTap: () {
                  setState(() {
                    showLogin = false;
                    unfocus();
                  });
                },
              )),

              new Padding(padding: const EdgeInsets.only(right: 16.0)),
              
              new Expanded(child: new _RoundBtn(
                height: 30.0, fontSize: 17.0,
                text: login ? "Login" : "Register", color: new ColorTween(
                  begin: Colors.lightBlue.shade400,
                  end: Colors.purple.shade400,
                ).lerp(0.5).withOpacity(0.7), onTap: () async {
                  try {
                    if (login) {
                      var reply = await account.signIn(
                        usernameCtrl.text, passwordCtrl.text);
                      if (!reply.success) {
                        Scaffold.of(context).showSnackBar(new SnackBar(
                          content: new Text(reply.message,
                            style: const TextStyle(color: Colors.red)),
                        ));
                      } else {
                        Navigator.of(context).pushReplacementNamed("home");
                      }
                    } else {
                      var reply = await account.signUp(
                        usernameCtrl.text, passwordCtrl.text);
                      if (!reply.success) {
                        Scaffold.of(context).showSnackBar(new SnackBar(
                          content: new Text(reply.message,
                            style: const TextStyle(color: Colors.red)),
                        ));
                      } else {
                        Navigator.of(context).pushReplacementNamed("home");
                      }
                    }
                  } on SocketException catch (e, bt) {
                    print(e.toString() + bt.toString());
                    Scaffold.of(context).showSnackBar(new SnackBar(
                      content: new Text("Socket Error: ${e.osError.message}", style: const TextStyle(color: Colors.red)),
                    ));
                  } catch (e, bt) {
                    print(e.toString() + bt.toString());
                    Scaffold.of(context).showSnackBar(new SnackBar(
                      content: new Text(e.toString(), style: const TextStyle(color: Colors.red)),
                    ));
                  }

                  secureStorage.write(key: "savedUsername", value: usernameCtrl.text);
                  if (rememberPW) {
                    secureStorage.write(key: "savedPassword", value: passwordCtrl.text);
                  } else {
                    secureStorage.delete(key: "savedPassword");
                  }
                },
              )),
            ]),
          ]), crossFadeState: showLogin ? CrossFadeState.showSecond : CrossFadeState.showFirst),
        ])
      ],
    )))),
  );
}
