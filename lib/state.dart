import 'dart:async';

import 'package:flutter/material.dart';

abstract class Store<T> {
  Store(this._parent);
  Store _parent;
  StreamController<Null> _updates = new StreamController.broadcast();
  Stream<Null> get updates => _updates.stream;
  void notify() {
    _updates.add(null);
    _parent?.notify();
  }
}

class ValueStore<T> extends Store<T> {
  ValueStore([this._value, parent]) : super(parent);
  T _value;
  T get v => _value;
  set v(T other) {
    if (diff(other)) {
      _value = other;
      notify();
    }
  }
  bool diff(T other) => _value != other;
}

abstract class StoreState<T extends StatefulWidget> extends State<T> {
  final List<Store> stores = [];
  final List<StreamSubscription<Null>> _storeSubscriptions = [];
  
  onUpdate() {
    setState(() {});
  }
  
  initState() {
    super.initState();
    for (var st in stores) {
      _storeSubscriptions.add(st.updates.listen((_) {
        onUpdate();
      }));
    }
  }
  
  dispose() {
    super.dispose();
    _storeSubscriptions.forEach((e) => e.cancel());
  }
}