import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/widgets/notifier/dropdown/i_dropdown_state.dart';
import 'package:trus_app/common/widgets/notifier/listview/i_listview_state.dart';
import 'package:trus_app/models/api/football/stats/football_all_individual_stats_api_model.dart';
import 'package:trus_app/models/api/interfaces/model_to_string.dart';

import '../../../models/api/interfaces/dropdown_item.dart';

class FootballStatsState implements IDropdownState, IListviewState {
  final AsyncValue<List<DropdownItem>> dropdownTexts;
  final DropdownItem? selectedText;
  final AsyncValue<List<ModelToString>> stats;
  final List<FootballAllIndividualStatsApiModel> allStats;

  FootballStatsState({
    required this.dropdownTexts,
    required this.selectedText,
    required this.stats,
    required this.allStats,
  });

  factory FootballStatsState.initial() => FootballStatsState(
        dropdownTexts: const AsyncValue.loading(),
        selectedText: null,
        stats: const AsyncValue.loading(),
        allStats: [],
      );

  FootballStatsState copyWith({
    AsyncValue<List<DropdownItem>>? dropdownTexts,
    DropdownItem? selectedText,
    AsyncValue<List<ModelToString>>? stats,
    List<FootballAllIndividualStatsApiModel>? allStats,
  }) {
    return FootballStatsState(
      dropdownTexts: dropdownTexts ?? this.dropdownTexts,
      selectedText: selectedText ?? this.selectedText,
      stats: stats ?? this.stats,
      allStats: allStats ?? this.allStats,
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
