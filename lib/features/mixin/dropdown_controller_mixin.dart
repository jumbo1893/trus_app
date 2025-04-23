import 'dart:async';

import '../../models/api/interfaces/dropdown_item.dart';

mixin DropdownControllerMixin {
  final Map<String, List<DropdownItem>> dropdownLists = {};
  final Map<String, DropdownItem> dropdownValues = {};
  final Map<String, bool> createdDropdownChecker = {};
  final Map<String, StreamController<DropdownItem>> dropdownControllers = {};
  final Map<String, StreamController<List<DropdownItem>>> dropdownListControllers = {};
  final Map<String, StreamController<String>> dropdownErrorTextControllers = {};

  void _setAlreadyCreated(String key) {
    createdDropdownChecker[key] = true;
  }

  void _createDropdownCheckedList(String key) {
    if(!(createdDropdownChecker[key]?? false)) {
      _setAlreadyCreated(key);
      dropdownLists[key] = [];
      dropdownControllers[key] = StreamController<DropdownItem>.broadcast();
      dropdownListControllers[key] = StreamController<List<DropdownItem>>.broadcast();
      dropdownErrorTextControllers[key] = StreamController<String>.broadcast();
    }
  }

  Stream<DropdownItem> dropdownItem(String key) {
    _createDropdownCheckedList(key);
    return dropdownControllers[key]?.stream ?? const Stream.empty();
  }

  Future<List<DropdownItem>> dropdownItemList(String key) {
    _createDropdownCheckedList(key);
    return Future.delayed(Duration.zero, () => dropdownLists[key]!);
  }

  Stream<List<DropdownItem>> dropdownItemListStream(String key) {
    _createDropdownCheckedList(key);
    return dropdownListControllers[key]?.stream ?? const Stream.empty();
  }

  void setDropdownItem(DropdownItem dropdownItem, String key) {
    _setDropdownItem(dropdownItem, key);
  }

  void setDropdownItemList(List<DropdownItem> items, String key) {
    dropdownLists[key] = items;
    dropdownListControllers[key]!.add(items);
  }

  void _setDropdownItem(DropdownItem dropdownItem, String key) {
    _createDropdownCheckedList(key);
    dropdownControllers[key]!.add(dropdownItem);
    dropdownValues[key] = dropdownItem;
  }

  void initDropdown(DropdownItem item, List<DropdownItem> items, String key) {
    _createDropdownCheckedList(key);
    _setDropdownItem(item, key);
    dropdownLists[key] = items;
  }

  void initDropdownItem(String key) {
    _createDropdownCheckedList(key);
    dropdownControllers[key]!.add(dropdownValues[key]!);
  }
}
