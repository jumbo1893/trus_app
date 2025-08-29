import 'dart:async';

import 'package:trus_app/models/api/interfaces/model_to_string.dart';

mixin ModelToStringListControllerMixin {

  final Map<String, List<ModelToString>> modelToStringListValues = {};
  final Map<String, bool> createdModelToStringListChecker = {};
  final Map<String, StreamController<List<ModelToString>>> modelToStringListControllers = {};

  void _setAlreadyCreated(String key) {
    createdModelToStringListChecker[key] = true;
  }

  void _createModelToStringListStream(String key) {
    if(!(createdModelToStringListChecker[key]?? false)) {
      _setAlreadyCreated(key);
      modelToStringListValues[key] = [];
      modelToStringListControllers[key] = StreamController<List<ModelToString>>.broadcast();
    }
  }

  Stream<List<ModelToString>> modelToStringListValue(String key) {
    _createModelToStringListStream(key);
    return modelToStringListControllers[key]?.stream ?? const Stream.empty();
  }

  void setModelToStringListValue(List<ModelToString> strings, String key) {
    _createModelToStringListStream(key);
    modelToStringListValues[key] = strings;
    modelToStringListControllers[key]?.add(strings);
  }

  void initModelToStringListFields(List<ModelToString> strings, String key) {
    _createModelToStringListStream(key);
    setModelToStringListValue(strings, key);
  }
}
