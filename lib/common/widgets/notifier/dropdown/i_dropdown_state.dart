import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/models/api/interfaces/dropdown_item.dart';

abstract class IDropdownState {
  DropdownItem? getSelected();
  AsyncValue<List<DropdownItem>> getDropdownItems();
}