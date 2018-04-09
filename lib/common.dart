import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speed1/account.dart';
import 'package:speed1/main.dart';
import 'package:speed1/state.dart';

class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  GradientAppBar({
    this.text,
    this.colors,
    this.leading,
    this.actions,
  });
  
  final Widget leading;
  final List<Widget> actions;
  final List<Color> colors;
  final String text;
  
  build(BuildContext context) => new Stack(children: [
    new Positioned(child: new DecoratedBox(decoration: new BoxDecoration(
      gradient: new LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight)
    ), child: new Container())),
    new AppBar(
      leading: leading,
      title: new Row(children: [
        new Expanded(child: new Text(text, textAlign: TextAlign.center, style: const TextStyle(
          fontFamily: "PT",
          fontSize: 25.0,
        )
      ))]),
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      actions: actions,
    ),
  ]);
  
  final preferredSize = const Size.fromHeight(56.0);
}

Map<ProfileOnlineState, Color> _onlineIndicatorColors = {
  ProfileOnlineState.online: Colors.green,
  ProfileOnlineState.idle: Colors.amber,
  ProfileOnlineState.busy: Colors.red,
  ProfileOnlineState.offline: Colors.blueGrey,
};

class OnlineIndicator extends StatelessWidget {
  final double size;
  final ProfileOnlineState state;
  OnlineIndicator({
    this.size = 12.0,
    this.state,
  });
  
  get _brad => new BorderRadius.circular(size / 2);
  
  build(context) => new ClipRRect(borderRadius: _brad, child: new Container(
    color: new ColorTween(
      begin: Colors.black,
      end: _onlineIndicatorColors[state],
    ).lerp(0.8),
    child: new ClipRRect(borderRadius: _brad, child: new Container(
      color: _onlineIndicatorColors[state],
    )),
    padding: new EdgeInsets.all(size / 8),
    width: size,
    height: size,
  ));
}

class ColorSwitch extends StatefulWidget {
  final Color colorFrom;
  final Color colorTo;
  final bool state;
  
  ColorSwitch({
    this.colorFrom,
    this.colorTo,
    this.state = false,
  });
  
  createState() => new _ColorSwitchState();
}

class _ColorSwitchState extends State<ColorSwitch> with TickerProviderStateMixin {
  AnimationController anim;
  
  initState() {
    super.initState();
    anim = new AnimationController(value: widget.state ? 1.0 : 0.0, vsync: this, duration: const Duration(milliseconds: 200))
      ..addListener(() {
        setState(() {});
      });
  }
  
  dispose() {
    super.dispose();
    anim.dispose();
  }
  
  didUpdateWidget(ColorSwitch other) {
    super.didUpdateWidget(other);
    
    if (widget.state != other.state) anim.animateTo(widget.state ? 1.0 : 0.0, curve: Curves.easeIn);
  }

  static const width = 45.0;
  static const innerWidth = 20.0;
  
  build(BuildContext context) {
    return new ClipRRect(borderRadius: new BorderRadius.circular(8.0), child: new Container(
      color: new ColorTween(
        begin: widget.colorFrom,
        end: widget.colorTo,
      ).lerp(anim.value),
      width: width,
      height: 25.0,
      child: new Stack(children: [
        new Positioned(
          top: 0.0,
          bottom: 0.0,
          left: anim.value * (width - (8 + innerWidth)),
          child: new ClipRRect(borderRadius: new BorderRadius.circular(5.0), child: new Container(
            color: Colors.white,
            width: innerWidth,
          ))
        ),
      ]),
      padding: const EdgeInsets.all(4.0),
    ));
  }
}

const List<Color> _avatarColors = const [
  Colors.red,
  Colors.purple,
  Colors.indigo,
  Colors.lightBlue,
  Colors.teal,
  Colors.green,
  Colors.amber,
  Colors.orange,
];

