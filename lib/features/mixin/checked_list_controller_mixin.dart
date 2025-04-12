import 'dart:async';

import '../../models/api/interfaces/model_to_string.dart';

mixin CheckedListControllerMixin {

  final Map<String, List<ModelToString>> modelsLists = {};
  final Map<String, bool> createdCheckedListChecker = {};
  final Map<String, List<ModelToString>> checkedModelsLists = {};
  final Map<String, StreamController<List<ModelToString>>> checkedModelsControllers = {};
  final Map<String, StreamController<String>> checkedListsErrorTextControllers = {};

  void _setAlreadyCreated(String key) {
    createdCheckedListChecker[key] = true;
  }

  void _createCheckedListCheckedList(String key) {
    if(!(createdCheckedListChecker[key]?? false)) {
      _setAlreadyCreated(key);
      modelsLists[key] = [];
      checkedModelsLists[key] = [];
      checkedModelsControllers[key] = StreamController<List<ModelToString>>.broadcast();
      checkedListsErrorTextControllers[key] = StreamController<String>.broadcast();
    }
  }

  Future<List<ModelToString>> modelList(String key) {
    _createCheckedListCheckedList(key);
    return Future.delayed(Duration.zero, () => modelsLists[key] ?? []);
  }

  Stream<List<ModelToString>> checkedModels(String key) {
    _createCheckedListCheckedList(key);
    return checkedModelsControllers[key]?.stream ?? const Stream.empty();
  }

  Stream<String> checkedListErrorText(String key) {
    _createCheckedListCheckedList(key);
    return checkedListsErrorTextControllers[key]?.stream ?? const Stream.empty();
  }

  void setCheckedList(List<ModelToString> models, String key) {
    _createCheckedListCheckedList(key);
    checkedModelsLists[key] = models;
    checkedModelsControllers[key]?.add(models);
  }

  void initCheckedListFields(List<ModelToString> allModels, List<ModelToString> checkedModels, String key) {
    _createCheckedListCheckedList(key);
    modelsLists[key] = allModels;
    checkedModelsLists[key] = checkedModels;
    checkedModelsControllers[key]?.add(checkedModels);
    checkedListsErrorTextControllers[key]?.add("");
  }

  void initCheckedList(String key) {
    _createCheckedListCheckedList(key);
    checkedModelsControllers[key]?.add(checkedModelsLists[key] ?? []);
  }
}
