import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/api/interfaces/dropdown_item.dart';
import 'i_dropdown_state.dart';

class DropdownState implements IDropdownState {
  final AsyncValue<List<DropdownItem>> dropdownItems;
  final DropdownItem? selected;

  const DropdownState({
    required this.dropdownItems,
    required this.selected,
  });

  factory DropdownState.initial() {
    return const DropdownState(
      dropdownItems: AsyncValue.loading(),
      selected: null,
    );
  }

  DropdownState copyWith({
    AsyncValue<List<DropdownItem>>? dropdownItems,
    DropdownItem? selected,
  }) {
    return DropdownState(
      dropdownItems: dropdownItems ?? this.dropdownItems,
      selected: selected ?? this.selected,
    );
  }

  @override
  DropdownItem? getSelected() {
    return selected;
  }

  @override
  AsyncValue<List<DropdownItem>> getDropdownItems() {
    return dropdownItems;
  }
}
