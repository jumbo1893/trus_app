import 'dart:async';

mixin ViewControllerMixin {

  final Map<String, String> viewValues = {};
  final Map<String, bool> createdAchievementChecker = {};
  final Map<String, StreamController<String>> viewControllers = {};
  final Map<String, StreamController<String>> viewErrorTextControllers = {};

  void _setAlreadyCreated(String key) {
    createdAchievementChecker[key] = true;
  }

  void _createViewCheckedList(String key) {
    if(!(createdAchievementChecker[key]?? false)) {
      _setAlreadyCreated(key);
      viewValues[key] = "";
      viewControllers[key] = StreamController<String>.broadcast();
      viewErrorTextControllers[key] = StreamController<String>.broadcast();
    }
  }

  Stream<String> viewValue(String key) {
    _createViewCheckedList(key);
    return viewControllers[key]?.stream ?? const Stream.empty();
  }

  Stream<String> viewErrorText(String key) {
    _createViewCheckedList(key);
    return viewErrorTextControllers[key]?.stream ?? const Stream.empty();
  }

  void setViewValue(String name, String key) {
    _createViewCheckedList(key);
    viewValues[key] = name;
    viewControllers[key]?.add(name);
  }

  void initViewFields(String name, String key) {
    _createViewCheckedList(key);
    setViewValue(name, key);
    viewErrorTextControllers[key]?.add("");
  }
}
