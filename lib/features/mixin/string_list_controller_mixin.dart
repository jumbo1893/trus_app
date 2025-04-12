import 'dart:async';

mixin StringListControllerMixin {

  final Map<String, List<String>> stringListValues = {};
  final Map<String, bool> createdStringListChecker = {};
  final Map<String, StreamController<List<String>>> stringListControllers = {};

  void _setAlreadyCreated(String key) {
    createdStringListChecker[key] = true;
  }

  void _createStringListStream(String key) {
    if(!(createdStringListChecker[key]?? false)) {
      _setAlreadyCreated(key);
      stringListValues[key] = [];
      stringListControllers[key] = StreamController<List<String>>.broadcast();
    }
  }

  Stream<List<String>> stringListValue(String key) {
    _createStringListStream(key);
    return stringListControllers[key]?.stream ?? const Stream.empty();
  }

  void setStringListValue(List<String> strings, String key) {
    _createStringListStream(key);
    stringListValues[key] = strings;
    stringListControllers[key]?.add(strings);
  }

  void initStringListFields(List<String> strings, String key) {
    _createStringListStream(key);
    setStringListValue(strings, key);
  }
}
