import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/notifier/dropdown/i_dropdown_state.dart';
import 'package:trus_app/common/widgets/notifier/listview/i_listview_state.dart';
import 'package:trus_app/models/api/interfaces/model_to_string.dart';

import '../../../models/api/interfaces/dropdown_item.dart';

class BeerDetailStatsState implements IDropdownState, IListviewState {
  final AsyncValue<List<DropdownItem>> dropdownTexts;
  final DropdownItem? selectedText;
  final AsyncValue<List<ModelToString>> stats;

  BeerDetailStatsState({
    required this.dropdownTexts,
    required this.selectedText,
    required this.stats,
  });

  factory BeerDetailStatsState.initial() => BeerDetailStatsState(
        dropdownTexts: const AsyncValue.loading(),
        selectedText: null,
        stats: const AsyncValue.loading(),
      );

  BeerDetailStatsState copyWith({
    AsyncValue<List<DropdownItem>>? dropdownTexts,
    DropdownItem? selectedText,
    AsyncValue<List<ModelToString>>? stats,
  }) {
    return BeerDetailStatsState(
      dropdownTexts: dropdownTexts ?? this.dropdownTexts,
      selectedText: selectedText ?? this.selectedText,
      stats: stats ?? this.stats,
    );
  }

  @override
  AsyncValue<List<DropdownItem>> getDropdownItems() {
    return dropdownTexts;
  }

  @override
  DropdownItem? getSelected() {
    return selectedText;
  }

  @override
  AsyncValue<List<ModelToString>> getListViewItems() {
    return stats;
  }
}
