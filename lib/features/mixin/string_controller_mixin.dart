import 'dart:async';
mixin StringControllerMixin {

  final Map<String, String> stringValues = {};
  final Map<String, bool> createdStringChecker = {};
  final Map<String, StreamController<String>> stringControllers = {};
  final Map<String, StreamController<String>> stringErrorTextControllers = {};

  void _setAlreadyCreated(String key) {
    createdStringChecker[key] = true;
  }

  void _createStringCheckedList(String key) {
    if(!(createdStringChecker[key]?? false)) {
      _setAlreadyCreated(key);
      stringValues[key] = "";
      stringControllers[key] = StreamController<String>.broadcast();
      stringErrorTextControllers[key] = StreamController<String>.broadcast();
    }
  }

  Stream<String> stringValue(String key) {
    _createStringCheckedList(key);
    return stringControllers[key]?.stream ?? const Stream.empty();
  }

  Stream<String> stringErrorText(String key) {
    _createStringCheckedList(key);
    return stringErrorTextControllers[key]?.stream ?? const Stream.empty();
  }

  void setStringValue(String name, String key) {
    _createStringCheckedList(key);
    stringValues[key] = name;
    stringControllers[key]?.add(name);
  }

  void initStringFields(String name, String key) {
    _createStringCheckedList(key);
    setStringValue(name, key);
    stringErrorTextControllers[key]?.add("");

  }
}
