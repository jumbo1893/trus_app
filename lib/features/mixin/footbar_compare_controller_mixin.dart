import 'dart:async';

import 'package:trus_app/models/api/footbar/footbar_account_sessions.dart';

mixin FootbarCompareControllerMixin {

  final Map<String, List<FootbarAccountSessions>> viewValues = {};
  final Map<String, bool> createdFootbarCompareChecker = {};
  final Map<String, StreamController<List<FootbarAccountSessions>>> viewControllers = {};

  void _setAlreadyCreated(String key) {
    createdFootbarCompareChecker[key] = true;
  }

  void _createViewCheckedList(String key) {
    if(!(createdFootbarCompareChecker[key]?? false)) {
      _setAlreadyCreated(key);
      viewValues[key] = [];
      viewControllers[key] = StreamController<List<FootbarAccountSessions>>.broadcast();
    }
  }

  Stream<List<FootbarAccountSessions>> viewValue(String key) {
    _createViewCheckedList(key);
    return viewControllers[key]?.stream ?? const Stream.empty();
  }

  void setViewValue(List<FootbarAccountSessions> list, String key) {
    _createViewCheckedList(key);
    viewValues[key] = list;
    viewControllers[key]?.add(list);
  }

  void initViewFields(List<FootbarAccountSessions> list, String key) {
    _createViewCheckedList(key);
    setViewValue(list, key);
  }
}
