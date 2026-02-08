import 'dart:async';

import 'package:trus_app/models/helper/title_and_text.dart';

mixin TitleAndTextControllerMixin {

  final Map<String, TitleAndText> titleAndTextValues = {};
  final Map<String, bool> createdTitleAndTextChecker = {};
  final Map<String, StreamController<TitleAndText>> titleAndTextControllers = {};

  void _setAlreadyCreated(String key) {
    createdTitleAndTextChecker[key] = true;
  }

  void _createTitleAndTextCheckedList(String key) {
    if(!(createdTitleAndTextChecker[key]?? false)) {
      _setAlreadyCreated(key);
      titleAndTextValues[key] = TitleAndText(title: "", text: "");
      titleAndTextControllers[key] = StreamController<TitleAndText>.broadcast();
    }
  }

  Stream<TitleAndText> titleAndTextValue(String key) {
    _createTitleAndTextCheckedList(key);
    return titleAndTextControllers[key]?.stream ?? const Stream.empty();
  }

  void setTitleAndTextValue(TitleAndText titleAndText, String key) {
    _createTitleAndTextCheckedList(key);
    titleAndTextValues[key] = titleAndText;
    titleAndTextControllers[key]?.add(titleAndText);
  }

  void initTitleAndTextFields(TitleAndText titleAndText, String key) {
    _createTitleAndTextCheckedList(key);
    setTitleAndTextValue(titleAndText, key);
  }
}
