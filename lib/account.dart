import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:speed1/main.dart';
import 'package:speed1/state.dart';

final secureStorage = new FlutterSecureStorage();

class Settings {
  bool enableNotifications = false;
  bool enablePingNotifications = false;
  bool enableNotificationSound = false;
}

enum ProfileOnlineState {
  online,
  idle,
  busy,
  offline,
}

class ProfileRef {
  const ProfileRef(this.uuid, {
    this.userName,
    this.avatar,
    this.nickName,
  });
  
  ProfileRef.fromList(final List<dynamic> data) :
    uuid = data[0],
    userName = data[1],
    avatar = data[2],
    nickName = data[3];
  
  final String uuid;
  final String avatar;
  final String userName;
  final String nickName;
  
  get displayName => nickName ?? userName ?? uuid;
}

enum ConnectionStatus {
  offline,
  connecting,
  connected,
}

class DCConnection {
  Map<int, Completer<List<dynamic>>> replies = {};
  WebSocket _socket;
  String session;
  
  Future<Null> onConnect;
  
  ValueStore<ConnectionStatus> status = new ValueStore(ConnectionStatus.offline);
  
  var _onReconnectCtrl = new StreamController<Null>.broadcast();
  Stream<Null> get onReconnect => _onReconnectCtrl.stream;
  
  get connected => _socket != null && _socket.closeReason == null;
  
  Future<Null> tryConnect() async {
    if (connected) return;
    if (onConnect != null) {
      await onConnect;
      return;
    }
    
    replies = {};
    onConnect = (() async {
      try {
        status.v = ConnectionStatus.connecting;
        
        _socket = await WebSocket.connect("ws://10.0.2.2:3399/").timeout(const Duration(seconds: 10));
    
        if (_socket == null) {
          throw "Connection timed out.";
        }
        
        status.v = ConnectionStatus.connected;
        
        _socket.listen((data) {
          var x = JSON.decode(data);
          print(x);
          if (x[0] == 0) {
            // Handle broadcast
            if (x[1] == "updateProfile") {
              print("updating profile");
              var ref = new ProfileRef.fromList(x[2]);
              if (account.profileCache.containsKey(ref.uuid)) {
                account.profileCache[ref.uuid].v = ref;
              } else {
                account.profileCache[ref.uuid] = new ValueStore(ref);
              }
            }
          } else if (x[0] > 0) {
            // Handle incoming requests
          } else if (!replies.containsKey(-x[0])) {
            throw "Bad reply";
          } else {
            print(x);
            replies[-x[0]].complete((x as List<dynamic>).skip(1).toList());
          }
        }, cancelOnError: true, onDone: () {
          print("done!");
          status.v = ConnectionStatus.offline;
          if (appNavigatorKey.currentState != null) {
            print("ctx");
            if (appNavigatorKey.currentState.canPop()) {
              print("popping");
              appNavigatorKey.currentState.popUntil((r) => false);
              appNavigatorKey.currentState.pushNamed("setup");
            }
          }
        }).onError((e, bt) {
          print("WS error: $e");
          tryConnect();
        });
        
        _onReconnectCtrl.add(null);
        onConnect = null;
      } finally {
        onConnect = null;
      }
    })();
    
    await onConnect;
  }
  
  Future<List<dynamic>> request(List<dynamic> data) async {
    await tryConnect();
    
    var timeout = new Future.delayed(const Duration(seconds: 10));
    
    while (true) {
      int id = replies.isEmpty ? 1 : replies.keys.last + 1;
      while (replies.containsKey(id)) id++;
      var ctrl = new Completer<List<dynamic>>();
      replies[id] = ctrl;
      
      print("sending");
      _socket.add(JSON.encode(<dynamic>[id]..addAll(data)));
      print("sent");
      
      bool reconnect = false;
      try {
        var x = await Future.any(<Future<List<dynamic>>>[
          ctrl.future,
          timeout,
          onReconnect.first.then((_) {
            reconnect = true;
            return null;
          }),
        ]);
  
        if (x == null && !reconnect) {
          throw "Request timed out.";
        } else if (!reconnect) {
          return x;
        }
        
        print("retrying");
      } finally {
        if (!reconnect) replies.remove(id);
      }
    }
  }
  
  dispose() {
    _onReconnectCtrl.close();
  }

  Future<Null> disconnect() async {
    if (connected) await _socket.close();
  }
}

class Account {
  final connection = new DCConnection();

  String sessionUUID;
  String sessionResume;
  
  Map<String, ProfileOnlineState> onlineStateCache = {};
  Map<String, ValueStore<ProfileRef>> profileCache = {};
  
  void cleanProfileCache() => profileCache.keys.forEach((e) {
    if (
      e != account.profile.v.uuid &&
      !friends.containsKey(e) &&
      !incomingFriends.containsKey(e) &&
      !outboundFriends.containsKey(e)
    ) {
      profileCache.remove(e);
      if (onlineStateCache.containsKey(e)) onlineStateCache.remove(e);
    }
  });
  
  String uuid;
  ValueStore<ProfileRef> get profile => profileCache[uuid];
  
  Map<String, ValueStore<ProfileRef>> friends = {};
  Map<String, ValueStore<ProfileRef>> incomingFriends = {};
  Map<String, ValueStore<ProfileRef>> outboundFriends = {};

  Future<SignInStatus> signIn(String username, String password) async {
    var resp = await connection.request(["login", username, password]);
    if (resp[0] == false) return new SignInStatus(false, resp[1]);
    uuid = resp[1][0];
    if (!profileCache.containsKey(uuid)) profileCache[uuid] = new ValueStore<ProfileRef>();
    profile.v = new ProfileRef.fromList(resp[1]);
    sessionUUID = resp[2];
    sessionResume = resp[3];
    return new SignInStatus(true);
  }
  
  Future<Null> signOut() async {
    await connection.disconnect();
  }

  Future<SignInStatus> signUp(String username, String password) async {
    var resp = await connection.request(["register", username, password]);
    if (resp[0] == false) return new SignInStatus(false, resp[1]);
    uuid = resp[1][0];
    if (!profileCache.containsKey(uuid)) profileCache[uuid] = new ValueStore<ProfileRef>();
    profile.v = new ProfileRef.fromList(resp[1]);
    sessionUUID = resp[2];
    sessionResume = resp[3];
    return new SignInStatus(true);
  }
}

class SignInStatus {
  const SignInStatus(this.success, [this.message]);
  final bool success;
  final String message;
}

Settings settings = new Settings();
Account account = new Account();