class UserAvatar extends StatelessWidget {
  final ValueStore<ProfileRef> user;
  final double size;
  final bool circular;
  UserAvatar(this.user, {this.size = 40.0, this.circular = false});
  build(BuildContext context) {
    if (user.v.avatar != null) {
      return new ClipRRect(
        borderRadius: new BorderRadius.circular(10.0),
        child: new Image.asset(user.v.avatar, width: size, height: size, fit: BoxFit.cover),
      );
    } else {
      var hash = 0;
      for (var char in user.v.uuid.codeUnits) {
        hash ^= char;
        hash ^= hash << 13;
        hash ^= hash >> 17;
        hash ^= hash << 5;
        hash = hash & 0xFFFFFFFF;
      }
      var rand = new Random(hash);
      var idx = rand.nextInt(_avatarColors.length);
      
      return new ClipRRect(
        borderRadius: new BorderRadius.circular(circular ? 180.0 : 10.0),
        child: new DecoratedBox(decoration: new BoxDecoration(
          gradient: new LinearGradient(colors: [
            _avatarColors[idx],
            _avatarColors[(idx + 1) % _avatarColors.length],
          ], begin: new Alignment(rand.nextDouble(), rand.nextDouble()), end: new Alignment(rand.nextDouble(), rand.nextDouble())),
        ), child: new Container(width: size, height: size)),
      );
    }
  }
}

class MultiUserAvatar extends StatefulWidget {
  final double size;
  final List<ValueStore<ProfileRef>> users;
  MultiUserAvatar(this.users, {this.size = 40.0});
  createState() => new _MultiUserAvatarState();
}

class _MultiUserAvatarState extends State<MultiUserAvatar> {
  build(BuildContext context) {
    var coords = <Offset>[];
    var minx = double.infinity;
    var maxx = double.negativeInfinity;
    var miny = double.infinity;
    var maxy = double.negativeInfinity;
    
    final radius = 0.5;
    
    void addBubble(int x, int y) {
      double scaledx = x + (y / 2);
      double scaledy = y * (sqrt(3) / 2);
      minx = min(minx, scaledx - radius);
      maxx = max(maxx, scaledx + radius);
      miny = min(miny, scaledy - radius);
      maxy = max(maxy, scaledy + radius);
      coords.add(new Offset(scaledx, scaledy));
    }
    
    int x = 0;
    int y = 0;
    
    bool cont() => coords.length < widget.users.length;
    
    if (cont()) addBubble(x, y);
    for (int n = 1; cont(); n++) {
      for (int i = 0; i < n && cont(); i++) addBubble(++x, y);
      for (int i = 0; i < n - 1 && cont(); i++) addBubble(x, ++y);
      for (int i = 0; i < n && cont(); i++) addBubble(--x, ++y);
      for (int i = 0; i < n && cont(); i++) addBubble(--x, y);
      for (int i = 0; i < n && cont(); i++) addBubble(x, --y);
      for (int i = 0; i < n && cont(); i++) addBubble(++x, --y);
    }
    double scale = 1 / max(maxx - minx, maxy - miny);
    double avsize = (radius * 2) * scale * widget.size;
    var children = <Widget>[];
    for (int i = 0; i < widget.users.length; i++) {
      var sx = ((coords[i].dx - minx) * scale) + (0.5 - ((maxx - minx) / 2) * scale);
      var sy = ((coords[i].dy - miny) * scale) + (0.5 - ((maxy - miny) / 2) * scale);
      children.add(new Positioned(
        left: (sx * widget.size) - (avsize / 2),
        top:  (sy * widget.size) - (avsize / 2),
        child: new UserAvatar(widget.users[i], size: avsize, circular: true),
      ));
    }
    
    return new Stack(children: [
      new Container(
      color: Colors.blueGrey.shade100,
      width: widget.size,
      height: widget.size,
      child: new Stack(children: children),
    )]);
  }
}

class ConnectionStatusBar extends StatefulWidget {
  createState() => new _ConnectionStatusBarState();
}

class _ConnectionStatusBarState extends State<ConnectionStatusBar> {
  build(context) => new PreferredSize(child: new LinearProgressIndicator(), preferredSize: new Size.fromHeight(8.0));
}


unfocus() => SystemChannels.textInput.invokeMethod('TextInput.hide');