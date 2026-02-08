import 'dart:async';

import 'package:trus_app/models/api/helper/list_models.dart';

mixin ListModelControllerMixin {

  final Map<String, ListModels> listModelValues = {};
  final Map<String, bool> createdListModelChecker = {};
  final Map<String, StreamController<ListModels>> listModelControllers = {};

  void _setAlreadyCreated(String key) {
    createdListModelChecker[key] = true;
  }

  void _createListModelStream(String key) {
    if(!(createdListModelChecker[key]?? false)) {
      _setAlreadyCreated(key);
      listModelValues[key] = ListModels([], true);
      listModelControllers[key] = StreamController<ListModels>.broadcast();
    }
  }

  Stream<ListModels> listModelValue(String key) {
    _createListModelStream(key);
    return listModelControllers[key]?.stream ?? const Stream.empty();
  }

  void setListModelValue(ListModels listModels, String key) {
    _createListModelStream(key);
    listModelValues[key] = listModels;
    listModelControllers[key]?.add(listModels);
  }

  void initListModelFields(ListModels listModels, String key) {
    _createListModelStream(key);
    setListModelValue(listModels, key);
  }
}
