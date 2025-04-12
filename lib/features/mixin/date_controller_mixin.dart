import 'dart:async';

mixin DateControllerMixin {

  final Map<String, DateTime> dateValues = {};
  final Map<String, bool> createdDateChecker = {};
  final Map<String, StreamController<DateTime>> dateControllers = {};
  final Map<String, StreamController<String>> dateErrorTextControllers = {};

  void _setAlreadyCreated(String key) {
    createdDateChecker[key] = true;
  }

  void _createDateCheckedList(String key) {
    if(!(createdDateChecker[key]?? false)) {
      _setAlreadyCreated(key);
      dateValues[key] = DateTime.now();
      dateControllers[key] = StreamController<DateTime>.broadcast();
      dateErrorTextControllers[key] = StreamController<String>.broadcast();
    }
  }

  Stream<DateTime> date(String key) {
    _createDateCheckedList(key);
    return dateControllers[key]?.stream ?? const Stream.empty();
  }

  Stream<String> dateErrorText(String key) {
    _createDateCheckedList(key);
    return dateErrorTextControllers[key]?.stream ?? const Stream.empty();
  }

  void setDate(DateTime date, String key) {
    _createDateCheckedList(key);
    dateValues[key] = date;
    dateControllers[key]?.add(date);
  }

  void initDateFields(DateTime date, String key) {
    _createDateCheckedList(key);
    setDate(date, key);
    dateErrorTextControllers[key]?.add("");
  }
}
