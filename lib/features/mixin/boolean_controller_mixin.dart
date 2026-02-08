import 'dart:async';

mixin BooleanControllerMixin {

  final Map<String, bool> boolValues = {};
  final Map<String, bool> createdBoolChecker = {};
  final Map<String, StreamController<bool>> boolControllers = {};

  void _setAlreadyCreated(String key) {
    createdBoolChecker[key] = true;
  }

  void createBooleanCheckedList(String key) {
    if(!(createdBoolChecker[key]?? false)) {
      _setAlreadyCreated(key);
      boolValues[key] = true;
      boolControllers[key] = StreamController<bool>.broadcast();
    }
  }

  Stream<bool> boolean(String key) {
    createBooleanCheckedList(key);
    return boolControllers[key]?.stream ?? const Stream.empty();
  }

  void setBoolean(bool boolean, String key) {
    setBooleanInternal(boolean, key);
  }

  void setBooleanInternal(bool boolean, String key) {
    createBooleanCheckedList(key);
    boolValues[key] = boolean;
    boolControllers[key]?.add(boolean);
  }

  void initBooleanFields(bool boolean, String key) {
    createBooleanCheckedList(key);
    setBooleanInternal(boolean, key);
  }
}
